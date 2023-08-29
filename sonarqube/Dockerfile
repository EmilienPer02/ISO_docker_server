FROM sonarqube:latest
ENV VAULT_VERSION 1.8.2

USER root
RUN apt-get update && apt-get install -y unzip

RUN wget --quiet -O vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip vault.zip && \
    mv vault /usr/local/bin/ && \
    rm vault.zip


COPY vault-agent-config.hcl /etc/vault-agent/

ENV VAULT_ADDR=http://host:8200
ENV VAULT_AGENT_CONFIG=/etc/vault-agent/vault-agent-config.hcl

CMD ["vault", "agent", "-config=/etc/vault-agent/vault-agent-config.hcl"]
