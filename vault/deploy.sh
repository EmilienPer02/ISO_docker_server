#!/bin/bash

# Variables d'environnement pour Vault
export VAULT_ADDR=http://localhost:8200
export VAULT_DEV_ROOT_TOKEN_ID=myroottoken

# Démarrez Vault en tant que conteneur Docker
docker run -d --cap-add=IPC_LOCK -e VAULT_DEV_ROOT_TOKEN_ID=$VAULT_DEV_ROOT_TOKEN_ID -p 8200:8200 --name vault-dev vault

# Attendez que Vault démarre (vous pouvez personnaliser le temps d'attente en fonction de votre système)
sleep 5

# Initialisez Vault (il s'agit d'un environnement de développement, ne le faites pas en production)
docker exec -it vault-dev vault operator init -key-shares=1 -key-threshold=1 > vault_init.txt

# Déverrouillez Vault avec la clé d'initialisation (ATTENTION : c'est une opération critique, stockez les clés en toute sécurité en production)
UNSEAL_KEY=$(cat vault_init.txt | grep "Unseal Key 1:" | awk '{print $4}')
docker exec -it vault-dev vault operator unseal $UNSEAL_KEY

# Autorisez Vault à gérer des secrets (ceci est un exemple, adaptez-le à vos besoins de politique)
docker exec -it vault-dev vault policy write my-policy - <<EOF
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Créez un token d'accès avec la politique précédemment définie (à adapter en production)
docker exec -it vault-dev vault token create -policy=my-policy > token.txt

# Stockez un secret dans Vault (à adapter en production)
docker exec -it vault-dev vault kv put secret/my-secret key1=value1 key2=value2

# Affichez le token pour l'accès à Vault
echo "Token d'accès à Vault :"
cat token.txt

# Assurez-vous de stocker en toute sécurité le token et les clés d'initialisation en production
