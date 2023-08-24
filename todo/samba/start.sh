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

# TODO : create dedicate group
# https://www.arubacloud.com/tutorial/how-to-create-an-intranet-with-samba-and-openvpn.aspx

# Update the packages list :
apk update

# Install the samba server :
apk add samba

# Create the folder that will host the media files to share over network :
mkdir -p /DATA/media/movies
mkdir -p /DATA/media/tv

# Override the default configuration with the default one :
rm -f /etc/samba/smb.conf
cp smb.conf /etc/samba

# Define the new SMB user :
echo "Input an username for the new SMB user : "
IFS= read -r regularAccountUsername

# Create the new SMB user that wants to read this folder :
smbpasswd -a "$regularAccountUsername"
# (a password prompt will pop up)

# Run samba as a service :
rc-update add samba
rc-service samba start

# Success :
exit 0
