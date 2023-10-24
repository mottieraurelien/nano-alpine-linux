#!/bin/bash

#######################
### 1/ REQUIREMENTS ###
#######################

# [Connected as root]
if [ "$(whoami)" != "root" ]; then
  echo "root privileges are required"
  exit 1
fi

# [docker-compose is required]
if [ -z "$(command -v docker-compose)" ]; then
  echo "Docker-compose installation failed"
  exit 1
fi

###############
### 2/ MAIN ###
###############

# Shutdown Emulatorjs if exists :
docker compose down
rm -rf /pvs/emulatorjs

# Create the persistent volumes :
mkdir -p /pvs/emulatorjs/config
mkdir -p /pvs/emulatorjs/data

# Run Portainer :
docker compose up --detach --force-recreate

# Success :
exit 0
