FROM debian:bookworm-slim

LABEL maintainer="@Kakoolnews" \
      description="VLESS proxy via GitHub Codespaces"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget unzip tzdata openssl ca-certificates bc \
    && rm -rf /var/lib/apt/lists/*

COPY install.sh /app/install.sh
RUN chmod +x /app/install.sh && /app/install.sh

COPY config.json /etc/config.template.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
