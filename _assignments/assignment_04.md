# Assignment 4 - Talking to a service
In order to be able to interact with our Rails application over http, we need to publish port `3000`. The following command should do the trick:
```
docker container run -it -p 3000:3000 your_docker_id/rails_app:v1 rails s -b 0.0.0.0
```

As we've seen in prior assignments, we just have to append the command (`rails s`) after the image name. The `-p 3000:3000` flag makes sure that traffic that is received by the Docker Host on port 3000 is forwarded to the container on port 3000.

Open the browser and try to navigate to http://localhost:3000. You should see the Web UI of our demo application.

Back on you command line you should see the output of the Rails server.

Go ahead and try to create a few books via the web interface.

Once you are done, you can terminate Rails and the container by pressing `Ctrl-C`.

__*Side note*__: Accessing a service inside a container will NOT work of the service only listens on `localhost`. In other words, you have to make sure that the service listens on the outwards facing ethernet interfaces of the container. We told our Rails application to listen on `0.0.0.0` which is an alias for all interfaces.

__*Side note*__: When using `-p 3000:3000` you instruct Docker to listen on all interfaces on your local machine. That means that your rails service will be accessible from other machines. Not what you want? Try `-p 127.0.0.1:3000:3000` instead to only listen on `localhost`.

## Enhancing the Dockerfile
Let's make some changes to our Dockerfile to make our life a little easier and safe us some typing. **Before we get started, make sure to terminate any running containers**.

Here is the updated version of the Dockerfile:
```
FROM jfahrer/ruby:2.6.3-alpine3.10-ser

RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev

RUN gem install bundler:2.0.2

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

New here is the `EXPOSE` instructions. `EXPOSE` adds metadata to the image that tells Docker that the service provided by this image will listen on port 3000. This is not required, but it allows other users to properly run the container and publish the correct port.

We also changed the `CMD` instruction. The `rails server` with the required arguments is not the defeault command that will be executed when a container based on the image starts.

With the changes in place, we have to rebuild our image:
```
docker image build -t your_docker_id/rails_app:v1 .
```

Now we can start a container without specifying that we want to run `rails server`:
```
docker container run -it -p 3000:3000 your_docker_id/rails_app:v1
```

## Things to try
* What will happen if you try to start a second container while the first one is still running?
* Stop the current container by pressing `Ctrl-C`. Then start a new container with the same command. Is the data still there?
* Try to figure out how to revive the old container that you stopped earlier. `docker container --help` is your friend. Do you see the data again?

## Troubleshooting
If you receive an error message similar to this one:
```
docker: Error response from daemon: driver failed programming external connectivity on endpoint elastic_robinson (1e9b864796702b7909a3247a04809fe053885367b152d2385ce7ddeab364b6d5): Bind for 0.0.0.0:3000 failed: port is already allocated.
ERRO[0000] error waiting for container: context canceled
```
You are already running something on port 3000. Either stop the service that is bound to port 3000 or change the local port:
```
docker container run -it -p 3001:3000 your_docker_id/rails_app:v1 rails s -b 0.0.0.0
```

[Back to the overview](../README.md#assignments)
