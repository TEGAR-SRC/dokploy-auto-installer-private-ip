#!/bin/bash

# Dokploy Auto Installer Script
# Created by TEGAR-SRC

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Dokploy Auto Installer${NC}"
    echo -e "${BLUE}  Created by TEGAR-SRC${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        print_error "Script ini harus dijalankan sebagai root"
        print_status "Gunakan: sudo $0"
        exit 1
    fi
}

# Check if running on Linux
check_os() {
    if [ "$(uname)" = "Darwin" ]; then
        print_error "Script ini hanya bisa dijalankan di Linux"
        exit 1
    fi
    
    if [ -f /.dockerenv ]; then
        print_error "Script ini tidak bisa dijalankan di dalam container"
        exit 1
    fi
}

# Check if ports are available
check_ports() {
    print_status "Memeriksa ketersediaan port..."
    
    if ss -tulnp | grep ':80 ' >/dev/null 2>&1; then
        print_error "Port 80 sudah digunakan. Silakan hentikan service yang menggunakan port tersebut."
        exit 1
    fi
    
    if ss -tulnp | grep ':443 ' >/dev/null 2>&1; then
        print_error "Port 443 sudah digunakan. Silakan hentikan service yang menggunakan port tersebut."
        exit 1
    fi
    
    print_status "Port 80 dan 443 tersedia"
}

# Download and run the main installer
download_and_install() {
    print_status "Mengunduh script installer Dokploy..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download the installer script
    if ! curl -sSL -o dokploy-installer-iplocal.sh https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/dokploy-installer-iplocal.sh; then
        print_error "Gagal mengunduh script installer"
        exit 1
    fi
    
    # Make it executable
    chmod +x dokploy-installer-iplocal.sh
    
    print_status "Menjalankan installer Dokploy..."
    echo ""
    
    # Run the installer
    ./dokploy-installer-iplocal.sh
    
    # Cleanup
    cd /
    rm -rf "$TEMP_DIR"
}

# Main function
main() {
    print_header
    
    print_status "Memulai proses instalasi Dokploy..."
    echo ""
    
    # Run checks
    check_root
    check_os
    check_ports
    
    # Download and install
    download_and_install
    
    echo ""
    print_status "Instalasi selesai!"
    print_warning "Tunggu 15 detik untuk server memulai, kemudian akses Dokploy di browser Anda."
}

# Run main function
main "$@"