#!/bin/bash

#######################
### 1/ REQUIREMENTS ###
#######################

# [Connected as root]
if [ "$(whoami)" != "root" ]; then
  echo "root privileges are required"
  exit 1
fi

# [curl is available]
if [ -z "$(command -v curl)" ]; then
  apk update && apk add curl
fi

###############
### 2/ MAIN ###
###############

# Cloudflare email input
# Cloudflare API key

# Try login

# POST certificate

########################
### 3/ HEALTH CHECKS ###
########################