#!/usr/bin/env sh
VERBOSE=false

# Verbose function
verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

#Analysing script options
while getopts ":v" opt; do
    case $opt in
        v)
            VERBOSE=true
            ;;
        \?)
            echo "Option invalide: -$OPTARG" >&2
            ;;
    esac
done

#shift $((OPTIND-1))

#Create a SSL Certificate for HTTPS
openssl req -x509 -newkey rsa:4096 -keyout ./vault_data/key.pem -out ./vault_data/certificate.pem -sha256 -days 3650 -nodes -addext 'subjectAltName = IP:127.0.0.1' -subj "/ST=ISO_Server/L=ISO_Server/O=ISO_Server/OU=ISO_Server/IP=127.0.0.1" 

#Create and deploy the vault
docker-compose build 
docker-compose up -d 

# Wait to be sure the vault is ready
sleep 5

# Initialization
sudo docker exec -it vault vault operator init -n 6 -t 2 --format=json --tls-skip-verify > key.json

# Unsealing
seal_key_0=$(cat key.json |  jq ".unseal_keys_b64[0]" | sed 's/\"//g' )
seal_key_1=$(cat key.json | jq ".unseal_keys_b64[1]"| sed 's/\"//g' )
root_token=$(cat key.json | jq ".root_token"| sed 's/\"//g' )
docker exec -it vault vault operator unseal --tls-skip-verify $seal_key_0 
docker exec -it vault vault operator unseal  --tls-skip-verify $seal_key_1 

# Enabling KV engine
docker exec -it vault vault login --tls-skip-verify $root_token 
docker exec -it vault vault secrets enable --tls-skip-verify -version=2 kv 

# show and destroy vault secrets
cat key.json
rm key.json
