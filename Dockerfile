# DOCKER-VERSION 1.2.0

# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
#
# MY MAIN REASON FOR BASEIMAGE-DOCKER: to enable graceful shutdown with 'docker stop'
# https://phusion.github.io/baseimage-docker/

FROM phusion/baseimage:0.9.15

# Set correct environment variables.
ENV HOME /root

# Disable ssh
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ... my own build instructions below ...

# make sure apt is up to date
RUN apt-get update -qq

# install nodejs, npm, git
RUN apt-get install -qq nodejs npm git git-core curl

# set /usr/bin/node as a symlink to /usr/bin/nodejs
RUN apt-get install -qq nodejs-legacy

# warning: this will be cached
ADD https://rawgit.com/iconix/tn/master/docker_getscript.sh $HOME/

RUN chmod +x $HOME/docker_getscript.sh

CMD $HOME/docker_getscript.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
