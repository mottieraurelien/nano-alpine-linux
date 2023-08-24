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

# Check that his authorized keys file contains one public key at least :
authorizedFile="/home/$REGULAR_USER/$(grep AuthorizedKeysFile /etc/ssh/sshd_config | cut -d$'\t' -f2)"
numberOfAuthorizedKeys=$(cat "$authorizedFile" | wc -l)
if [ "$numberOfAuthorizedKeys" -eq "0" ]; then
  echo "Please set up the key-based authentication before disabling the credentials-based authentication."
  exit
fi

# Prevent using root when connecting to the server using SSH :
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config

# Success :
exit 0
