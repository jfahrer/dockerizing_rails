# Assignment 8 - Iterating
Rebuilding the image every time we make changes is tedious and slows us down in our development workflow. But Docker wouldn't be Docker if we couldn't work around this problem. The solution here are so called bind mounts. A bind mount allows us to mount a local file or directory into the containers file system. When using the Docker CLI, you can specify the bind mount using the `-v` flag. With Docker Compose, we simply add the definition the `docker-compose.yml` via the `volumes` directive. The resulting service definition will look like this:

```
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
      - 3000:3000
```

There is one more change we have to make to our Dockerfile. Since every container has its own process tree by default, the Rails server will always be PID 1. Puma, our Web Server, stores a PID-file in `tmp/`. This leads to issues when we restart our container: Puma will see the PID file and because there is already a process with the PID 1 (Puma itself), Puma will refuse to start and exit. We can work around this issue by appending the `--pid=/tmp/server.pid` flag to `rails server`. In order to do that we will the `CMD` instruction in the Dockerfile like so:

```
CMD ["rails", "server", "-b", "0.0.0.0", "--pid=/tmp/server.pid"]
```

TODO Check out `_examples/docker-compose.yml.with_bind_mount` for a complete example. We can restart our containers with


```
docker-compose up -d
```

Docker Compose will pick up our changes and re-create the container for our `app` service. Make sure that everything is running with `docker-compose ps` and use `docker-compose logs` to troubleshoot any issues.

With the bind mount in place, we can start iterating on our application. Here are a few things you can try:
TODO * Fix the failing spec in the `ProgressUpdateJob` (`spec/jobs/progress_update_job_spec.rb`)
TODO * Change some of the text in `app/views/books/`
TODO * Create a new model using the Rails generators
TODO * Change one of the validations on books

[Back to the overview](../README.md#assignments)
