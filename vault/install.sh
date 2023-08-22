#!/usr/bin/env sh
docker volume create vault-data
openssl req -x509 -newkey rsa:4096 -keyout ./vault-data/key.pem -out ./vault-data/certificate.pem -sha256 -days 3650 -nodes -subj "/ST=ISO_Server/L=ISO_Server/O=ISO_Server/OU=ISO_Server"
docker-compose up -d
docker exec -it vault vault operator init > generated_keys.txt
