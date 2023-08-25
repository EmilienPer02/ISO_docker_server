#!/usr/bin/env sh
# Configuration Vault
VAULT_TOKEN=$1

#!/bin/bash

# Variables
VAULT_ADDR="https://localhost:8200"  # Adresse de votre serveur Vault
MYSQL_RANDOM_PASSWORD=$(echo $RANDOM | md5sum | head -c 12; echo;)
echo $MYSQL_RANDOM_PASSWORD
#Start mysql
docker-compose run --rm -d -e MYSQL_ROOT_PASSWORD=$MYSQL_RANDOM_PASSWORD -p '3306:3306' mysql
#cmd_enable_database_engine=curl -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d '{"type": "database"}' $VAULT_ADDR/v1/sys/mounts/database -k
#cmd_create_connection = curl $VAULT_ADDR/v1/database/config/mysql   -H "x-vault-token:$VAULT_TOKEN"   --data-raw '{"backend":"database","name":"mysql","plugin_name":"mysql-rds-database-plugin","verify_connection":true,"connection_url":"{{username}}:{{password}}@tcp(host:3306)/sonar","username":"root","password":"'$MYSQL_RANDOM_PASSWORD'","max_open_connections":4,"max_idle_connections":0,"max_connection_lifetime":"0s"}'   --insecure
cmd_enable_database_engine="curl -X POST -H \"X-Vault-Token: $VAULT_TOKEN\" -d '{\"type\": \"database\"}' $VAULT_ADDR/v1/sys/mounts/database -k"
cmd_create_connection="curl $VAULT_ADDR/v1/database/config/mysql -H \"x-vault-token:$VAULT_TOKEN\" --data-raw '{\"backend\":\"database\",\"name\":\"mysql\",\"plugin_name\":\"mysql-rds-database-plugin\",\"verify_connection\":true,\"connection_url\":\"{{username}}:{{password}}@tcp(host:3306)/sonar\",\"username\":\"root\",\"password\":\"'$MYSQL_RANDOM_PASSWORD'\",\"max_open_connections\":4,\"max_idle_connections\":0,\"max_connection_lifetime\":\"0s\"}' --insecure"

echo "-----------------------------------------------------------------------------------------------------------------"
cmd_create_connection_output=$(eval $cmd_create_connection)
cmd_create_connection_exit_code=$?
echo $cmd_create_connection_output
echo $cmd_create_connection_exit_code
echo "-----------------------------------------------------------------------------------------------------------------"

# Vérifier si la commande a échoué (code de retour différent de zéro) ou si la sortie contient "no handler for route"
if [ $cmd_create_connection_exit_code -ne 0 ] || echo "$cmd_create_connection_output" | grep -q "no handler for route"; then
  echo "La commande cmd_create_connection a échoué ou contient 'no handler for route'. Exécution de cmd_enable_database_engine."
  # Exécuter la commande cmd_enable_database_engine
  eval $cmd_enable_database_engine
  eval $cmd_create_connection
else
  echo "La commande cmd_create_connection a réussi."
fi


