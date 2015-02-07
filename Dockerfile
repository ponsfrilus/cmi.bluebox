# Installation script for the Blue Box NOC
#
# To test out your changes:
#   1. Install Docker as per the instructions at
#      https://docs.docker.com/installation/, or just run the
#      install_noc.sh script as root
#   2. Using the vigr command, put yourself as a member of the "docker" group;
#      log out then back in
#   3. cd to the directory of this file
#   4. docker build -t epflsti/blueboxnoc:dev .
#      docker run -t -i epflsti/blueboxnoc:dev /bin/bash
#
# To enact the changes, simply run install_noc.sh again and restart.

FROM ubuntu
MAINTAINER Dominique Quatravaux <dominique.quatravaux@epfl.ch>

RUN apt-get update && apt-get -y upgrade && apt-get install -y tinc curl

# https://github.com/joyent/node/wiki/installing-node.js-via-package-manager#debian-and-ubuntu-based-linux-distributions
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get install -y nodejs

# http://www.rexify.org/get
RUN apt-get -y install build-essential libexpat1-dev libxml2-dev libssh2-1-dev libssl-dev
RUN curl -L get.rexify.org | perl - --sudo -n Rex

EXPOSE 80
# For tinc:
EXPOSE 655
