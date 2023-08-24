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

# Shutdown Portainer if exists :
docker compose down
rm -rf /pvs/portainer/data

# Create the persistent volume :
mkdir -p /pvs/portainer/data

# Run Portainer :
docker compose up --detach --force-recreate

# Success :
exit 0
