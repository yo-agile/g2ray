#!/bin/sh
set -e

# Download and install Xray-core
RELEASE="https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip"
TMPDIR="$(mktemp -d)"

curl -sL "$RELEASE" -o "$TMPDIR/xray.zip"
unzip -q "$TMPDIR/xray.zip" -d "$TMPDIR"
install -m 755 "$TMPDIR/xray" /usr/local/bin/xray

rm -rf "$TMPDIR"
