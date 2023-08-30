pid_file = "/var/run/vault-agent.pid"
auto_auth {
  method "database" {
    config = {
      # Le type de méthode d'authentification (dans ce cas, "database").
      type = "database"

      # Chemin du secret qui contient les informations d'identification du client.
      config = {
        #credentials = "database/creds/sonarqube"
        credentials = "secrets/database/credentials/sonarqube"
      }

      # Chemin où le token client doit être stocké.
      sink {
        config = {
          path = "auth/database/login"
        }
      }

      # Temps avant le renouvellement du token.
      template {
        destination = "/etc/sonarqube/sonar.properties"
        contents = <<EOL
      # Fichier de configuration de SonarQube

      sonar.jdbc.username = "{{secret "your/database/secrets" "username"}}"
      sonar.jdbc.password = "{{secret "your/database/secrets" "password"}}"
      EOL
      }
    }
  }

  # Méthode de récupération du token.
  sink {
    config = {
      path = "env:VAULT_TOKEN"
    }
  }
}

vault {
  address = "https://host:8200"
}

exit_after_auth = true


