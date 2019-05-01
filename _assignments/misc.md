# Misc
This is a collection of various tasks (WIP)

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


## Creating a setup script

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

