# Assignment 12 - Keeping things running with Spring

Utilizing the power of [Spring](https://github.com/rails/spring) and pre-loading your application also works in Dockerland and speed up our test runs. Just like we did with Sidekiq, we will add another service for Spring to separate the concerns into different containers. We will run one service for Rails Server, one for Sidekiq and another one for Spring. I tend to use the service name `app` for Spring for and `web` for the Rails Server.

```yaml
  app:
    image: your_docker_id/rails_app:v1
    build:
      context: .
    command: ["spring", "server"]
    environment:
      - POSTGRES_HOST=pg
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - REDIS_HOST=redis
      - RAILS_ENV
    volumes:
      - ./:/usr/src/app:cached
      - tmp:/usr/src/app/tmp
      - gems:/usr/local/bundle
      - node_modules:/usr/src/app/node_modules

  web:
    image: your_docker_id/rails_app:v1
    environment:
      - POSTGRES_HOST=pg
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - REDIS_HOST=redis
      - RAILS_ENV
    volumes:
      - ./:/usr/src/app:cached
      - tmp:/usr/src/app/tmp
      - gems:/usr/local/bundle
      - node_modules:/usr/src/app/node_modules
    ports:
      - 127.0.0.1:3000:3000
    tty: true
    stdin_open: true
```

We changed the `app` service to start Spring with `spring server` and we also removed the published ports. The new service `web` will take care of making the Rails server available to us. Since we use the same image for all three services, we only need to build it once. Hence only our `app` service has the `build` directive set.


We also have to make sure that our springified binstubs are in our path by adding the following line to our `Dockerfile` right before the `CMD` instruction:

```Dockerfile
ENV PATH=./bin:$PATH
```

This way we will automatically use `./bin/rails` and `./bin/rspec` if we execute `rails` or `rspec` inside a container. The same is true for the other binstubs in the `bin/` directory. The binstubs are setup to utilize Spring.

Check out `_examples/docker-compose.yml.with_spring` and `_examples/Dockerfile.with_spring` for complete examples.

Let's rebuild the image and restart your services:
```
docker-compose build app
docker-compose up -d
```

> **Note**: Run the command a second time if you get an error - depending on the order in which things happen the app container might still be holding port 3000 open.


Instead of using `docker-compose run` we can now use `docker-compose exec` and send arbitrary shell commands to a running container of the `app` service:
```
docker-compose exec app rspec
docker-compose exec rake db:migrate
docker-compose exec rails console
```

Unlike `docker-compose run`, `docker-compose exec` will not spin up a brand new container every time we execute the command. Instead the command is executed in an already running container. That means that the commands we send to the container can now benefit from Spring pre-loading the application.

Try restarting the `app` service with `docker-compose restart app` and running the test suite afterwards. The first time you run the test suite it will take a short while before rspec starts. If you run the test suite for a second time, rspec should start almost immediately thanks to Spring.


From here on, web ui will be made available via the `web` service. So if we now want to read the logs for the Rails server, we need to run:
```
docker-compose logs --tail 25 -f web
```

# What changed
You can find our changes in the [`spring`](https://github.com/jfahrer/dockerizing_rails/tree/spring) branch. [Compare it](https://github.com/jfahrer/dockerizing_rails/compare/webpacker...spring) to the previous branch to see what changed.

[Back to the overview](../README.md#assignments)
