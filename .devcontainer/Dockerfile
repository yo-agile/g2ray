FROM debian:bookworm-slim

COPY install.sh /app/install.sh

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget unzip tzdata openssl ca-certificates vnstat \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /app/install.sh \
    && /app/install.sh \
    && rm /app/install.sh

COPY config.json /etc/config.template.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN mkdir -p /workspaces/g2ray/.devcontainer && \
    cp config.json /workspaces/g2ray/.devcontainer/config.json
COPY usage.sh /workspaces/usage.sh
COPY export.sh /workspaces/g2ray/.devcontainer/export.sh
COPY setup.sh /workspaces/g2ray/.devcontainer/setup.sh
COPY install.sh /workspaces/g2ray/.devcontainer/install.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /workspaces/usage.sh /workspaces/g2ray/.devcontainer/*.sh

CMD ["/usr/local/bin/entrypoint.sh"]
