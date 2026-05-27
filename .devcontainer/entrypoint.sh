#!/bin/sh
set -eu

CONFIG_TEMPLATE="/etc/config.template.json"
CONFIG="/etc/config.json"

generate_uuid() {
    # Prefix encodes "KakoolNews" in hex: K=4b a=61 k=6b o=6f o=6f l=6c N=4e e=65 w=77 s=73
    prefix="4b616b6f-6f6c-4e65-7773"
    suffix=$(od -An -tx1 -N6 /dev/urandom | tr -d ' \n')
    echo "${prefix}-${suffix}"
}

# Get your VPS IP from env or use default
SERVER_IP="${SERVER_IP:-localhost}"

UUID="${VLESS_UUID:-$(generate_uuid)}"

sed "s/\${UUID}/$UUID/g" "$CONFIG_TEMPLATE" > "$CONFIG"

SNI="${CODESPACE_NAME:-localhost}-443.app.github.dev"

# Compatible IPs
IP1="20.90.66.7"
IP2="20.103.221.187"

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
    echo "[@KakoolNews] Bandwidth Usage:"
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
echo "  @KakoolNews - VLESS Proxy"
echo "========================================"
echo ""
echo "UUID: $UUID"
echo ""

show_usage

echo "VLESS links:"
echo ""
echo "vless://${UUID}@${IP1}:443?encryption=none&security=tls&sni=${SNI}&insecure=0&allowInsecure=0&type=ws&path=%2F#%40KakoolNews-1"
echo ""
echo "vless://${UUID}@${IP2}:443?encryption=none&security=tls&sni=${SNI}&insecure=0&allowInsecure=0&type=ws&path=%2F#%40KakoolNews-2"
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
    echo "[@KakoolNews] alive - $(date '+%H:%M:%S')"
    
    if ! kill -0 "$XRAY_PID" 2>/dev/null; then
        echo "[@KakoolNews] Xray stopped, restarting..."
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
