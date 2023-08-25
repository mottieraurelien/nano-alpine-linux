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

# Create the persistent volume :
mkdir -p /pvs/jenkins/home

# Run Jenkins :
docker compose up --detach --force-recreate

# Success :
exit 0
