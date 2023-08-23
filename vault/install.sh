#!/usr/bin/env sh
openssl req -x509 -newkey rsa:4096 -keyout ./vault_data/key.pem -out ./vault_data/certificate.pem -sha256 -days 3650 -nodes -addext 'subjectAltName = IP:127.0.0.1' -subj "/ST=ISO_Server/L=ISO_Server/O=ISO_Server/OU=ISO_Server/IP=127.0.0.1"
docker-compose build
docker-compose up -d
sleep 5
sudo docker exec -it vault vault operator init -n 6 -t 2 --format=json --tls-skip-verify > key.json
seal_key_0= cat key.json |  jq ".unseal_keys_b64[0]"
seal_key_1= cat key.json | jq ".unseal_keys_b64[0]"
echo $seal_key_0
echo $seal_key_1
docker exec -it vault vault operator unseal $seal_key_0 --tls-skip-verify
docker exec -it vault vault operator unseal $seal_key_1 --tls-skip-verify
