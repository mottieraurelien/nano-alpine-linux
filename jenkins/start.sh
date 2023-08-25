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
deluser jenkins || true

# Create jenkins user so that we avoid using root, and add the user to docker group :
adduser jenkins --disabled-password --no-create-home
addgroup jenkins docker

# Create the persistent volume and give ownership :
mkdir -p /pvs/jenkins && chown -R jenkins:jenkins /pvs/jenkins

# Export jenkins user id and group id (since we will use a docker bind volume) :
#JENKINS_UID="$(grep -e "^jenkins" /etc/passwd | cut -d":" -f3)"
#export JENKINS_UID
#JENKINS_GID="$(grep -e "^jenkins" /etc/passwd | cut -d":" -f4)"
#export JENKINS_GID

# Run Jenkins :
JENKINS_UID="$(grep -e "^jenkins" /etc/passwd | cut -d":" -f3)" \
 JENKINS_GID="$(grep -e "^jenkins" /etc/passwd | cut -d":" -f4)" \
 docker compose up --detach --force-recreate

# Success :
exit 0
