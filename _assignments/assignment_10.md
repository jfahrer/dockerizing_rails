# Assignment 10 - Integrating Sidekiq
To further optimize the our application, we will integrate [Sidekiq](https://github.com/mperham/sidekiq) and move the expensive score generation operation into a background job. In the `TodosController` (`app/controllers/todos_controller.rb`) we currently update the users scores after each action via a `after_action`:
```ruby
after_action :update_scores, only: [:create, :update, :destroy]
```

The `update_scores` method uses the `ScoreCalculator` to update the scores:
```ruby
def update_scores
  ScoreCalculator.call(Date.today)
end
```

The goal is to make the call to `ScoreCalculator.call(Date.today)` asynchronous since there is no good reason to do it inline with when the user updates the todo-list.

## Adding the Gem
As we would do with a non-dockerized application, we start by adding the Sidekiq gem to our `Gemfile`:

```ruby
gem "sidekiq", "~> 5.2.7"
```

The next step would be to run `bundle install`. This is somewhat problematic with our current setup. We have a discrete build step in which we build the container image. In this step we run `bundle install`. The `Gemfile.lock` does not yet have an entry for Sidekiq. If we would run `docker image build`, the `Gemfile.lock` would be updated as part of the build process of the image. However, only the file that is part of the image would be updated. Our local `Gemfile.lock` stays unchanged. That means over time we might end up with a different version of Sidekiq in our image.

We can work around this by creating the `Gemfile.lock` using a container to run bundle:
```
docker-compose run --rm app bundle
```

With the `Gemfile.lock` in place we can now build the image and can rest assured that we will always use the locked version of Sidekiq.

There are still a few problems tho:
* We have to run 2 commands in order to run install images
* Installing gems takes a long time because if the `Gemfile` or `Gemfile.lock` changes, the `RUN` instruction in our `Dockerfile` will be executed in the context of a "blank" ruby installation. Hence all gems in the `Gemfile` have to be installed.
* Switching between branches with different `Gemfiles`s becomes tedious. Every time we switch, we have to build the Docker image again.

To ensure a better experience we are going to use a concept we already learned about - a volume. We will use the volume to store a copy of our gems. Doing this allows us to skip building the image and just `bundle` as we would do with a non-dockerized ruby application.

Let's a volume `gems` to our `app` service definition:
```yaml
    volumes:
      - ./:/usr/src/app:cached
      - tmp:/usr/src/app/tmp
      - gems:/usr/local/bundle

```

And just like in the prior examples, we also have to add the volume to the `volumes` section:
```yaml
volumes:
  pg-data:
  tmp:
  gems:
```

From here on we can just run `docker-compose run --rm app bundle` to bundle our gems. Even switching between different branches will work seamlessly since the all gems we install over time will be persisted in the volume.

## Setting up Sidekiq
Now to the actual Sidekiq integration. Let's start by creating an initializer. Here is an example `config/initializers/sidekiq.rb`:
```ruby
redis_url = "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}/:#{ENV.fetch('REDIS_PORT', '6379')}/#{ENV.fetch('REDIS_DB', '0')}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
```

In [12factor](https://12factor.net/) manner we use environment variables to configure Sidekiq. We also make sure to fallback to default values in case the environment variables are not set. This also ensures that someone can develop the application without using Docker. We also applied these principles for the Postgres setup. Take another look at the `config/database.yml` if you want to refresh your memory. This pattern and the other 11 factors are great for containerized applications - both in development and production.


In order to make Sidekiq play nice with our test suite, we have to require `sidekiq/testing` and tell Sidekiq to run jobs inline in `spec/rails_helper.rb`:
```ruby
require 'sidekiq/testing'

Sidekiq::Testing.inline!
```

You can copy and paste those lines right bellow the `# Add additional requires below this line. Rails is not loaded until this point!` comment in `spec/rails_helper.rb`.

## Adding the service
Thanks to Docker and Compose, adding additional services to our Rails application becomes a breeze. All we have to do is:
* Add a service to our `docker-compose.yml` to run Redis:
  ```yaml
    redis:
      image: redis:5.0
      volumes:
        - redis-data:/data
  ```

* Add the `redis-data` volume to the volumes section:
  ```yaml
  volumes:
    pg-data:
    redis-data:
    tmp:
    gems:
  ```
  Redis will persist its data to `/data` when the service is stopped and read the backup on startup to restore it. By mounting a volume to `/data` we ensure that we keep the data around even when the container is deleted.

* Add a service to our `docker-compose.yml` to run Sidekiq:
  ```yaml
    sidekiq:
      image: your_docker_id/rails_app:v1
      command: ["sidekiq"]
      volumes:
        - ./:/usr/src/app
        - tmp:/usr/src/app/tmp
        - gems:/usr/local/bundle
      environment:
        - POSTGRES_HOST=pg
        - POSTGRES_USER=postgres
        - POSTGRES_PASSWORD=secret
        - REDIS_HOST=redis
        - RAILS_ENV
      tty: true
      stdin_open: true
  ```

The environment section of the `sidekiq` service is mostly identical with the one from the `app` service. There is one additional environment variable that we set: `REDIS_HOST=redis`. This environment variable is used in `config/initializers/sidekiq.rb` to configure Sidekiq. We could also specify `REDIS_PORT` and `REDIS_DB`, but since we are using the default values, there is no need to. However, we do have to add the `REDIS_HOST` environment variable to our `app` service so that Rails can enqueue jobs:
```yaml
      - REDIS_HOST=redis
```

We can omit the `build` directive for the `sidekiq` service since we use the same image as the `app` service. Docker Compose will build the image for `app` and then just re-use it for `sidekiq`. Check out the `_examples/docker-compose.yml.with_sidekiq` for a complete example.


## Creating the job
Now we have to write the code for the actual job. It will simply call `ScoreCalculator.call`.

So let's create `app/jobs/score_generation_job.rb`:
```ruby
class ScoreGenerationJob
  include Sidekiq::Worker

  def perform(date_string)
    ScoreCalculator.call(date_string.to_date)
  end
end
```

And then we update the `update_scores` method in `app/controllers/todos_controller.rb` to look like this:
```ruby
def update_scores
  ScoreGenerationJob.perform_async(Date.today)
end
```

So instead of calling the `ScoreCalculator` directly, we will enqueue a Sidekiq job that will do this for us.

Once you're done with the changes, restart the `app` service and run the specs to make sure everything works as expected:
```
docker-compose restart app
docker-compose run --rm app rspec
```

## Running Sidekiq
With the configuration in place, we can now spin up our services with `docker-compose up -d`. As always, make sure that all the services are up and running with `docker-compose ps`.

If everything looks good, let's keep an eye on the Sidekiq logs with:
```
docker-compose logs -f sidekiq
```

Add some todos and mark them as complete. You should see that jobs are being processed in the Sidekiq logs.


# What changed
You can find our changes in the [`sidekiq`](https://github.com/jfahrer/dockerizing_rails/tree/sidekiq) branch. [Compare it](https://github.com/jfahrer/dockerizing_rails/compare/debugging...sidekiq) to the previous branch to see what changed.

[Back to the overview](../README.md#assignments)
