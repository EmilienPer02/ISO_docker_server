#!/usr/bin/env sh

#Install vault and get root token
root_token= $(./vault/install.sh | jq ".root_token"| sed 's/\"//g' )
echo $root_token