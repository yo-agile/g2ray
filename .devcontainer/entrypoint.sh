#!/bin/sh
set -eu

CONFIG_TEMPLATE="/etc/config.template.json"
CONFIG="/etc/config.json"

# Static UUID - same for all sessions (never changes)
UUID="db9c5b9e-06b9-40cf-b987-575afcb30aea"

sed "s/\${UUID}/$UUID/g" "$CONFIG_TEMPLATE" > "$CONFIG"

SNI="${CODESPACE_NAME:-localhost}-443.app.github.dev"

echo ""
echo "========================================"
echo "  @Kakoolnews - VLESS Proxy"
echo "========================================"
echo ""
echo "VLESS links (try each IP, use whichever works best):"
echo ""
echo "vless://${UUID}@20.103.221.187:443?encryption=none&security=tls&type=ws&sni=${SNI}&path=%2F#@Kakoolnews-1"
echo ""
echo "vless://${UUID}@20.90.66.7:443?encryption=none&security=tls&type=ws&sni=${SNI}&path=%2F#@Kakoolnews-2"
echo ""
echo "========================================"
echo ""
echo "[@Kakoolnews] Commands:"
echo "  1 - Restart Xray"
echo "  bash /workspaces/usage.sh - Check bandwidth usage"
echo ""

/usr/local/bin/xray -c "$CONFIG" &
XRAY_PID=$!

# Interactive loop for restart command
while kill -0 "$XRAY_PID" 2>/dev/null; do
    echo "[@Kakoolnews] alive - $(date '+%H:%M:%S')"
    sleep 300 &
    wait $!
    
    # Check for restart command in a non-blocking way
    if read -t 0; then
        cmd=$(cat)
        if [ "$cmd" = "1" ]; then
            echo "Restarting Xray..."
            kill "$XRAY_PID" 2>/dev/null || true
            sleep 1
            /usr/local/bin/xray -c "$CONFIG" &
            XRAY_PID=$!
            echo "Xray restarted!"
        fi
    fi
done
