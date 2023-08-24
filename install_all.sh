#!/usr/bin/env sh

# Install treafic
docker-compose -f ./treafic/docker-compose.yml up -d

# Install vault and get root token
root_token= $(./vault/install.sh | jq ".root_token"| sed 's/\"//g' )
echo $root_token