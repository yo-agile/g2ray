set -eu

XRAY_DIR="/usr/local/bin"

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
URL="https://github.com/XTLS/Xray-core/releases/download/${VERSION}/Xray-linux-${ARCH}.zip"

echo "Downloading Xray ${VERSION} for linux-${ARCH}..."
wget -q -O /tmp/xray.zip "$URL"

echo "Installing Xray..."
unzip -o /tmp/xray.zip -d /tmp/xray
chmod +x /tmp/xray/xray
mv /tmp/xray/xray "$XRAY_DIR/xray"

rm -rf /tmp/xray.zip /tmp/xray
echo "Xray installed."
