# DOCKER-VERSION 1.2.0

FROM ubuntu:14.04

# unsure why this is necessary now, but this makes the build less noisy
ENV DEBIAN_FRONTEND noninteractive

# make sure apt is up to date
RUN apt-get update -qq

# install nodejs, npm, git
RUN apt-get install -qq nodejs npm git git-core curl

# set /usr/bin/node as a symlink to /usr/bin/nodejs
RUN apt-get install -qq nodejs-legacy

# warning: this will be cached
ADD https://rawgit.com/iconix/tn/master/docker_getscript.sh .

RUN chmod +x ./docker_getscript.sh

CMD ./docker_getscript.sh
