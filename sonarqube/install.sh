#!/usr/bin/env sh
# Configuration Vault
VAULT_TOKEN=$1

#!/bin/bash

# Variables
VAULT_ADDR="http://localhost:8200"  # Adresse de votre serveur Vault
VAULT_TOKEN="YOUR_VAULT_TOKEN"      # Votre token d'authentification Vault

# Activer l'engine "databases" dans Vault
curl -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d '{"type": "database"}' $VAULT_ADDR/v1/sys/mounts/database -k

# Créer une configuration pour la base de données PostgreSQL
curl -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d '{
  "plugin_name": "postgresql-database-plugin",
  "allowed_roles": "myapp-role",
  "connection_url": "postgresql://{{username}}:{{password}}@localhost:5432/sonarqube?sslmode=disable",
  "username": "myappadmin",
  "password": "password123"
}' $VAULT_ADDR/v1/database/config/sonarqubedb -k

# Créer un rôle pour la base de données
curl -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d '{
  "db_name": "myappdb",
  "creation_statements": "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  "default_ttl": "1h",
  "max_ttl": "24h"
}' $VAULT_ADDR/v1/database/roles/myapp-role

# Activer la rotation automatique du mot de passe pour le rôle
curl -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d '{
  "rotation_period": "1h"
}' $VAULT_ADDR/v1/database/config/myappdb/rotate-root/myapp-role
