#!/bin/bash
#
# usage.sh - Bandwidth Usage Monitor for @Kakoolnews
# Shows network traffic statistics in human-readable format
#

echo ""
echo "[@Kakoolnews] Bandwidth Usage"
echo "========================================"

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

# Get traffic from /proc/net/dev
get_interface_traffic() {
    local rx=0 tx=0
    for iface in eth0 ens enp; do
        if [ -f "/sys/class/net/$iface/statistics/rx_bytes" ]; then
            rx=$((rx + $(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)))
            tx=$((tx + $(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)))
        fi
    done
    # Fallback to /proc/net/dev
    if [ "$rx" -eq 0 ] || [ "$tx" -eq 0 ]; then
        rx=$(awk '/^(eth0|ens|enp)/ {rx+=$2} END {print rx+0}' /proc/net/dev 2>/dev/null || echo "0")
        tx=$(awk '/^(eth0|ens|enp)/ {tx+=$10} END {print tx+0}' /proc/net/dev 2>/dev/null || echo "0")
    fi
    echo "$rx $tx"
}

# Check vnstat first
if command -v vnstat &> /dev/null; then
    INTERFACE=$(vnstat --iflist 2>/dev/null | grep -oE 'eth[0-9]|ens[0-9]+|enp[0-9]+s[0-9]+' | head -1)
    if [ -n "$INTERFACE" ]; then
        echo "Interface: $INTERFACE"
        echo ""
        vnstat -i "$INTERFACE" --style 3 2>/dev/null || {
            # Manual human-readable output from vnstat
            rx_bytes=$(vnstat -i "$INTERFACE" --oneline 2>/dev/null | awk -F';' '{print $6}')
            tx_bytes=$(vnstat -i "$INTERFACE" --oneline 2>/dev/null | awk -F';' '{print $7}')
            if [ -n "$rx_bytes" ] && [ -n "$tx_bytes" ]; then
                echo "  Downloaded:  $(bytes_to_human "$rx_bytes")"
                echo "  Uploaded:    $(bytes_to_human "$tx_bytes")"
                echo ""
                echo "  Total:       $(bytes_to_human $((rx_bytes + tx_bytes)))"
            fi
        }
    else
        echo "No vnstat data available"
    fi
else
    # Use /proc/net/dev fallback
    read rx_bytes tx_bytes <<< "$(get_interface_traffic)"
    echo "  Downloaded:  $(bytes_to_human "$rx_bytes")"
    echo "  Uploaded:    $(bytes_to_human "$tx_bytes")"
    echo ""
    echo "  Total:       $(bytes_to_human $((rx_bytes + tx_bytes)))"
fi

echo "========================================"
echo ""
