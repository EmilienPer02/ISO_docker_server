storage "file" {
  path = "/vault_data/data"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/vault_data/data/certificate.pem"
  tls_key_file = "/vault_data/data/key.pem"

}

default_lease_ttl = "168h"
max_lease_ttl     = "720h"
api_addr          = "http://0.0.0.0:8200"
ui                = 1
VAULT_SKIP_VERIFY = "true"

