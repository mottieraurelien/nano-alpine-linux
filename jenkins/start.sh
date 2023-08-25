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

# Shutdown Jenkins if exists :
docker compose down
rm -rf /pvs/jenkins

# Create jenkins user so that we avoid using root, and add the user to docker group :
deluser jenkins || true
adduser jenkins --disabled-password --no-create-home
addgroup jenkins docker

# Create the persistent volume and give ownership :
mkdir -p /pvs/jenkins && chown -R jenkins:jenkins /pvs/jenkins

# Export jenkins user id and group id (since we will use a docker bind volume) :
sed -i '/export JENKINS_UID=/d' "$HOME"/.profile
sed -i '/export JENKINS_GID=/d' "$HOME"/.profile
JENKINS_UID="$(grep -e "^jenkins" /etc/passwd | cut -d":" -f3)"
echo "export JENKINS_UID=$JENKINS_UID" >>"$HOME"/.profile
JENKINS_GID="$(grep -e "^jenkins" /etc/passwd | cut -d":" -f4)"
echo "export JENKINS_GID=$JENKINS_GID" >>"$HOME"/.profile
source "$HOME"/.profile

# Run Jenkins :
docker compose up --detach --force-recreate

# Success :
exit 0
