set -eu

XRAY_DIR="/usr/local/bin"
MAX_RETRIES=3
WGET_TIMEOUT=30

detect_arch() {
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) echo "64" ;;
        aarch64|arm64) echo "arm64-v8a" ;;
        armv7*) echo "arm32-v7a" ;;
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
    esac
}

ARCH="$(detect_arch)"
VERSION="v26.4.7"

download_xray() {
    local retries=0
    local URL="https://github.com/XTLS/Xray-core/releases/download/${VERSION}/Xray-linux-${ARCH}.zip"
    
    while [ "$retries" -lt "$MAX_RETRIES" ]; do
        echo "Downloading Xray ${VERSION} for linux-${ARCH}... (attempt $((retries + 1))/${MAX_RETRIES})"
        
        # Try wget first
        if wget --timeout="${WGET_TIMEOUT}" -q -O /tmp/xray.zip "$URL" 2>/dev/null; then
            if [ -s /tmp/xray.zip ]; then
                echo "Download complete."
                return 0
            fi
        fi
        
        # Fallback to curl if wget fails
        echo "wget failed, trying curl..."
        if curl -fLSs --connect-timeout "${WGET_TIMEOUT}" -o /tmp/xray.zip "$URL"; then
            if [ -s /tmp/xray.zip ]; then
                echo "Download complete (via curl)."
                return 0
            fi
        fi
        
        retries=$((retries + 1))
        if [ "$retries" -lt "$MAX_RETRIES" ]; then
            echo "Download failed, retrying in 3 seconds..."
            sleep 3
        fi
    done
    
    echo "ERROR: Failed to download Xray after ${MAX_RETRIES} attempts"
    return 1
}

download_xray

echo "Installing Xray..."
unzip -o /tmp/xray.zip -d /tmp/xray
chmod +x /tmp/xray/xray
mv /tmp/xray/xray "$XRAY_DIR/xray"

rm -rf /tmp/xray.zip /tmp/xray
echo "Xray installed."
