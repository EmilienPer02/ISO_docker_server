exit_after_auth = false

auto_auth {
  method "client_token" {
    mount_path = "auth/token"  # Le chemin du mont-point d'authentification du client_token
    config = {
      client_token = "$VAULT_CLIENT_TOKEN"  # Remplacez par votre propre client_token
    }
  }

  sink "database" {
    config = {
      path = "secrets/database/credentials/sonarqube"
    }
  }
}

template {
  destination = "/etc/sonarqube/sonar.properties"
  contents = <<EOL
# Fichier de configuration de SonarQube

sonar.jdbc.username = "{{secret "your/database/secrets" "username"}}"
sonar.jdbc.password = "{{secret "your/database/secrets" "password"}}"
EOL
}