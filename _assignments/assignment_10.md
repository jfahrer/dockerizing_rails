# Assignment 10 - Integrating Sidekiq
With our Rails application dockerized and the `docker-compose.yml` in place, adding additional services and features becomes a breeze. To demonstrate how we would do this, we are going to start processing background jobs using `Sidekiq`.

TODO: What are we trying to achieve


## Adding the Gem
As we would do with a non-dockerized application, we start by adding the Sidekiq gem to our `Gemfile`:

```
gem "sidekiq", "~> 5.2.7"
```

And then run `bundle`:
```
docker-compose run --rm app bundle
```

Here things can become a little confusing. So far we installed the Sidekiq gem and its dependencies in a one-off container. That means that the gems will be missing from all other containers that we will start in the future. To make sure that all future containers will have the Gem installed, we have to rebuild the image:
```
docker-compose build app
```

However, running `docker-compose run --rm app bundle` **is a mandatory step**. We need to run `bundle` outside of the image build process to get an updated `Gemfile.lock` locally.

TODO: Add content for gem volumes here

## Setting up Sidekiq
```
redis_url = "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}/:#{ENV.fetch('REDIS_PORT', '6379')}/#{ENV.fetch('REDIS_DB', '0')}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
```

TODO: We also need to make sure that everything works fine with our tests.
```ruby
require 'sidekiq/testing'
```

## Adding the service
All we have to do is:
* Add a service to our `docker-compose.yml` to run Redis:
```
  redis:
    image: redis:5.0
```

* Add a service to our `docker-compose.yml` to run Sidekiq:
```
  sidekiq:
    image: your_docker_id/rails_app:v1
    build:
      context: .
    command: ["sidekiq"]
    volumes:
      - ./:/usr/src/app
    environment:
      - POSTGRES_HOST=pg
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - REDIS_HOST=redis
      - RAILS_ENV
```

* Enable background job processing and configure the Redis connection for our `app` service by adding the following environment variable:
```
      - REDIS_HOST=redis
```

TODO Check out the `_examples/docker-compose.yml.with_sidekiq` for a complete example.

The environment variable `REDIS_HOST` configures our Redis connection for Sidekiq. We will make use of it in the initializer for Sidekiq. Let's create a `config/initializers/sidekiq.rb` file with the following content:

TODO: Why we don't use REDIS_PORT/DB -> good practice to add it anyways


## Creating the job
Now we have to write the code for the actual job. It will simply call `ScoreCalculator.call`.

So let's create `app/jobs/score_generation_job.rb`:
```ruby
class ScoreGenerationJob
  include Sidekiq::Worker

  def perform(date)
    ScoreCalculator.call(date)
  end
end
```


## Running Sidekiq
With the configuration in place, we can now spin up our services with `docker-compose up -d`. As always, make sure that all the services are up and running with `docker-compose ps`.

If everything looks good, let's keep an eye on the Sidekiq logs with:
```
docker-compose logs -f sidekiq
```

[Back to the overview](../README.md#assignments)
