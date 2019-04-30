# Assignment 8 - Iterating
Rebuilding the image every time we make changes is tedious and slows us down in our development workflow. But Docker wouldn't be Docker if we couldn't work around this problem. The solution here are so called bind-mounts. A bind mount allows us to mount a local file or directory into the containers file system. When using the Docker CLI, you can specify the bind-mount using the `-v` flag. With Docker Compose, we simply add the definition the `docker-compose.yml` via the `volumes` directive. The resulting service definition will look like this:

```
  app:
    image: your_docker_id/rails_app:v1
    build:
      context: .
    command: ["rails", "server", "--pid=/tmp/server.pid"]
    environment:
      - POSTGRES_HOST=pg
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - RAILS_ENV
    volumes:
      - ./:/usr/src/app
    ports:
      - 3000:3000
```

Please also note the `--pid=/tmp/server.pid` argument that we appended to `rails server`. This makes sure that we don't share the pidfile between multiple containers by storing it outside of the project directory (and bind mount).

Check out `_examples/docker-compose.yml.with_bind_mount` for a complete example. We can restart our containers with


```
docker-compose up -d
```

Docker Compose will pick up our changes and re-create the container for our `app` service. Make sure that everything is running with `docker-compose ps` and use `docker-compose logs` to troubleshoot any issues.

With the bind-mount in place, we can start iterating on our application. Here are a few things you can try:
* Fix the failing spec in the `ProgressUpdateJob` (`spec/jobs/progress_update_job_spec.rb`)
* Change some of the text in `app/views/books/`
* Create a new model using the Rails generators
* Change one of the validations on books

[Back to the overview](../README.md#assignments)
