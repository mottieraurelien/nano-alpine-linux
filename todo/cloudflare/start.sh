#!/bin/bash

# connect API Cloudflare > get input from user
# Defines the regular account username :
echo "Input the token to call the Cloudflare API : "
IFS= read -r cloudflareToken

# check if can login using token

# check token permissions

# get CERT and store it on host > cloudflare.crt

# get KEY and store it on host > cloudflare.key

# convert CERT+KEY into PKCS12 (some services like Jellyfin needs PKCS12)
openssl pkcs12 -export -in cloudflare.crt -inkey cloudflare.key -name 'cloudflare' -out cloudflare.p12

# enforce TLSv1.3

# enforce strict connection

# enforce ...

# enforce ...

# enforce ...

# enforce ...

exit 0
