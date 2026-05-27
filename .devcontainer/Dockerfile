FROM debian:bookworm-slim

COPY install.sh /app/install.sh

WORKDIR /app

# Install dependencies with clear output
RUN echo "📦 Installing system dependencies..." && \
    apt-get update && apt-get install -y --no-install-recommends \
    bash git curl wget unzip tzdata openssl ca-certificates bc \
    && echo "✅ Dependencies installed successfully" \
    && rm -rf /var/lib/apt/lists/*

# Setup and configure xray
RUN echo "⚙️  Running installation script..." && \
    chmod +x /app/install.sh && /app/install.sh && \
    echo "✅ Installation completed successfully"

COPY config.json /etc/config.json

# Create startup message with clear banner and interactive menu
RUN printf '#!/bin/bash\n' > /app/startup.sh && \
    printf 'get_data_usage() {\n' >> /app/startup.sh && \
    printf '    uplink=$(/usr/local/bin/xray api statsquery -s -p "counter>>>proxy>>>traffic>>>uplink" 2>/dev/null | grep -oP "\\d+" || echo "0")\n' >> /app/startup.sh && \
    printf '    downlink=$(/usr/local/bin/xray api statsquery -s -p "counter>>>proxy>>>traffic>>>downlink" 2>/dev/null | grep -oP "\\d+" || echo "0")\n' >> /app/startup.sh && \
    printf '    total=$((uplink + downlink))\n' >> /app/startup.sh && \
    printf '    if [ $total -ge 1073741824 ]; then\n' >> /app/startup.sh && \
    printf '        printf "%%.2f GB\\n" "$(echo "scale=2; $total / 1073741824" | bc)"\n' >> /app/startup.sh && \
    printf '    elif [ $total -ge 1048576 ]; then\n' >> /app/startup.sh && \
    printf '        printf "%%.2f MB\\n" "$(echo "scale=2; $total / 1048576" | bc)"\n' >> /app/startup.sh && \
    printf '    elif [ $total -ge 1024 ]; then\n' >> /app/startup.sh && \
    printf '        printf "%%.2f KB\\n" "$(echo "scale=2; $total / 1024" | bc)"\n' >> /app/startup.sh && \
    printf '    else\n' >> /app/startup.sh && \
    printf '        printf "%%d B\\n" $total\n' >> /app/startup.sh && \
    printf '    fi\n' >> /app/startup.sh && \
    printf '}\n' >> /app/startup.sh && \
    printf 'show_banner() {\n' >> /app/startup.sh && \
    printf '    clear\n' >> /app/startup.sh && \
    printf '    echo ""\n' >> /app/startup.sh && \
    printf '    echo "╔════════════════════════════════════════════════════════════╗"\n' >> /app/startup.sh && \
    printf '    echo "║          🚀 G2RAY - XRAY SERVICE INITIALIZED 🚀           ║"\n' >> /app/startup.sh && \
    printf '    echo "╚════════════════════════════════════════════════════════════╝"\n' >> /app/startup.sh && \
    printf '    echo ""\n' >> /app/startup.sh && \
    printf '    echo "📋 Configuration:"\n' >> /app/startup.sh && \
    printf '    echo "   • Config File: /etc/config.json"\n' >> /app/startup.sh && \
    printf '    echo "   • Data Usage: $(get_data_usage)"\n' >> /app/startup.sh && \
    printf '    echo ""\n' >> /app/startup.sh && \
    printf '    echo "🔗 VLESS Connection Details:"\n' >> /app/startup.sh && \
    printf '    echo "   • Primary: vless://550e8400-e29b-41d4-a716-446655440000@20.90.66.7:443"\n' >> /app/startup.sh && \
    printf '    echo "   • Backup:  vless://550e8400-e29b-41d4-a716-446655440000@20.103.221.187:443"\n' >> /app/startup.sh && \
    printf '    echo "   • Encryption: none"\n' >> /app/startup.sh && \
    printf '    echo "   • Security: tls"\n' >> /app/startup.sh && \
    printf '    echo "   • Type: ws"\n' >> /app/startup.sh && \
    printf '    echo "   • Path: /"\n' >> /app/startup.sh && \
    printf '    echo "   • SNI: ${CODESPACE_NAME}-443.app.github.dev"\n' >> /app/startup.sh && \
    printf '    echo ""\n' >> /app/startup.sh && \
    printf '    echo "📊 Control Panel:"\n' >> /app/startup.sh && \
    printf '    echo "   Press [1] to restart Xray Core"\n' >> /app/startup.sh && \
    printf '    echo "   Press [Ctrl+C] to stop"\n' >> /app/startup.sh && \
    printf '    echo ""\n' >> /app/startup.sh && \
    printf '}\n' >> /app/startup.sh && \
    printf 'restart_xray() {\n' >> /app/startup.sh && \
    printf '    echo "🔄 Restarting Xray Core..."\n' >> /app/startup.sh && \
    printf '    pkill -f "/usr/local/bin/xray" 2>/dev/null || true\n' >> /app/startup.sh && \
    printf '    sleep 1\n' >> /app/startup.sh && \
    printf '    /usr/local/bin/xray -c /etc/config.json > /dev/null 2>&1 &\n' >> /app/startup.sh && \
    printf '    echo "✅ Xray Core restarted!"\n' >> /app/startup.sh && \
    printf '}\n' >> /app/startup.sh && \
    printf 'show_banner\n' >> /app/startup.sh && \
    printf '/usr/local/bin/xray -c /etc/config.json > /dev/null 2>&1 &\n' >> /app/startup.sh && \
    printf 'xray_pid=$!\n' >> /app/startup.sh && \
    printf 'echo "✨ Service is running (PID: $xray_pid)"\n' >> /app/startup.sh && \
    printf 'echo ""\n' >> /app/startup.sh && \
    printf 'while true; do\n' >> /app/startup.sh && \
    printf '    echo -n "Waiting for input: "\n' >> /app/startup.sh && \
    printf '    read -t 60 -n 1 key 2>/dev/null\n' >> /app/startup.sh && \
    printf '    if [ "$key" = "1" ]; then\n' >> /app/startup.sh && \
    printf '        restart_xray\n' >> /app/startup.sh && \
    printf '    fi\n' >> /app/startup.sh && \
    printf '    show_banner\n' >> /app/startup.sh && \
    printf 'done\n' >> /app/startup.sh && \
    chmod +x /app/startup.sh

CMD ["/app/startup.sh"]
