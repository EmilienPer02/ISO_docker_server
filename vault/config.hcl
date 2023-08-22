storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/vault/data/certificate.pem"
  tls_key_file = "/vault/data/key.pem"

}

default_lease_ttl = "168h"
max_lease_ttl     = "720h"
api_addr          = "http://0.0.0.0:8200"
ui                = 1

