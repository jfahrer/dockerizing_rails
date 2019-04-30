# Assignment 5 - integrating Postgres
Before we start, let's clean up. Make sure to stop all containers and _optionally_ delete them. Either use `docker container ls -a` and `docker container rm` OR `docker container prune` (*if you don't care about any of the containers on your system*)

## Configuring the application
Currently, our Rails app is using SQLite as a DBMS. We're going to switch to PostgresSQL and need to update our `database.yml`. An updated `database.yml` can be found in the `config` directory
```
cp config/database.yml.postgres config/database.yml
```

Make sure to take a look at the updated `database.yml`. As you can see, we are utilizing environment variables to configure our connection to PostgreSQL.

Since we made changes to the source code of our application, __we need to rebuild the image__:
```
docker image build -t your_docker_id/rails_app:v1 .
```

## Running Postgres
Now we can start our Postgres instance:
```
docker container run --name pg -d \
  -v ws-pg-data:/var/lib/postgresql/data \
  -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=secret postgres:10.6-alpine
```

Let's dig a little into the flags we used to start the container:
* The `--name` flag gives our container a name. This way we can easily start/stop it and reference it from other containers.
* `-d` starts the container in `detatched` mode. That means we won't be attached to `STDOUT` of the container. Try playing around `docker container attach` and `docker container logs` to see what is going on. Don't forget the `--help` flag if you want to find out more about those commands
* With `-v ws-pg-data:/var/lib/postgresql/data`, we make sure that the data that Postgres writes to disk is persisted outside of the container. Docker will create a volume named `ws-pg-data` and mount it into the container.
* `-e` allows us to pass in environment variables that will be available to our container. We use this flag to configure the credentials for Postgres.

Make sure that the container is up and running by running the `docker container ls` command. You should see a container with the name `pg` in the output:
```
$ docker container ls
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                              NAMES
66bbf21aedc0        postgres:10.6-alpine   "docker-entrypoint.s…"   17 seconds ago      Up 16 seconds       5432/tcp                           pg
```


### Talking to the service
Now that we have our Postgres container up and running, we need to start our Rails application. We already built the new image with the correct `database.yml` in place. If you take a quick look at the `database.yml`, you will see that we set the connection information via environment variables. We need to pass the correct environment variables to our `docker container run` command using the `-e` flag:
```
docker container run -it -p 3000:3000 --link pg \
  -e POSTGRES_HOST=pg -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=secret \
  your_docker_id/rails_app:v1 rails s
```

The environment variables that we pass in are used to configure the connection to our Postgres database. These environment variables are read in out `database.yml`.

You might also have spotted the `--link` flag in our command. This flag allows us to talk to our Postgres container by its name `pg`. 

__*Side note*__: `--link` is deprecated and we will learn about a better mechanism later in the workshop. However, it is the easiest way to get the app up and running for now.

If you open your browser and go to http://localhost:3000, you will see that we need to migrate our database. So let's do that in another container (in another shell):
```
docker container run -it --link pg \
  -e POSTGRES_HOST=pg -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=secret \
  your_docker_id/rails_app:v1 rake db:create db:migrate db:test:prepare
```

With the database schema in place you should be able to to interact with our application through the web interface.

Feel free to terminate your Rails and Postgres containers and restart them. Your data will still be there!

Let's start by stopping Postgres
```
docker container stop pg
docker container rm pg
```

The volume `ws-pg-data` will still be there. You can verify this via:
```
docker volume ls
```

### Bonus
* Try to run the test suite with the Postgres connection in place.
* Start a Rails console in a second container and create some records. They should show up in the Web UI.

## Troubleshooting
Things are going wrong? Let's make them work! Here are a couple of things to try
* Make sure you copied the database.yml AND rebuild the image?
* Remove the Postgres container and volume:
  ```
  docker container rm -f pg
  docker voume rm ws-pg-data
  ```

  And then try it again

* Check the logs for the Postgres container
  ```
  docker container logs pg
  ```

* Check if the expected containers are up and running
  ```
  docker container ls -a
  docker volume ls
  ```

* Delete all the containers and volumes and start over (__be careful__ - this will do exactly that):
  ```
  docker container ls -a | xargs docker container rm
  docker volume ls | xargs docker volume rm
  ```

[Back to the overview](../README.md#assignments)
