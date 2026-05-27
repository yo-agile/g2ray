#!/bin/bash
#
# usage.sh - Bandwidth Usage Monitor for @KakoolNews
# Shows network traffic statistics using vnstat
#

echo ""
echo "[@KakoolNews] Bandwidth Usage:"
echo "========================================"

# Get default network interface
INTERFACE=$(vnstat --iflist 2>/dev/null | head -n 1 | awk '{print $1}')
if [ -z "$INTERFACE" ]; then
    INTERFACE="eth0"
fi

# Check if vnstat has data
if command -v vnstat &> /dev/null; then
    echo "Interface: $INTERFACE"
    echo ""
    vnstat -i "$INTERFACE" -h 2>/dev/null || vnstat -i "$INTERFACE" 2>/dev/null || echo "No data available"
else
    echo "vnstat not available, using /proc/net/dev:"
    rx_bytes=$(awk '/^(eth0|ens|enp)/ {rx+=$2} END {print rx+0}' /proc/net/dev 2>/dev/null || echo "0")
    tx_bytes=$(awk '/^(eth0|ens|enp)/ {tx+=$10} END {print tx+0}' /proc/net/dev 2>/dev/null || echo "0")
    
    bytes_to_human() {
        local b=$1
        if [ "$b" -lt 1024 ]; then echo "${b}B"
        elif [ "$b" -lt 1048576 ]; then echo "$((b / 1024))KB"
        elif [ "$b" -lt 1073741824 ]; then echo "$((b / 1048576))MB"
        else echo "$(echo "scale=2; $b / 1073741824" | bc 2>/dev/null || echo "$((b / 1073741824))")GB"
        fi
    }
    
    echo "Total received: $(bytes_to_human $rx_bytes)"
    echo "Total sent:     $(bytes_to_human $tx_bytes)"
fi

echo "========================================"
echo ""
