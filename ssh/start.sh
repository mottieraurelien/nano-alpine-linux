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

# Check that the authorizes keys file contains one public key at least :
numberOfAuthorizedKeys=$(cat "$AUTHORIZED_KEYS_FILE" | wc -l)
if [ "$numberOfAuthorizedKeys" -eq "0" ]; then
  echo "Please set up the key-based authentication before disabling the credentials-based authentication."
  exit
fi

# Prevent root from login (you can now connect through SSH with root, no need that login method anymore from host) :
if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
fi
if grep -q "^PermitRootLogin prohibit-password" /etc/ssh/sshd_config; then
  sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
fi
if grep -q "^#PubkeyAuthentication yes" /etc/ssh/sshd_config; then
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
fi

########################
### 3/ HEALTH CHECKS ###
########################

exit 0
