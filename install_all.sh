#!/usr/bin/env sh

# Install treafic
docker-compose -f ./treafic/docker-compose.yml up -d

# Install vault and get root token
cd ./vault
./install.sh > ../key.json
cd ..
root_token=$(cat key.json | jq ".root_token"| sed 's/\"//g' )

cd sonarqube
./install.sh $root_token