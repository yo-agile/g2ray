FROM debian:bookworm-slim

# Install system dependencies
RUN echo "Installing system dependencies..." && \
    apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget unzip tzdata openssl ca-certificates vnstat \
    && echo "System dependencies installed" \
    && rm -rf /var/lib/apt/lists/*

# Install Xray-core (latest)
RUN echo "Installing Xray-core..." && \
    ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
        amd64) XRAY_ARCH="64" ;; \
        arm64) XRAY_ARCH="arm64-v8a" ;; \
        armhf) XRAY_ARCH="arm32-v7a" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    XRAY_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+' | sed 's/v//') && \
    echo "Found Xray version: $XRAY_VERSION for $ARCH" && \
    wget -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-${XRAY_ARCH}.zip" && \
    unzip -o /tmp/xray.zip xray -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm /tmp/xray.zip && \
    echo "Xray-core installed"

# Install cloudflared (Cloudflare Tunnel client)
RUN echo "Installing cloudflared..." && \
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared && \
    echo "cloudflared installed"

# Create required directories
RUN mkdir -p /workspaces && chmod 755 /workspaces

# Copy xray config
COPY config.json /etc/xray_config.json

# Copy setup and usage scripts
COPY setup.sh /workspaces/setup.sh
COPY usage.sh /workspaces/usage.sh
RUN chmod +x /workspaces/setup.sh /workspaces/usage.sh

WORKDIR /workspaces

CMD ["/workspaces/setup.sh"]
