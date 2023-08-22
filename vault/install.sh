#!/usr/bin/env sh
# docker volume create vault-volume
openssl req -x509 -newkey rsa:4096 -keyout ./vault-data/key.pem -out ./vault-data/certificate.pem -sha256 -days 3650 -nodes -subj "/C=ISO/ST=ISO_Server/L=ISO_Server/O=ISO_Server/OU=ISO_Server/CN=10.1.20.100"
