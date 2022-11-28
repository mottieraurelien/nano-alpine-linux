#!/bin/bash

# USAGE
# Mode force optional

# Get info if Portainer container is running


# if Portainer container is running + mode force enabled
# policy="--force-recreate"

# Portainer container is not running (or not anymore since stopped)
  # docker compose up --detach ${policy}
# docker run -d -p 9443:9443 --name portainer --restart unless-stopped \
# -v /var/run/docker.sock:/var/run/docker.sock \
# -v ~/portainer:/data \
# -v ~/certs:/certs:ro \
# portainer/portainer-ce --ssl --sslcert /certs/portainer.crt --sslkey /certs/portainer.key

# Portainer is running and accessible here : https://{DOMAIN}/portainer