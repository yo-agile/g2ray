#!/bin/bash
#
# usage.sh - Bandwidth Usage Monitor
# Displays network traffic statistics using vnstat
#

# Check if vnstat is installed
if ! command -v vnstat &> /dev/null; then
    echo "Error: vnstat is not installed"
    echo "Please install vnstat first"
    exit 1
fi

# Get default network interface
INTERFACE=$(vnstat --iflist 2>/dev/null | head -n 1 | awk '{print $1}')
if [ -z "$INTERFACE" ]; then
    INTERFACE="eth0"
fi

echo ""
echo "========================================"
echo "  Bandwidth Usage Statistics"
echo "========================================"
echo ""

# Check if vnstat has data
if vnstat --oneline -i "$INTERFACE" 2>/dev/null | grep -q "0.00"; then
    echo "No data available yet. Traffic monitoring begins"
    echo "when the first network activity is detected."
else
    # Display total traffic (RX/TX) in human-readable format
    echo -n "Interface: "
    echo "$INTERFACE"
    echo ""
    
    # Get RX (received) traffic
    RX=$(vnstat -i "$INTERFACE" --oneline 2>/dev/null | cut -d';' -f2 | sed 's/ //g')
    
    # Get TX (sent) traffic
    TX=$(vnstat -i "$INTERFACE" --oneline 2>/dev/null | cut -d';' -f3 | sed 's/ //g')
    
    echo "Total received: $RX"
    echo "Total sent:     $TX"
fi

echo ""
echo "========================================"

# Also show live interface stats as backup
echo ""
echo "Alternative method (from /proc/net/dev):"
echo ""

# Extract bytes from /proc/net/dev
rx_bytes=$(awk '/^(eth0|ens|enp|lo|docker|br-)/ {rx+=$2} END {print rx+0}' /proc/net/dev 2>/dev/null || echo "0")
tx_bytes=$(awk '/^(eth0|ens|enp|lo|docker|br-)/ {tx+=$10} END {print tx+0}' /proc/net/dev 2>/dev/null || echo "0")

# Convert bytes to human readable
bytes_to_human() {
    local bytes=$1
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes}B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    elif [ "$bytes" -lt 1073741824 ]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$(echo "scale=2; $bytes / 1073741824" | bc 2>/dev/null || echo "$((bytes / 1073741824))")GB"
    fi
}

if [ "$rx_bytes" -gt 0 ] || [ "$tx_bytes" -gt 0 ]; then
    echo "Total received: $(bytes_to_human $rx_bytes)"
    echo "Total sent:     $(bytes_to_human $tx_bytes)"
fi

echo ""
