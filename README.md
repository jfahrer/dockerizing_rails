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
docker image pull ruby:2.5.5-alpine3.9
docker image pull redis:4.0
docker image pull postgres:10.6-alpine
docker image pull jfahrer/ruby:2.5.5-alpine3.9-railsconf
```

The output will look similar to this:
```
2.5.5-alpine3.9: Pulling from library/ruby
bdf0201b3a05: Pull complete
67a4a175230f: Pull complete
5b688ca58800: Pull complete
68bfb7317906: Downloading [==========>                                        ]  4.668MB/23.3MB
68bfb7317906: Pull complete
e95e2e8e402a: Pull complete
Digest: sha256:913a48f37398163b3f27b836d4db06fe867991ee3c871d26ed38fd51f6f646e0
Status: Downloaded newer image for ruby:2.5.5-alpine3.9
```

# Assignments
Throughout the workshop we will complete various assignments. This section will contain a list with links to the individual assignments.
