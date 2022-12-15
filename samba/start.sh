#!/bin/bash

# Update the packages list :
apk update

# Upgrade the packages :
apk upgrade

# Install the samba server :
apk add samba

# Create the folder that will host the media files to share over network :
mkdir -p /media/ssd/

# Override the default configuration with the default one :
rm -f /etc/samba/smb.conf
cp smb.conf /etc/samba

# Create the samba user that wants to read this folder :
smbpasswd -a aurel
# (a password prompt will pop up)

# Run samba as a service :
rc-update add samba
rc-service samba start