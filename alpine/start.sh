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

# Prevent root from login (you can now connect through SSH, no need that login method anymore) :
if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
fi
if grep -q "^PermitRootLogin prohibit-password" /etc/ssh/sshd_config; then
  sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
fi

# Reset the packages repositories :
echo "# HK repositories (closest ones) :
https://mirror.xtom.com.hk/alpine/latest-stable/main
https://mirror.xtom.com.hk/alpine/latest-stable/community
# CDL repositories (in case HK ones don't work) :
https://dl-cdn.alpinelinux.org/alpine/latest-stable/main
https://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >/etc/apk/repositories

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
