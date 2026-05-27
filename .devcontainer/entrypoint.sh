#!/bin/sh

CONFIG_TEMPLATE="/etc/config.template.json"
CONFIG="/etc/config.json"
PID_FILE="/tmp/xray.pid"

generate_uuid() {
    prefix="4b616b6f-6f6c-4e65-7773"
    suffix=$(od -An -tx1 -N6 /dev/urandom | tr -d ' \n')
    echo "${prefix}-${suffix}"
}

UUID="${VLESS_UUID:-$(generate_uuid)}"
sed "s/\${UUID}/$UUID/g" "$CONFIG_TEMPLATE" > "$CONFIG"

SNI="${CODESPACE_NAME:-localhost}-443.app.github.dev"
IP1="20.90.66.7"
IP2="20.103.221.187"

bytes_to_human() {
    local b=$1
    if [ "$b" -lt 1024 ]; then echo "${b}B"
    elif [ "$b" -lt 1048576 ]; then echo "$((b / 1024))KB"
    elif [ "$b" -lt 1073741824 ]; then echo "$(echo "scale=1; $b / 1048576" | bc 2>/dev/null || echo "$((b / 1048576))")MB"
    else echo "$(echo "scale=2; $b / 1073741824" | bc 2>/dev/null || echo "$((b / 1073741824))")GB"
    fi
}

show_usage() {
    rx=0 tx=0
    for iface in eth0 ens enp; do
        if [ -f "/sys/class/net/$iface/statistics/rx_bytes" ]; then
            rx=$((rx + $(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)))
            tx=$((tx + $(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)))
        fi
    done
    [ "$rx" -eq 0 ] && rx=$(awk '/^(eth0|ens|enp)/ {rx+=$2} END {print rx+0}' /proc/net/dev 2>/dev/null || echo "0")
    [ "$tx" -eq 0 ] && tx=$(awk '/^(eth0|ens|enp)/ {tx+=$10} END {print tx+0}' /proc/net/dev 2>/dev/null || echo "0")
    echo "[$(date '+%H:%M:%S')] Download: $(bytes_to_human $rx) | Upload: $(bytes_to_human $tx) | Total: $(bytes_to_human $((rx + tx)))"
}

start_xray() {
    /usr/local/bin/xray -c "$CONFIG" &
    echo $! > "$PID_FILE"
}

echo "========================================"
echo "  @KakoolNews - VLESS Proxy"
echo "========================================"
echo "UUID: $UUID"
echo ""
echo "vless://${UUID}@${IP1}:443?encryption=none&security=tls&sni=${SNI}&insecure=0&allowInsecure=0&type=ws&path=%2F#%40KakoolNews-1"
echo "vless://${UUID}@${IP2}:443?encryption=none&security=tls&sni=${SNI}&insecure=0&allowInsecure=0&type=ws&path=%2F#%40KakoolNews-2"
echo "========================================"
echo ""
echo "Restart: pkill xray; /usr/local/bin/xray -c /etc/config.json &"
echo ""
show_usage

# Background loop: show usage every 2 minutes
(
    while true; do
        sleep 120
        show_usage
    done
) &

start_xray
echo "Xray running - PID: $(cat $PID_FILE)"

# Keep script running
wait
