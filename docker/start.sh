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

# Install docker :
apk add docker

# Install docker-compose :
apk add docker-compose

# Define docker as a system service :
rc-update add docker boot
service docker start

# Define the regular account username :
echo "Input an username for the regular account : "
IFS= read -r regularAccountUsername

# Create regular user so that we avoid to use root when there is no need :
adduser "$regularAccountUsername"

# Add the current user to the docker group (so that no need to be root to run docker commands) :
addgroup "$regularAccountUsername" docker

# Leave the root session to switch to the regular account :
su - "$regularAccountUsername"

########################
### 3/ HEALTH CHECKS ###
########################

# [Regular account has been successfully created]
if [ "$(whoami)" != "$regularAccountUsername" ]; then
  echo "Regular account creation failed"
  exit 1
fi
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
