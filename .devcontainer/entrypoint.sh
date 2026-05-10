#!/bin/sh
set -eu

CONFIG_TEMPLATE="/etc/config.template.json"
CONFIG="/etc/config.json"

generate_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen
    elif [ -r /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}'
    fi
}

UUID="${VLESS_UUID:-$(generate_uuid)}"

sed "s/\${UUID}/$UUID/g" "$CONFIG_TEMPLATE" > "$CONFIG"

SNI="${CODESPACE_NAME:-localhost}-443.app.github.dev"

echo ""
echo "========================================"
echo "  G2Ray - VLESS Proxy"
echo "========================================"
echo ""
echo "VLESS link:"
echo "vless://${UUID}@94.130.50.12:443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${SNI}&path=%2F#g2ray"
echo ""
echo "========================================"
echo ""

exec /usr/local/bin/xray -c "$CONFIG"
