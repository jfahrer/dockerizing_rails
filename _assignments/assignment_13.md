# Assignment 13 - Scripts To Rule Them All

The [Scripts To Rule Them All](https://github.com/github/scripts-to-rule-them-all) pattern comes from GitHub. It is a set of scripts with normalized names that can be used to get a project up and running in a repeatable and reliable fashion.

The purpose of the assignment is to demonstrate that Docker allows us to easily write scripts that get our environment into a working state. The exact usage and naming of the scripts is ultimately up to you. Coming up with a standard and sticking to it has the advantage that we don't have to look into the README when we switch between projects.

I already prepared a set of scripts for us. You can copy them from `_examples/script`:
```
cp -rp _examples/script ./script
```

We won't go into the inner mechanics of the scripts. They are all pretty straight forward shell scripts that execute `docker` and `docker-compose`. Instead, let's talk about what each script is intended to do:
* `script/bootstrap`: Prepares the runtime environment for the application. This entails building the image and install gems and node modules.
* `script/update` is responsible for updating the dependencies of the application. The script makes sure that Redis and Postgres are up and running, migrates the database, and updates the node modules and gems by calling `bootstrap`.
* `script/setup` is responsible for setting up the whole environment. It should be called after the initial clone or when a full reset of the environment is required. `setup` calls `update`.
* `script/test` will start all services and run the est suite of the application. `test` calls `update` unless the environment variable `FAST` is set.
* `script/server` will start all services and tail the logs of the Rails server and Sidekiq. `server` calls `update` unless the environment variable `FAST` is set.
* `script/console` will start all services and open a Rails console. `console` calls `update` unless the environment variable `FAST` is set.

Whoever needs to work on this project just needs to have **bash and Docker** installed, clone the repository and execute `script/setup`. Since the scripts only execute commands in containers, we know that they **will yield the expected results**! The same pattern can be utilized for other dockerized and non-dockerized applications as well. The great thing is that a developer don't have to understand the inner mechanics of the application to interact with it. They just have to know which script to execute based on what we are trying to achieve.

One tricky thing, when it comes to fully automating the setup of an application, is dealing with external dependencies. They might not being ready to use when you need them. For example it might take Postgres a while to boot. Since we want to script the setup of our application, we need to add steps to make sure our external dependencies are up and running before we use them.

Our set scripts solve this by using a tool called `pg_isready` that is shipped with Postgres. It can be used to determine if Postgres server is up and running. Since we don't want to introduce additional dependencies besides bash and Docker, we are going to run `pg_isready` in container. To do so, we have to install it in our Docker image. Go ahead and add `postgresql-client` to the list of packages that we install with `apk add`:
```
RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev \
      postgresql-client \
      yarn
```
You can find a complete example in `_examples/Dockerfile.with_postgres_client`.

To make calling `pg_isready` easier, we are going to wrap it in another script. We are going to call it `wait-for-postgres` and place it in `bin/`. I already prepared the script and you can just copy it:
```
cp -rp _examples/wait-for-postgres ./bin
```

__*Side note*__: We place the `wait-for-postgres` script in `bin/` because it is intended to be executed within the application context. That means we make it part of the application and run it in containers. Everything in `script/` is not part of the actual application. Those are helpers that we use to interact with our application. Everything in `script/` is intended to be run on the Docker Host.

The script uses the `POSTGRES_HOST` environment variable that we pass to the our containers to connect to Postgres. `pg_isready` will yield a unsuccessful exit code if it can't connect to Postgres. The script simply executes `pg_isready` until it returns successful.

Within our Scripts To Rule them All, `wait-for-postgres` is used like this:
```
docker-compose run --rm app bin/wait-for-postgres
```

Go ahead and try the scripts!

# What changed
You can find our changes in the [`scripts_to_rule_them_all`](https://github.com/jfahrer/dockerizing_rails/tree/scripts_to_rule_them_all) branch. [Compare it](https://github.com/jfahrer/dockerizing_rails/compare/spring...scripts_to_rule_them_all) to the previous branch to see what changed.

[Back to the overview](../README.md#assignments)
