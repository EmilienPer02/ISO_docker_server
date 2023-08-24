#!/usr/bin/env sh
# Configuration Vault
VAULT_TOKEN=$1

#!/bin/bash

# Variables
VAULT_ADDR="https://localhost:8200"  # Adresse de votre serveur Vault
MYSQL_RANDOM_PASSWORD=$(echo $RANDOM | md5sum | head -c 20; echo;)

#Start mysql
MYSQL_ROOT_PASSWORD=$MYSQL_RANDOM_PASSWORD docker-compose up -d

# Activer l'engine "databases" dans Vault
curl -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d '{"type": "database"}' $VAULT_ADDR/v1/sys/mounts/database -k

curl 'https://10.1.20.100:8200/v1/database/config/mysql' \
  -H "X-Vault-Token: $VAULT_TOKEN" \
  -d '{"backend":"database","name":"mysql","plugin_name":"mysql-legacy-database-plugin","verify_connection":true,"connection_url":"{{username}}:{{password}}@tcp(host:3306)/sonar","username":"root","password":"your_root_password","max_open_connections":4,"max_idle_connections":0,"max_connection_lifetime":"0s"}' \
  -k

echo "done"