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

# Upgrade the existing packages :
apk upgrade

# Install a bunch of new packages:
apk add ca-certificates curl htop jq nano nmap openjdk17-jdk openssl

# Define the regular account username (so that we don't use root) :
echo "Input an username for the regular account : "
IFS= read -r regularAccountUsername

# Create regular user so that we avoid using root:
adduser "$regularAccountUsername"

# Add the regular user as environment variable in root sessions:
echo "export REGULAR_USER=$regularAccountUsername" >> "$HOME"/.profile
chmod +x "$HOME"/.profile
source "$HOME"/.profile

# Leave the root session to switch to the regular account :
su - "$regularAccountUsername"

# Initialise the SSH configuration to get access to nano remotely :
mkdir -p "$HOME"/.ssh
authorizedFile="$HOME/$(grep AuthorizedKeysFile /etc/ssh/sshd_config | cut -d$'\t' -f2)"
touch "$authorizedFile"
echo "export AUTHORIZED_KEYS_FILE=$authorizedFile" >> "$HOME"/.profile
chmod +x "$HOME"/.profile

# Leave the regular account session (to go back to root):
exit

# Generate the custom unique set of Diffie-Hellman key exchange parameters to prevent the Logjam attack against the TLS protocol :
mkdir -p /etc/certificates/

# Generate self-signed certificates (until get official-signed by Cloudflare)
echo "Input password to use to protect your certificates (P12 and JKS) : "
IFS= read -r certificatesPassword

# Add the certificate password as environment variable :
echo "export KEYSTORE_PASSWORD=$certificatesPassword" >> "$HOME"/.profile
source "$HOME"/.profile

# Generate a private key :
openssl genrsa 4096 >/etc/certificates/private.key && chmod 400 /etc/certificates/private.key

# Getting the public one :
openssl req -new -x509 -nodes -sha256 -days 365 -subj "/C=HK/ST=Hong-Kong/L=Hong-Kong/O=nanonas/OU=dev/CN=nanonas.dev" -key /etc/certificates/private.key -out /etc/certificates/cert.crt

# Converting the certificates into PKCS12 format (since some apps need PKCS12 or even JKS)
openssl pkcs12 -name nanonas -inkey /etc/certificates/private.key -in /etc/certificates/cert.crt -export -out /etc/certificates/cert.p12 -password pass:"$KEYSTORE_PASSWORD"

# Converting the PKCS12 certificate into JKS format :
# keytool -delete -alias nanonas -keystore /etc/certificates/cert.jks -storepass "$KEYSTORE_PASSWORD"    => command to run in case you want to re-generate the JKS.
keytool -alias nanonas -importkeystore -srcstoretype pkcs12 -srckeystore /etc/certificates/cert.p12 -deststoretype JKS -destkeystore /etc/certificates/cert.jks -storepass "$KEYSTORE_PASSWORD" -keypass "$KEYSTORE_PASSWORD" -destkeypass "$KEYSTORE_PASSWORD" -srcstorepass "$KEYSTORE_PASSWORD" -deststorepass "$KEYSTORE_PASSWORD"

# This operation can take a while (20-60 minutes depending on your CPU)
openssl dhparam -out /etc/certificates/dhparams.pem 4096
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
