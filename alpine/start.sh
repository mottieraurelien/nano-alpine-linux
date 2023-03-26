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

# Reset the packages repositories and enable the community repository :
echo "# HK repositories (closest ones) :
https://mirror.xtom.com.hk/alpine/latest-stable/main
https://mirror.xtom.com.hk/alpine/latest-stable/community" > /etc/apk/repositories

# Update the packages list :
apk update

# Upgrade the packages :
apk upgrade

# Install nano to easily edit files :
apk add nano

# Install curl to easily call APIs :
apk add curl

# Install jq to easily parse JSON payloads :
apk add jq

# Install htop to get a better overview of the hardware consumption and running processes :
apk add htop

# Install openssl to generate certificates :
apk add openssl

# Initialise the SSH configuration to get access to nano remotely :
mkdir -p "$HOME"/.ssh
authorizedFile="$HOME/$(grep AuthorizedKeysFile /etc/ssh/sshd_config | cut -d$'\t' -f2)"
touch "$authorizedFile"
echo "export AUTHORIZED_KEYS_FILE=$authorizedFile" >> /etc/profile

# Generate the custom unique set of Diffie-Hellman key exchange parameters to prevent the Logjam attack against the TLS protocol :
mkdir -p /etc/certificates/
# This operation can take a while (20-60 minutes depending on your CPU)
openssl dhparam -out /etc/certificates/dhparams.pem 4096
# Set the right permissions :
chmod 400 /etc/certificates/dhparams.pem

# Install Intel drivers (since my Intel CPU J4125 embeds an iGPU) :
apk add mesa-dri-gallium
apk add libva-intel-driver
echo "export MESA_LOADER_DRIVER_OVERRIDE=iris" >> /etc/profile

########################
### 3/ HEALTH CHECKS ###
########################

# [nano has been successfully installed]
if [ -z "$(command -v nano)" ]; then
  echo "nano installation failed"
  exit 1
fi

# [curl has been successfully installed]
if [ -z "$(command -v curl)" ]; then
  echo "curl installation failed"
  exit 1
fi

# [jq has been successfully installed]
if [ -z "$(command -v jq)" ]; then
  echo "jq installation failed"
  exit 1
fi

# [htop has been successfully installed]
if [ -z "$(command -v htop)" ]; then
  echo "htop installation failed"
  exit 1
fi

# [docker packages are available]
if [ -z "$(apk search docker)" ]; then
  echo "Failed to find the docker package in the community repository"
  exit 1
fi

exit 0
