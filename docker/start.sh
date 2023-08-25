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

# Define docker as a service (starts automatically when the server is starting) :
rc-update add docker boot
service docker start

# Fixing permissions on docker socket (to allow other users to execute docker from containers) :
chmod 666 /var/run/docker.sock

# Add the current user to the docker group (so that no need to be root to run docker commands) :
addgroup "$REGULAR_USER" docker

########################
### 3/ HEALTH CHECKS ###
########################

# Switch to the regular user to check its right:
su - "$REGULAR_USER"

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

# Leave the current regular account session:
exit

exit 0
