FROM sonarqube:latest
ENV VAULT_VERSION 1.8.2

RUN apt-get install unzip

RUN wget --quiet --output-document=/tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /vault && \
    rm -f /tmp/vault.zip && \
    chmod +x /vault

COPY vault-agent-config.hcl /etc/vault-agent/

ENV VAULT_ADDR=http://host:8200
ENV VAULT_AGENT_CONFIG=/etc/vault-agent/vault-agent-config.hcl

CMD ["vault", "agent", "-config=/etc/vault-agent/vault-agent-config.hcl"]
