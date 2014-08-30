# DOCKER-VERSION 1.2.0

FROM ubuntu:14.04

# make sure apt is up to date
RUN apt-get update

# install nodejs, npm, git
RUN apt-get install -y nodejs npm git git-core

# set /usr/bin/node as a symlink to /usr/bin/nodejs
RUN apt-get install nodejs-legacy

ADD https://rawgit.com/iconix/tn/master/docker_start.sh /tmp/

RUN chmod +x /tmp/docker_start.sh

CMD ./tmp/docker_start.sh
