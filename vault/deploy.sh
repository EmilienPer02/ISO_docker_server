#!/bin/bash

# Vérifiez si Vault est déjà en cours d'exécution en production
if docker ps | grep -q "vault"; then
  echo "Vault est déjà en cours d'exécution en production."
  exit 1
fi

# Démarrez Vault en production
docker run -d --name vault -p 8200:8200 hashicorp/vault:latest

# Attendez que Vault démarre
echo "Attente de démarrage de Vault..."
sleep 10

# Initialisez Vault et stockez les clés de déchiffrement dans un fichier temporaire
docker exec vault vault operator init -dev -key-shares=3 -key-threshold=2 > keys.txt

# Déverrouillez Vault avec la clé de déchiffrement principale
cat keys.txt | grep "Unseal Key 1" | awk '{print $4}' | docker exec -i vault vault operator unseal -
cat keys.txt | grep "Unseal Key 2" | awk '{print $4}' | docker exec -i vault vault operator unseal -

# Utilisez la clé racine pour vous authentifier
cat keys.txt | grep "Initial Root Token" | awk '{print $4}' | docker exec -i vault vault login -

# Activez le moteur de stockage de secrets KV
docker exec vault vault -dev secrets enable -path=mysecrets kv

# Créez un secret
docker exec vault vault -dev kv put mysecrets/mysecretkey myvalue=mysecretvalue

# Nettoyez le fichier temporaire contenant les clés
rm keys.txt

echo "Vault a été déployé en production et un secret a été créé."