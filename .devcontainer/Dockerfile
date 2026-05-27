FROM debian:bookworm-slim

ENV XRAY_VERSION=v26.3.27

COPY setup.sh /tmp/setup.sh
COPY config.json /etc/xray/g2ray.json

# Install system dependencies + vnstat for bandwidth monitoring
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash curl wget unzip ca-certificates openssl vnstat \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /tmp/setup.sh \
    && /tmp/setup.sh \
    && rm /tmp/setup.sh

# Fixed UUID - same for all sessions (no regeneration needed)
# UUID: 12345678-1234-1234-1234-123456789abc
RUN echo 'printf "\n\033[1;32m[@KakoolNews]\033[0m VLESS Connection strings:\n"' >> /etc/bash.bashrc
RUN echo 'printf "\nvless://12345678-1234-1234-1234-123456789abc@20.103.221.187:443?encryption=none&security=tls&type=ws&path=%2F#Kakool%20news-1\n"' >> /etc/bash.bashrc
RUN echo 'printf "\nvless://12345678-1234-1234-1234-123456789abc@20.90.66.7:443?encryption=none&security=tls&type=ws&path=%2F#Kakool%20news-2\n"' >> /etc/bash.bashrc
RUN echo 'printf "\n\033[1;33m[@KakoolNews]\033[0m Commands:\n"' >> /etc/bash.bashrc
RUN echo 'printf "  1 - Restart Xray\n"' >> /etc/bash.bashrc
RUN echo 'printf "  bash /workspaces/usage.sh - Check bandwidth usage\n\n"' >> /etc/bash.bashrc

# Copy usage script for bandwidth monitoring
COPY usage.sh /workspaces/usage.sh
RUN chmod +x /workspaces/usage.sh

EXPOSE 443

CMD ["/usr/local/bin/xray", "run", "-c", "/etc/xray/g2ray.json"]
