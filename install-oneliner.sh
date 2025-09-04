#!/bin/bash

# One-liner installer script
# This script downloads and runs the main installer

URL="https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh"

if [ -f /usr/bin/curl ]; then
    curl -ksSO "$URL"
else
    wget --no-check-certificate -O one-liner-install.sh "$URL"
fi

bash one-liner-install.sh