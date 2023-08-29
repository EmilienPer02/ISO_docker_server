#!/usr/bin/env sh

# Variables
VAULT_TOKEN=$1
VAULT_ADDR="https://localhost:8200"  # Adresse de votre serveur Vault
MYSQL_RANDOM_PASSWORD=$(echo $RANDOM | md5sum | head -c 12; echo;)
VAULT_PATH="secret/sonarqube"

#Start mysql
docker-compose run --rm -d -e MYSQL_ROOT_PASSWORD=$MYSQL_RANDOM_PASSWORD -p '3306:3306' mysql

#Waiting the docker is ready
sleep 20

#Create connection into Vault
cmd_enable_database_engine="curl -X POST -H \"X-Vault-Token: $VAULT_TOKEN\" -d '{\"type\": \"database\"}' $VAULT_ADDR/v1/sys/mounts/database -k"
cmd_create_connection="curl $VAULT_ADDR/v1/database/config/sonardb -H \"x-vault-token:$VAULT_TOKEN\" --data-raw '{\"backend\":\"database\",\"name\":\"sonardb\",\"plugin_name\":\"mysql-rds-database-plugin\",\"verify_connection\":true,\"connection_url\":\"{{username}}:{{password}}@tcp(host:3306)/sonardb\",\"username\":\"root\",\"password\":\"'$MYSQL_RANDOM_PASSWORD'\",\"max_open_connections\":4,\"max_idle_connections\":0,\"max_connection_lifetime\":\"0s\"}' --insecure"
cmd_create_connection_output=$(eval $cmd_create_connection)
cmd_create_connection_exit_code=$?
if [ $cmd_create_connection_exit_code -ne 0 ] || echo "$cmd_create_connection_output" | grep -q "no handler for route"; then
  eval $cmd_enable_database_engine
  eval $cmd_create_connection
fi
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"policy": "path \"'$VAULT_PATH'/*\" { capabilities = [\"read\"] }"}' $VAULT_ADDR/v1/sys/policies/acl/sonarqube-policy -k
sonarqube_token=$(curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"policies": ["sonarqube-policy"]}' $VAULT_ADDR/v1/auth/token/create -k|jq '.auth.client_token'| sed 's/\"//g')
new_allowed_roles=$(curl $VAULT_ADDR/v1/database/config/sonardb -H "X-Vault-Token: $VAULT_TOKEN" -k|jq '.data.allowed_roles+=["sonarqube"]|.data.allowed_roles')
curl $VAULT_ADDR/v1/database/config/sonardb  --data-raw "{\"allowed_roles\":$new_allowed_roles}" -k
curl $VAULT_ADDR/v1/database/roles/sonarqube -H "X-Vault-Token: $VAULT_TOKEN" --data-raw $'{"backend":"database","name":"sonarqube","type":"dynamic","ttl":"3600s","max_ttl":"86400s","rotation_period":"24h","creation_statements":["CREATE USER \'{{name}}\'@\'%\' IDENTIFIED BY \'{{password}}\';GRANT ALL PRIVILEGES ON sonardb TO \'{{name}}\'@\'%\';"],"revocation_statements":["REVOKE ALL PRIVILEGES ON sonardb FROM \'{{name}}\';"],"path":"roles","db_name":"sonardb"}' -k