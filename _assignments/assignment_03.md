# Assignment 3 - Running Rails

For this and the remaining assignments, we will work with the demo application that is part of this repository. Make sure to __*change into the directory that you cloned this repository into*__ (see [here](../README.md#getting-started)). 

## The Dockerfile
Just as before, we will create a `Dockerfile` **inside the demo applications directory**:

```Dockerfile
FROM jfahrer/ruby:2.5.5-alpine3.9-railsconf

RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev

RUN gem install bundler:2.0.1

WORKDIR /usr/src/app

COPY . .

RUN bundle install

CMD ["rails", "console"]
```

For convenience, I already put a `.dockerignore` file in place. Similar to a `.gitignore` file, the files and directories listed in the `.dockerignore` file will be ignored when copying data into the container image. Feel free to open the `.dockerignore` file and take a look.

With the `Dockerfile` in place we can go ahead and build the image:
```
docker image build -t your_docker_id/rails_app:v1 .
```

Once the command completed successfully, we should be able to start a rails console in a container:
```
docker container run -it your_docker_id/rails_app:v1
```

Feel free to play around with the Rails environment for a bit. You should for example be able to create some records in the database:
```
Book.create!(title: "Rails With Docker", pages: 312)
```

Press `Ctrl-D` to quit the rails console and terminate the container.

__*Side note*__: Wondering why you didn't have to create/migrate the database? The data is currently stored in SQLite database which is part of this repository and hence part of the container image as well.


## Running the tests
As we've seen before, we can run arbitrary commands in the context of the container image by appending the command after the image name. We can use this technique to execute the test suite using `rspec`:
```
docker container run -it your_docker_id/rails_app:v1 rspec
```

You will see that __one of the tests will fail__ - that is OK and expected! You will get the time to fix the failing test later in the workshop.

__*Side note:*__ We don't need the `-it` flags here because we don't run an interactive program like the Rails console. However, we will only see the colors in the output with the `-t` flag. As there is no harm in adding those flags, we will keep doing this from there on even if we start non-interactive programs.

## Finding out what is going on
The Docker CLI is pretty straight forward. To get more information about what is possible, try just typing `docker`.
You will see a list of `Commands` and `Management Commands`. To get more information about a command, just append `--help`. For example
```
docker container run --help
```

Here are a few useful commands that you should try out before moving on to the next exercise.
```
docker container ls  # List all running containers
docker container ls -a  # List all containers - running or not
docker container rm <id/name> # Delete a container. Use the `-f` flag to delete a running container
docker container stop # Stop a running container
docker container kill # Kill a running container
```

Go ahead an try them out! It might make sense to use a second terminal to run the `stop` / `kill` / `ls` / `rm` commands while you keep a container running in the other terminal.

## Cleaning up
Now that we are done, it is time to clean up a little bit.

If you care about any of the containers on your system, delete just the ones you don't need using `docker container ls -a` and `docker container rm`.

If you never used Docker before or don't care about any of the containers on your system, you can run:

```
docker container prune
```

*__!!Attention!!__* This will delete all stopped containers on your system.

[Back to the overview](../README.md#assignments)
