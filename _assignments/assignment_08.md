# Assignment 8 - Iterating
Rebuilding the image every time we make changes is tedious and slows us down in our development workflow. But Docker wouldn't be Docker if we couldn't work around this problem. The solution here are so called bind mounts. A bind-mount allows us to mount a local file or directory into the containers file system. For the Docker CLI, we can specify the bind-mount using the `-v` flag. With Docker Compose, we simply add the definition the `docker-compose.yml` via the `volumes` directive. Here is an example:

```yaml
  app:
    image: your_docker_id/rails_app:v1
    build:
      context: .
    environment:
      - POSTGRES_HOST=pg
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - RAILS_ENV
    volumes:
      - ./:/usr/src/app:cached
    ports:
      - 127.0.0.1:3000:3000
```

The key part here is the `volumes` definition:
```yaml
    volumes:
      - ./:/usr/src/app:cached
```

We instruct Docker Compose to mount the current local working directory (`./`) to the `/usr/src/app` directory in the container. The `/usr/src/app` directory in the image contains a copy of our source code. We essentially just "replace" the content with what is currently on our local file system.

__*Side note*__: The `cached` options will [increase the performance](https://docs.docker.com/docker-for-mac/osxfs-caching/) of the bind-mount on MacOS. Unlike on Linux, there is some overhead when using bind-mounts on MacOS. Remember, Linux containers need to run on Linux and Docker will setup a virtual machine running Linux on your Mac. Getting the data from your Mac into the virtual machine requires a shared file system called [`osxfs`](https://docs.docker.com/docker-for-mac/osxfs/). There are significant overheads to guaranteeing perfect consistency and the `cached` options looses up the those guarantees. We don't require perfect consistency for our use case: Mounting our source code into the container.

In addition to the bind mount we will also add a volume for our `tmp/` directory. This is not strictly required but recommended for the following reasons:
* On MacOS a volume will be a lot faster than a bind-mount. Since we Rails will read and write temporary and cache data to `tmp/` we want to give ourselves maximum speed.
* We don't usually access anything in the `tmp/` directory locally, so there is no reason to write the data back to our Docker Host.
* [Bootsnap](https://github.com/Shopify/bootsnap) doesn't seem to [play nice](https://github.com/Shopify/bootsnap/issues/177) with the `cached` option and using a dedicated volume solves this problem for us.

In our `app` service definition we will mount a volume to `/usr/src/app/tmp`:
```yaml
    volumes:
      - ./:/usr/src/app:cached
      - tmp:/usr/src/app/tmp
```

Since we are using a named volume we also have to add it to the `volumes` section at the bottom of our `docker-compose.yml`:
```yaml
volumes:
  pg-data:
  tmp:
```

There is one more change we have to make to our `Dockerfile`. Since every container has its own process tree by default, the Rails server will always be PID 1. Puma, our Web Server, stores a PID-file in `tmp/`. This leads to issues when we restart our container: Puma will see the PID file and because there is already a process with the PID 1 (Puma itself), Puma will refuse to start and exit. We can work around this issue by appending the `--pid=/tmp/server.pid` flag to `rails server`. In order to do that we will change the `CMD` instruction in the `Dockerfile` like so:

```Dockerfile
CMD ["rails", "server", "-b", "0.0.0.0", "--pid=/tmp/server.pid"]
```


Check out `_examples/docker-compose.yml.with_bind_mount` and `_examples/Dockerfile.with_server_pid` for a complete examples.


We can now restart our containers with:
```
docker-compose up -d
```

Docker Compose will pick up our changes and re-create the container for our `app` service and create the new `tmp` volume. Make sure that everything is running with `docker-compose ps` and use `docker-compose logs` to troubleshoot any issues.

With the bind mount in place, we can start iterating on our application. Here are a few things you can try:
* Make some changes to `app/views/todos/index.html.erb` or `app/views/todos/_form.html.erb`. You can for example change a copy or the class of a submit button (try `btn-secondary` instead of `btn-primary`)
* Create a new model using the Rails generators
* Add a `presence` validation to `app/models/activity.rb` for the `data` field.

You should see the changes being reflected in the already running containers without the need to rebuild or restart anything.

# What changed
You can find our changes in the [`integrating_postgres`](https://github.com/jfahrer/dockerizing_rails/tree/iterating) branch. [Compare it](https://github.com/jfahrer/dockerizing_rails/compare/glueing_things_together...iterating) to the previous branch to see what changed.

[Back to the overview](../README.md#assignments)
