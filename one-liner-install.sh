#!/bin/bash

# One-liner Dokploy Installer
# Usage: curl -sSL https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[tegar-aja]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Dokploy Auto Installer${NC}"
    echo -e "${BLUE}  Created by TEGAR-SRC${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Check root
if [ "$(id -u)" != "0" ]; then
    print_error "Script ini harus dijalankan sebagai root"
    echo "Gunakan: sudo bash <(curl -sSL https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh)"
    exit 1
fi

# Check OS
if [ "$(uname)" = "Darwin" ]; then
    print_error "Script ini hanya bisa dijalankan di Linux"
    exit 1
fi

if [ -f /.dockerenv ]; then
    print_error "Script ini tidak bisa dijalankan di dalam container"
    exit 1
fi

print_header
print_status "Memulai instalasi Dokploy..."

# Update system
print_status "Updating package lists..."
apt update -y

print_status "Upgrading system packages..."
apt upgrade -y

# Install required packages
print_status "Installing required packages..."
apt install -y curl wget bash git

# Check ports
if ss -tulnp | grep ':80 ' >/dev/null; then
    print_error "Port 80 sudah digunakan"
    exit 1
fi

if ss -tulnp | grep ':443 ' >/dev/null; then
    print_error "Port 443 sudah digunakan"
    exit 1
fi

# Install Docker
if command -v docker >/dev/null 2>&1; then
    print_status "Docker already installed"
else
    print_status "Installing Docker..."
    curl -sSL https://get.docker.com | sh
fi

# Initialize Docker Swarm
docker swarm leave --force 2>/dev/null || true

# Get private IP
get_private_ip() {
    ip addr show | grep -E "inet (192\.168\.|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.)" | head -n1 | awk '{print $2}' | cut -d/ -f1
}

advertise_addr="${ADVERTISE_ADDR:-$(get_private_ip)}"

if [ -z "$advertise_addr" ]; then
    print_error "Tidak bisa menemukan private IP address"
    echo "Silakan set: export ADVERTISE_ADDR=192.168.1.100"
    exit 1
fi

print_status "Using advertise address: $advertise_addr"

# Initialize swarm
print_status "Initializing Docker Swarm..."
docker swarm init --advertise-addr $advertise_addr

# Create network
print_status "Creating Docker network..."
docker network rm -f dokploy-network 2>/dev/null || true
docker network create --driver overlay --attachable dokploy-network

# Setup directories
print_status "Setting up Dokploy directories..."
mkdir -p /etc/dokploy
chmod 777 /etc/dokploy

# Create services
print_status "Creating PostgreSQL service..."
docker service create \
    --name dokploy-postgres \
    --constraint 'node.role==manager' \
    --network dokploy-network \
    --endpoint-mode dnsrr \
    --env POSTGRES_USER=dokploy \
    --env POSTGRES_DB=dokploy \
    --env POSTGRES_PASSWORD=amukds4wi9001583845717ad2 \
    --mount type=volume,source=dokploy-postgres-database,target=/var/lib/postgresql/data \
    postgres:16

print_status "Creating Redis service..."
docker service create \
    --name dokploy-redis \
    --constraint 'node.role==manager' \
    --endpoint-mode dnsrr \
    --network dokploy-network \
    --mount type=volume,source=redis-data-volume,target=/data \
    redis:7

print_status "Creating main Dokploy service..."
docker service create \
    --name dokploy \
    --replicas 1 \
    --endpoint-mode dnsrr \
    --network dokploy-network \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --mount type=bind,source=/etc/dokploy,target=/etc/dokploy \
    --mount type=volume,source=dokploy-docker-config,target=/root/.docker \
    --publish published=3000,target=3000,mode=host \
    --update-parallelism 1 \
    --update-order stop-first \
    --constraint 'node.role == manager' \
    -e ADVERTISE_ADDR=$advertise_addr \
    dokploy/dokploy:latest

sleep 4

print_status "Creating Traefik reverse proxy..."
docker run -d \
    --name dokploy-traefik \
    --restart always \
    -v /etc/dokploy/traefik/traefik.yml:/etc/traefik/traefik.yml \
    -v /etc/dokploy/traefik/dynamic:/etc/dokploy/traefik/dynamic \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 80:80/tcp \
    -p 443:443/tcp \
    -p 443:443/udp \
    traefik:v3.1.2

docker network connect dokploy-network dokploy-traefik

# Format IP for URL
format_ip_for_url() {
    local ip="$1"
    if echo "$ip" | grep -q ':'; then
        echo "[${ip}]"
    else
        echo "${ip}"
    fi
}

formatted_addr=$(format_ip_for_url "$advertise_addr")

echo ""
print_status "Congratulations, Dokploy is installed!"
print_status "Wait 15 seconds for the server to start"
print_status "Please go to http://${formatted_addr}:3000"
echo ""