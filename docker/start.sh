#!/bin/bash

#######################
### 1/ REQUIREMENTS ###
#######################

# [Connected as root]
if [ "$(whoami)" != "root" ]; then
  echo "root privileges are required"
  exit 1
fi

###############
### 2/ MAIN ###
###############

# Update the packages list :
apk update

# Install docker and docker-compose :
apk add docker docker-compose

# Define docker as a system service :
rc-update add docker boot
service docker start

# Add the current user to the docker group (so that no need to be root to run docker commands) :
addgroup "$REGULAR_USER" docker

########################
### 3/ HEALTH CHECKS ###
########################

# [docker has been successfully installed and regular account can run commands]
if [ -z "$(command -v docker)" ]; then
  echo "Docker installation failed"
  exit 1
fi
# [docker-compose has been successfully installed and regular account can run commands]
if [ -z "$(command -v docker-compose)" ]; then
  echo "Docker-compose installation failed"
  exit 1
fi

exit 0
