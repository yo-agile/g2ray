#!/bin/sh
set -eu

CONFIG_TEMPLATE="/etc/config.template.json"
CONFIG="/etc/config.json"
UUID_FILE="/workspaces/g2ray/.devcontainer/uuid.txt"

# Generate UUID once and save to file for persistence
generate_uuid() {
    if [ -f "$UUID_FILE" ] && [ -s "$UUID_FILE" ]; then
        cat "$UUID_FILE"
    else
        UUID=$(cat /proc/sys/kernel/random/uuid)
        echo "$UUID" > "$UUID_FILE"
        echo "$UUID"
    fi
}

UUID=$(generate_uuid)
sed "s/\${UUID}/$UUID/g" "$CONFIG_TEMPLATE" > "$CONFIG"

SNI="${CODESPACE_NAME:-localhost}-443.app.github.dev"

bytes_to_human() {
    local b=$1
    if [ "$b" -lt 1024 ]; then
        echo "${b}B"
    elif [ "$b" -lt 1048576 ]; then
        echo "$((b / 1024))KB"
    elif [ "$b" -lt 1073741824 ]; then
        echo "$(echo "scale=1; $b / 1048576" | bc 2>/dev/null || echo "$((b / 1048576))")MB"
    else
        echo "$(echo "scale=2; $b / 1073741824" | bc 2>/dev/null || echo "$((b / 1073741824))")GB"
    fi
}

show_usage() {
    echo ""
    echo "[@Kakoolnews] Bandwidth Usage:"
    rx=0 tx=0
    for iface in eth0 ens enp; do
        if [ -f "/sys/class/net/$iface/statistics/rx_bytes" ]; then
            rx=$((rx + $(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)))
            tx=$((tx + $(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)))
        fi
    done
    if [ "$rx" -eq 0 ]; then
        rx=$(awk '/^(eth0|ens|enp)/ {rx+=$2} END {print rx+0}' /proc/net/dev 2>/dev/null || echo "0")
        tx=$(awk '/^(eth0|ens|enp)/ {tx+=$10} END {print tx+0}' /proc/net/dev 2>/dev/null || echo "0")
    fi
    echo "  Download:  $(bytes_to_human $rx)"
    echo "  Upload:    $(bytes_to_human $tx)"
    echo "  Total:     $(bytes_to_human $((rx + tx)))"
    echo ""
}

echo ""
echo "========================================"
echo "  @Kakoolnews - VLESS Proxy"
echo "========================================"
echo ""
echo "UUID: $UUID"
echo ""

show_usage

echo "VLESS links:"
echo ""
echo "vless://${UUID}@20.90.66.7:443?encryption=none&security=tls&type=ws&sni=${SNI}&path=%2F#@Kakoolnews-1"
echo ""
echo "vless://${UUID}@20.103.221.187:443?encryption=none&security=tls&type=ws&sni=${SNI}&path=%2F#@Kakoolnews-2"
echo ""
echo "========================================"
echo "Commands:"
echo "  1 - Restart Xray"
echo "  2 - Show bandwidth"
echo "  q - Quit"
echo ""

start_xray() {
    /usr/local/bin/xray -c "$CONFIG" &
    echo $!
}

XRAY_PID=$(start_xray)

while true; do
    echo "[@Kakoolnews] alive - $(date '+%H:%M:%S')"
    
    if ! kill -0 "$XRAY_PID" 2>/dev/null; then
        echo "[@Kakoolnews] Xray stopped, restarting..."
        XRAY_PID=$(start_xray)
    fi
    
    echo "Enter command: "
    if read -t 60 cmd; then
        case "$cmd" in
            1)
                echo "Restarting Xray..."
                kill "$XRAY_PID" 2>/dev/null || true
                wait "$XRAY_PID" 2>/dev/null || true
                sleep 1
                XRAY_PID=$(start_xray)
                echo "Xray restarted!"
                ;;
            2)
                show_usage
                ;;
            q|Q)
                kill "$XRAY_PID" 2>/dev/null || true
                exit 0
                ;;
            *)
                echo "Use 1, 2, or q"
                ;;
        esac
    fi
done
