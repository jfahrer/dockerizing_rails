# Assignment 10 - Integrating Spring

Utilizing the power of Spring and pre-loading your application also works in Dockerland. Just like we did with Sidekiq, we will add another service to separate the concerns of our containers. We will run one service for Rails Server and another one for Spring. I tend to use the service name `app` for and `web` for the Rails Server:

```
  app:
    image: your_docker_id/rails_app:v1
    build:
      context: .
    command: ["spring", "server"]
    volumes:
      - ./:/usr/src/app
    environment:
      - POSTGRES_HOST=pg
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - REDIS_HOST=redis
      - SIDEKIQ_ENABLED=true
      - RAILS_ENV

  web:
    image: your_docker_id/rails_app:v1
    command: ["rails", "server", "--pid=/tmp/server.pid"]
    volumes:
      - ./:/usr/src/app
    environment:
      - POSTGRES_HOST=pg
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - REDIS_HOST=redis
      - SIDEKIQ_ENABLED=true
      - RAILS_ENV
    ports:
      - 3000:3000
```

We also have to make sure that our springified binstubs are in our path by adding the following line to our Dockerfile right before the `CMD` instruction:

```
ENV PATH=./bin:$PATH
```

Rebuild the image and restart your services:
```
docker-compose build app
docker-compose up -d
```

*__Side note__*: Run the command a second time if you get an error - depending on the order in which things happen the app container might still be holding port 3000 open.

You can now use `docker-compose exec` to send arbitrary shell commands to a running Container of the `app` service:
```
docker-compose exec app rspec
docker-compose exec app rake db:migrate
docker-compose exec app rails console
```

Instead of spinning up a brand new container for every command, we utilize and already existing container that runs Spring!

The web ui will be made available via the `web` service. So if you want to read the logs run:
```
docker-compose logs --tail 25 -f web
```

[Back to the overview](../README.md#assignments)
