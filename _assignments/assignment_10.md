# Assignment 10
This is a collection of various tasks

## Running Spring
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

  web
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

Restart your services:
```
docker-compose up -d
```

You can now use `docker-compose exec` to send arbitrary shell commands to a running Container of the `app` service:
```
docker-compose exec app rspec
docker-compose exec rake db:migrate
docker-compose exec rails console
```

Instead of spinning up a brand new container for every command, we utilize and already existing container that runs Spring!

The web ui will be made available via the `web` service. So if you want to read the logs run:
```
docker-compose logs --tail 25 -f web
```

## Extracting environment variables
Now that we have three different services using mostly the same environment variables, it is a good time to go ahead and extract the environment variables into files that we can reference.

Create the file `env/app.env`:
```
TODO
```

Create the file `env/db_credentials.env`:
```
TODO
```

You can now reference the files containing the environment variables as follow:
```
TODO
```

The resulting `docker-compose.yml` can be found in `_examples/docker-compose.yml.with_env_extraxted`. Feel free to copy it:
```
mv docker-compose.yml docker-compose.yml.backup
cp _examples/docker-compose.yml.with_env_extraxted docker-compose.yml
```


## pry / irb history
Keeping the history for the Rails console can be useful when we want you are like me and try to replay commands. Currently the history is stored in the Container file-system and will be deleted when we delete or re-create our containers.

We can get around this by storing the history file locally on our system using a bind mount:
```
services:
  app:
    # -- SNIP --
    volumes:
      - ./:/usr/src/app
      - ${HOME}/.irb-save-history:/root/.irb-save-history
```

I'm using the default path for the irb history here, but you can mount any file into the corresponding path into the container and by that keep a separate history per project.

Using pry on your project? Mount `${HOME}/.pry_history` instead

Wondering about the environment variable in the compose file? It's a thing: https://docs.docker.com/compose/environment-variables/

## Making Postgres faster
With Postgres running in a container, we can easily influence its behavior on a per project basis. We can for example turn `fsync` off to get more performance in development/tests. All we have to do is setting the `command` for the `pg` container to `-c fsync=off`:

```
TODO
```

And then recreate the service:
```
docker-compose up -d`
```

Docker Compose will see that the service definition has changed and recreate the `pg` service for you.


## Run migrations on startup
* When we run migrations automatically, we need to ensure that Postgres is already running. The `wait-for-pg` utility is your friend.
* Use the `ENTRYPOINT` instruction and define a shell script that will automatically run the migrations if the `MIGRATE` environment variable is true


## Keeping gems locally
We made sure that we don't have to re-install all gems when we make changes to our source code. However, with every change to the `Gemfile`/`Gemfile.lock` we have to re-install all gems again - and waiting for nokogiri to compile can get pretty annoying. It also means that if you switching between branches that use different gems or gem versions, you get stuck in this loop of re-building your Docker Image.

There are some workarounds for this - let's look at one that helps while developing: Caching gems locally

All we have to do is mount a volume to `/usr/local/bundle`:
```
services:
  app:
    # -- SNIP --
    volumes:
      - ./:/usr/src/app
      - ${HOME}/.irb-save-history:/root/.irb-save-history
      - gems:/usr/local/bundle
```

When the volume is first created, the content of `/usr/local/bundle` of the Container Image is copied into the volume. After that - it will get stale and we have to manually update the gems. That means after making changes to the Gemfile, we have to run bundle:
```
docker-compose run --rm app bundle
```

The nice thing here is that the volume will contain all the gems that we install over time. So playing around with a new version or switching between branches will be seamless.
