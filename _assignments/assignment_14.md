# Assignment 13 - A seamless experience

## Customizing your experience
You might have realized that the `rails console` is not preserving our history. On your local system you might also use an `.irbrc`, shell customizations or other rc-files to enrich your development experience. These are all things that are currently missing in our containers. Not an issue tho - we can simply bind mount our rc-files into our containers!

```
    volumes:
      - ./.irbrc:/root/.irbrc
```

The `.irbrc` might look something like this:
```
require 'irb/completion'
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "/usr/src/app/.irb-history"
```

And we can use environment variables in our `docker-compose.yml` to change the behaviour of containers as well. For example we can set the history file used by `bash` using the `HISTFILE` environment variable:

```
HISTFILE=/usr/src/app/.bash_history
```

> **Note**: You might want to add `.bash_history` and `.irb_history` to your `.gitignore`.

> **Note**: The rc-files don't have the live in the repo - you can place them anywhere on your file system. You can even use [environment variables](https://docs.docker.com/compose/environment-variables/) within the `docker-compose.yml` to reference them. For example `${HOME}/.irbrc:/root/.irbrc`.


## Streamlining the execution of commands
When it comes to developing applications with Docker and Compose, we often have to make a few choice before running a command. Should we use `exec` or `run`? And which service do we have to specify for the command at hand? Here are a few examples:
* `docker-compose exec --rm app rspec`: We run the test suite using `exec` because we want to utilize Spring running provided the bye `app` service.
* `docker-compose run --rm bundle`: We install gems using `run` because missing gems might prevent our application from starting and `exec` won't work.
* `docker-compose exec pg psql -U postgres`: We use `exec` to start a `psql` session for our Postgres Database. We want to use `exec` here because Postgres has to be running in order to connect to it. It also allows us to omit the hostname of the database server since Postgres is running on "localhost" in the context of the `pg` service.
* `docker-compose exec redis redis-cli`: We use `exec` to connect to Redis via the `redis-cli`. We have to use the `redis` service here because our other containers won't have `redis-cli` installed. Using `exec` instead of `run` allows us to omit the hostname and connect to "localhost" in the context of the `redis` service.

This list is neither complete nor will it be identical across projects. This is where [Donner](https://github.com/codetales/donner) is helpful. Donner allows you to define how to execute given commands in a simple yaml-config. Instead of having to decide whether ot use `run` vs `exec` and which service to use, you can just execute
* `donner run rspec`
* `donner run bundle`
* `donner run psql -U postgres`
* `donner run redis-cli`

Donner will figure out how to execute the command for you based on the config.

Donner even allows you to set aliases for the specified commands. This way all you have to type is `rspec` or `psql -U postgres`!

Check out the [README](https://github.com/codetales/donner) and integrate Donner into your project if you are interested.


## Accelerating bind mounts on MacOS
If you are a MacOS user, you might notice that interacting with your applications seams slower compared to a version that runs locally. This is due to the overhead that comes with [`osxfs`](https://docs.docker.com/docker-for-mac/osxfs/), a shared file system that allows you to bind mount file and folders into Docker containers.

To work around this, we can use [Blitz](https://github.com/codetales/blitz), a zero dependency source code synchronizer for Docker for Mac. Instead of relying on `osxfs` and bind mounts to get your source code into your containers, Blitz synchronises files and folder from you Mac with a Doocker Volume. That means that your containers can access the files at native speed!

Check out the [README](https://github.com/codetales/blitz) and try setting it up if you are using MacOS.

# What changed
You can find our changes in the [`scripts_to_rule_them_all`](https://github.com/jfahrer/dockerizing_rails/tree/seamless) branch. [Compare it](https://github.com/jfahrer/dockerizing_rails/compare/scripts_to_rule_them_all...seamless_development) to the previous branch to see what changed.

[Back to the overview](../README.md#assignments)
