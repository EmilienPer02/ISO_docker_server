#!/usr/bin/env sh

# Install treafic
docker-compose -f ./treafic/docker-compose.yml up -d

# Install vault and get root token
cd ./vault
./install.sh > ../key.json
cd ..
cat key.json
