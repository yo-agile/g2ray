#!/bin/bash
#
# setup.sh - VLESS Proxy Setup Script
# This script starts Xray with VLESS/WebSocket configuration,
# creates a Cloudflare tunnel, and displays the VLESS connection link.
#
# Fixed UUID: 12345678-1234-1234-1234-123456789abc
#

set -e

# Configuration
XRAY_CONFIG="/etc/xray_config.json"
XRAY_PID_FILE="/tmp/xray.pid"
CF_LOG_FILE="/tmp/cloudflared.log"
VLESS_LINK_FILE="/workspaces/vless_link.txt"

# Fixed UUID as specified
UUID="12345678-1234-1234-1234-123456789abc"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print a banner
print_banner() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     VLESS Proxy Setup - GitHub Codespaces Edition        ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Start Xray with VLESS configuration
start_xray() {
    echo -e "${GREEN}[*]${NC} Starting Xray with VLESS/WebSocket configuration..."
    echo -e "${GREEN}[*]${NC} Config: $XRAY_CONFIG"
    echo -e "${GREEN}[*]${NC} UUID: $UUID"
    echo -e "${GREEN}[*]${NC} Listening on: 127.0.0.1:10000"
    
    # Kill any existing Xray process
    pkill -f "/usr/local/bin/xray" 2>/dev/null || true
    sleep 1
    
    # Start Xray in background
    /usr/local/bin/xray run -c "$XRAY_CONFIG" &
    XRAY_PID=$!
    echo $XRAY_PID > "$XRAY_PID_FILE"
    
    # Wait for Xray to start
    sleep 2
    
    if kill -0 $XRAY_PID 2>/dev/null; then
        echo -e "${GREEN}[+]${NC} Xray started successfully (PID: $XRAY_PID)"
    else
        echo -e "${RED}[!]${NC} Failed to start Xray!"
        exit 1
    fi
}

# Start cloudflared tunnel and extract hostname
start_cloudflared() {
    echo -e "${GREEN}[*]${NC} Starting Cloudflare Tunnel..."
    echo -e "${GREEN}[*]${NC} Tunnel URL: http://127.0.0.1:10000"
    
    # Kill any existing cloudflared process
    pkill -f "cloudflared tunnel" 2>/dev/null || true
    sleep 1
    
    # Start cloudflared in background, capture output
    cloudflared tunnel --url http://127.0.0.1:10000 > "$CF_LOG_FILE" 2>&1 &
    CF_PID=$!
    
    # Wait for cloudflared to establish connection and get hostname
    echo -e "${YELLOW}[*]${NC} Waiting for tunnel to be ready..."
    sleep 5
    
    # Extract hostname from cloudflared output
    TUNNEL_HOSTNAME=""
    for i in {1..20}; do
        if grep -q "trycloudflare.com" "$CF_LOG_FILE" 2>/dev/null; then
            TUNNEL_HOSTNAME=$(grep -o '[^ ]*\.trycloudflare\.com' "$CF_LOG_FILE" | head -1)
            break
        fi
        sleep 1
    done
    
    if [ -z "$TUNNEL_HOSTNAME" ]; then
        echo -e "${RED}[!]${NC} Failed to get tunnel hostname!"
        echo -e "${RED}[!]${NC} Check $CF_LOG_FILE for details"
        cat "$CF_LOG_FILE"
        exit 1
    fi
    
    echo -e "${GREEN}[+]${NC} Cloudflare Tunnel established"
    echo -e "${GREEN}[+]${NC} Hostname: $TUNNEL_HOSTNAME"
    echo "$TUNNEL_HOSTNAME" > /tmp/tunnel_hostname.txt
}

# Build and display VLESS link
display_vless_link() {
    TUNNEL_HOSTNAME=$(cat /tmp/tunnel_hostname.txt 2>/dev/null || echo "")
    
    if [ -z "$TUNNEL_HOSTNAME" ]; then
        echo -e "${RED}[!]${NC} Cannot build VLESS link: hostname not available"
        return 1
    fi
    
    # Build VLESS connection string
    # Format: vless://<UUID>@<HOSTNAME>:443?encryption=none&security=tls&type=ws&host=<HOSTNAME>&path=%2Fws#<remark>
    VLESS_LINK="vless://${UUID}@${TUNNEL_HOSTNAME}:443?encryption=none&security=tls&type=ws&host=${TUNNEL_HOSTNAME}&path=%2Fws#Kakool%20news"
    
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              VLESS CONNECTION LINK                        ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🔗 YOUR VLESS LINK:${NC}"
    echo ""
    echo -e "${YELLOW}$VLESS_LINK${NC}"
    echo ""
    
    # Save to file
    echo "$VLESS_LINK" > "$VLESS_LINK_FILE"
    echo -e "${GREEN}[+]${NC} VLESS link saved to: $VLESS_LINK_FILE"
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Configuration Summary${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "  Protocol:     VLESS (WebSocket)"
    echo -e "  UUID:         $UUID"
    echo -e "  Port:         10000 (internal)"
    echo -e "  Path:         /ws"
    echo -e "  TLS:          enabled"
    echo -e "  Tunnel:       Cloudflare (trycloudflare.com)"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Show usage instructions
    echo -e "${GREEN}[*]${NC} To check bandwidth usage, run: bash /workspaces/usage.sh"
    echo ""
}

# Restart Xray function
restart_xray() {
    echo -e "${YELLOW}[*]${NC} Restarting Xray..."
    
    # Kill current Xray
    if [ -f "$XRAY_PID_FILE" ]; then
        OLD_PID=$(cat "$XRAY_PID_FILE")
        if kill -0 "$OLD_PID" 2>/dev/null; then
            kill "$OLD_PID" 2>/dev/null || true
            echo -e "${GREEN}[+]${NC} Stopped Xray (PID: $OLD_PID)"
        fi
        rm -f "$XRAY_PID_FILE"
    fi
    pkill -f "/usr/local/bin/xray" 2>/dev/null || true
    sleep 2
    
    # Start Xray again
    /usr/local/bin/xray run -c "$XRAY_CONFIG" &
    XRAY_PID=$!
    echo $XRAY_PID > "$XRAY_PID_FILE"
    sleep 2
    
    if kill -0 $XRAY_PID 2>/dev/null; then
        echo -e "${GREEN}♻️  Xray restarted${NC} (New PID: $XRAY_PID)"
    else
        echo -e "${RED}[!]${NC} Failed to restart Xray!"
    fi
}

# Interactive loop for user commands
interactive_loop() {
    echo -e "${GREEN}[*]${NC} Setup complete! Proxy is running."
    echo ""
    echo -e "${BLUE}Available commands:${NC}"
    echo "  1 - Restart Xray"
    echo "  q - Quit (stops all services)"
    echo ""
    
    while true; do
        echo -n -e "${YELLOW}>${NC} Enter command: "
        read -r cmd
        
        case "$cmd" in
            1)
                restart_xray
                ;;
            q|Q)
                echo -e "${YELLOW}[*]${NC} Stopping services..."
                pkill -f "/usr/local/bin/xray" 2>/dev/null || true
                pkill -f "cloudflared tunnel" 2>/dev/null || true
                echo -e "${GREEN}[+]${NC} All services stopped."
                exit 0
                ;;
            *)
                echo -e "${RED}[!]${NC} Unknown command. Use 1, or q to quit."
                ;;
        esac
    done
}

# Main execution
main() {
    print_banner
    start_xray
    start_cloudflared
    display_vless_link
    interactive_loop
}

# Run main function
main "$@"
