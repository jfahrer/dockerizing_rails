# Dockerizing Rails - A supercharged development process

## Getting started
Please make sure to install
* Docker - https://hub.docker.com/search?q=&type=edition&offering=community
* Git - https://git-scm.com/downloads

Make sure to create a Docker ID if you don't have one already: https://hub.docker.com/signup

Clone this repository so that we can iterate on it later in the workshop:
```
git clone https://github.com/jfahrer/dockerizing_rails
```

### Testing your Docker installation
Run the following command on you system:
```
docker version
```

The output of the command should look similar to this:
```
Client: Docker Engine - Community
 Version:           18.09.2
 API version:       1.39
 Go version:        go1.10.8
 Git commit:        6247962
 Built:             Sun Feb 10 04:12:39 2019
 OS/Arch:           darwin/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.2
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.6
  Git commit:       6247962
  Built:            Sun Feb 10 04:13:06 2019
  OS/Arch:          linux/amd64
  Experimental:     true
```

The important parts here are
* `Version` for the `Client` and `Server` should be `18.09.2` or higher
  Please update your Docker installation if you are on an older version.
* Under `Server: Docker Engine - Community` make sure that the  `OS/Arch` says `linux/amd64`.
  If you are seeing `Windows` in there, please make sure to switch you Docker installation to run Linux: https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers

### Verifying Docker Compose version
Run the following command on you system:
```
docker-compose -v
```

The output of the command should look similar to this:
```
docker-compose version 1.23.2, build 1110ad01
```

If you are running an older Version of Docker Compose or you are getting a `command not found`, please follow the installation instructions for Docker Compose: https://docs.docker.com/compose/install/


### Pre-loading images
To save time and bandwidth throughout the workshop, I recommend that you download the container "images" that we will use beforehand. Don't worry if you don't know what an image is yet - we will go over that in the workshop. All you have to do is execute the following commands:

```
docker image pull ubuntu:18.04
docker image pull jfahrer/ruby:2.5.5-alpine3.9-railsconf
docker image pull redis:4.0
docker image pull postgres:10.6-alpine
```

The output will look similar to this:
```
2.5.5-alpine3.9-railsconf: Pulling from jfahrer/ruby
bdf0201b3a05: Pull complete
67a4a175230f: Pull complete
5b688ca58800: Pull complete
68bfb7317906: Pull complete
e95e2e8e402a: Pull complete
5e7827d9c7e8: Pull complete
4507d0429dd7: Pull complete
7cba2dc1349a: Pull complete
61e576b94017: Pull complete
951629f33eb5: Pull complete
Digest: sha256:b1a4210e93b94e5a09a6e9c8f44c8f0a2aef03c520d6268faa20261c55d6d2b7
Status: Downloaded newer image for jfahrer/ruby:2.5.5-alpine3.9-railsconf
```

# Assignments
Throughout the workshop you will complete the following assignments:

* [Assignment 1 - Hello World](_assignments/assignment_01.md)
* [Assignment 2 - Your first image](_assignments/assignment_02.md)
* [Assignment 3 - Running Rails](_assignments/assignment_03.md)
* [Assignment 4 - Talking to a service](_assignments/assignment_04.md)
* [Assignment 5 - Integrating Postgres](_assignments/assignment_05.md)
* [Assignment 6 - Utilizing layers](_assignments/assignment_06.md)
* [Assignment 7 - Glueing things together](_assignments/assignment_07.md)
* [Assignment 8 - Iterating](_assignments/assignment_08.md)
* [Assignment 9 - Integrating Sidekiq](_assignments/assignment_09.md)


# Learning more
* https://LearnDocker.online
* https://RailsWithDocker.com
* https://docs.docker.com
