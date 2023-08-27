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

# Shutdown WireGuard if exists :
docker compose down
rm -rf /pvs/wireguard

# Create the persistent volume :
mkdir -p /pvs/wireguard/config

# Run WireGuard :
docker compose up --detach --force-recreate

# Success :
exit 0
