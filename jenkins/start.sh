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

# Shutdown Jenkins if exists :
docker compose down
rm -rf /pvs/jenkins

# Create jenkins user so that we avoid using root, and add the user to docker group :
deluser jenkins || true
adduser jenkins --disabled-password --no-create-home
addgroup jenkins docker

# Create the persistent volume and give ownership :
mkdir -p /pvs/jenkins/jenkins_home && chown -R jenkins:jenkins /pvs/jenkins

# Run Jenkins :
docker compose up --detach --force-recreate

# Success :
exit 0
