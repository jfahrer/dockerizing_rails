# Assignment 9 - Integrating Sidekiq
With our Rails application dockerized and the `docker-compose.yml` in place, adding additional services and features becomes a breeze. To demonstrate how we would do this, we are going to start processing background jobs using `Sidekiq`. The `sidekiq` gem is already in our `Gemfile`.


## Setting up Sidekiq
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
      - SIDEKIQ_ENABLED=true
      - RAILS_ENV
```

* Enable background job processing and configure the Redis connection for our `app` service by adding the following environment variables:
```
      - REDIS_HOST=redis
      - SIDEKIQ_ENABLED=true
```

The environment variable `REDIS_HOST` configures our Redis connection for Sidekiq. And with `SIDEKIQ_ENABLED` we tell our application to actually make use of Sidekiq and enqueue jobs. This environment variable is used within the application code to enable/disable Sidekiq.

Check out the `_examples/docker-compose.yml.with_sidekiq` for a complete example.


## Running Sidekiq
With the configuration in place, we can now spin up our services with `docker-compose up -d`. As always, make sure that all the services are up and running with `docker-compose ps`.

If everything looks good, let's keep an eye on the Sidekiq logs with:
```
docker-compose logs -f sidekiq
```

Browse http://localhost:3000 - you should see a new dashboard showing up. Whenever we add a record to the database a Sidekiq job is enqueued that updates the dashboard. Try logging some progress for a few books and keep an eye on the Sidekiq logs. You will see that jobs are being picked up and run.


[Back to the overview](../README.md#assignments)
