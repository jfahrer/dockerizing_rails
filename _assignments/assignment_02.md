# Assignment 2 - Your first image
In this section, you will create your first container image. Please start by creating an empty directory and change into this directory
```
mkdir first_image
cd first_image
```

### Building the image
In this directory you will create the `Dockerfile` for your first image. Copy and paste the following content:
```
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y cowsay

CMD /usr/games/cowsay "Containers are awesome!"
```

Now, from within directory containing the `Dockerfile`, you can build the container image:
```
docker image build -t your_docker_id/cowsay:v1 .
```

The output of the command will look similar to this (note that you might not see the "Pulling from …" part if you followed the getting started part).:
```
Sending build context to Docker daemon  2.048kB
Step 1/3 : FROM ubuntu:18.04
18.04: Pulling from library/ubuntu
6cf436f81810: Pull complete
987088a85b96: Pull complete
b4624b3efe06: Pull complete
d42beb8ded59: Pull complete
Digest: sha256:7a47ccc3bbe8a451b500d2b53104868b46d60ee8f5b35a24b41a86077c650210
Status: Downloaded newer image for ubuntu:18.04
 ---> 47b19964fb50
Step 2/3 : RUN apt-get update && apt-get install -y cowsay
 ---> Running in 28d176829ae1
Get:1 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
Get:2 http://archive.ubuntu.com/ubuntu bionic InRelease [242 kB]
Get:3 http://security.ubuntu.com/ubuntu bionic-security/main amd64 Packages [339 kB]
Get:4 http://archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]
Get:5 http://archive.ubuntu.com/ubuntu bionic-backports InRelease [74.6 kB]
Get:6 http://archive.ubuntu.com/ubuntu bionic/universe amd64 Packages [11.3 MB]
Get:7 http://security.ubuntu.com/ubuntu bionic-security/multiverse amd64 Packages [3451 B]
Get:8 http://security.ubuntu.com/ubuntu bionic-security/universe amd64 Packages [147 kB]
Get:9 http://archive.ubuntu.com/ubuntu bionic/main amd64 Packages [1344 kB]
Get:10 http://archive.ubuntu.com/ubuntu bionic/restricted amd64 Packages [13.5 kB]
Get:11 http://archive.ubuntu.com/ubuntu bionic/multiverse amd64 Packages [186 kB]
Get:12 http://archive.ubuntu.com/ubuntu bionic-updates/multiverse amd64 Packages [6955 B]
Get:13 http://archive.ubuntu.com/ubuntu bionic-updates/restricted amd64 Packages [10.7 kB]
Get:14 http://archive.ubuntu.com/ubuntu bionic-updates/universe amd64 Packages [929 kB]
Get:15 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 Packages [679 kB]
Get:16 http://archive.ubuntu.com/ubuntu bionic-backports/universe amd64 Packages [4690 B]
Fetched 15.5 MB in 6s (2466 kB/s)
Reading package lists...
Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  libgdbm-compat4 libgdbm5 libperl5.26 libtext-charwidth-perl netbase perl
  perl-modules-5.26
Suggested packages:
  filters cowsay-off gdbm-l10n perl-doc libterm-readline-gnu-perl
  | libterm-readline-perl-perl make
The following NEW packages will be installed:
  cowsay libgdbm-compat4 libgdbm5 libperl5.26 libtext-charwidth-perl netbase
  perl perl-modules-5.26
0 upgraded, 8 newly installed, 0 to remove and 2 not upgraded.
Need to get 6563 kB of archives.
After this operation, 41.7 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 perl-modules-5.26 all 5.26.1-6ubuntu0.3 [2763 kB]
Get:2 http://archive.ubuntu.com/ubuntu bionic/main amd64 libgdbm5 amd64 1.14.1-6 [26.0 kB]
Get:3 http://archive.ubuntu.com/ubuntu bionic/main amd64 libgdbm-compat4 amd64 1.14.1-6 [6084 B]
Get:4 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 libperl5.26 amd64 5.26.1-6ubuntu0.3 [3527 kB]
[... SNIP ...]
Unpacking cowsay (3.03+dfsg2-4) ...
Setting up perl-modules-5.26 (5.26.1-6ubuntu0.3) ...
Setting up libgdbm5:amd64 (1.14.1-6) ...
Processing triggers for libc-bin (2.27-3ubuntu1) ...
Setting up libtext-charwidth-perl (0.04-7.1) ...
Setting up libgdbm-compat4:amd64 (1.14.1-6) ...
Setting up netbase (5.4) ...
Setting up libperl5.26:amd64 (5.26.1-6ubuntu0.3) ...
Setting up perl (5.26.1-6ubuntu0.3) ...
Setting up cowsay (3.03+dfsg2-4) ...
Processing triggers for libc-bin (2.27-3ubuntu1) ...
Removing intermediate container 28d176829ae1
 ---> c14904ec9828
Step 3/3 : CMD /usr/games/cowsay "Containers are awesome!"
 ---> Running in 487bea9e4c74
Removing intermediate container 487bea9e4c74
 ---> 760f3018b10b
Successfully built 760f3018b10b
Successfully tagged your_docker_id/cowsay:v1
```


After the build process finishes, you can verify that the build was successful and that image exists on your system:
```
docker image ls # to list all images
docker image ls your_docker_id/cowsay # to list images in the `your_docker_id/cowsay` repository
```

### Using the image
We can now run a container based on this image:
```
docker container run your_docker_id/cowsay:v1
```

You should see they cow saying `Containers are awesome!`:
```
 _________________________
< Containers are awesome! >
 -------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```


### Running other commands
Time to play around for a bit! We can execute arbitrary commands in a container - all we have to do is to __append the command after the image name__. For example:
```
docker container run your_docker_id/cowsay:v1 echo "Running the echo command in the cowsay image"
```

This will print `Running the echo command in the cowsay image`. The output was produced by the `echo` executable that is part of the `your_docker_id/cowsay:v1` image. In fact, we "inherited" this executable from the `ubuntu:18.04` image.

### Missing commands
The executable for whatever command we run in the container must be present in the container image. This means even with Ruby installed on our local system, __the following command will fail__:
```
docker container run your_docker_id/cowsay:v1 ruby -v
```

### Interactive programs
Let's try something else and start an interactive program like a shell in a container. We already know that we can specify which command we want to run in the container. However, for interactive applications like a shell, we have to specify the `-it` flags *before* the image name:
```
docker container run -it your_docker_id/cowsay:v1 bash
```

This command will open a shell prompt in a new container. Try it out - you will be able to navigate the containers file system and execute arbitrary commands as well. For example:
```
uname -a
ls -l /usr/bin
whoami
```

Once you are done, you can exit the shell and quit the container by pressing `Ctrl-D`

[Back to the overview](../README.md#assignments)
