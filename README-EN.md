# Dokploy Auto Installer - Private IP

Automatic script to install Dokploy with private IP address configuration.

## Features

- ✅ Automatic system update (apt update & upgrade)
- ✅ Install required packages (curl, wget, bash, git)
- ✅ Automatic Docker installation
- ✅ Docker Swarm setup with private IP
- ✅ Deploy Dokploy with PostgreSQL and Redis
- ✅ Setup Traefik reverse proxy
- ✅ Clear progress information with "tegar-aja" prefix

## Usage

### 🚀 One-Liner Installation (Easiest)
```bash
# Method 1: Using curl
curl -sSL https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh | bash

# Method 2: Using wget (if curl not available)
wget -qO- https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh | bash

# Method 3: Download first then run (like aapanel)
URL=https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O one-liner-install.sh "$URL";fi;bash one-liner-install.sh
```

### 📦 Manual Installation
```bash
# Download and run script
curl -sSL https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/install.sh | bash

# Or clone repository and run
git clone https://github.com/TEGAR-SRC/dokploy-auto-installer-private-ip.git
cd dokploy-auto-installer-private-ip
chmod +x dokploy-installer-iplocal.sh
sudo ./dokploy-installer-iplocal.sh
```

### Update
```bash
# Update Dokploy to latest version
sudo ./dokploy-installer-iplocal.sh update
```

## Requirements

- Ubuntu/Debian Linux
- Root access
- Internet connection
- Ports 80 and 443 not in use

## Access

After installation is complete, access Dokploy at:
- **HTTP**: `http://[SERVER-IP]:3000`
- **HTTPS**: `https://[SERVER-IP]:3000` (after SSL setup)

## Configuration

The script will automatically detect private IP address. To use manual IP:

```bash
export ADVERTISE_ADDR=192.168.1.100
sudo ./dokploy-installer-iplocal.sh
```

## Troubleshooting

### Port already in use
```bash
# Check which ports are in use
sudo ss -tulnp | grep ':80\|:443'

# Stop service using the port
sudo systemctl stop apache2  # or nginx
```

### Docker not installed
```bash
# Install Docker manually
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

### Cannot access web interface
```bash
# Check service status
docker service ls
docker service ps dokploy

# Check logs
docker service logs dokploy
```

### Reset installation
```bash
# Remove all services and data
docker service rm dokploy dokploy-postgres dokploy-redis
docker container rm -f dokploy-traefik
docker volume rm dokploy-postgres-database redis-data-volume dokploy-docker-config
docker network rm dokploy-network
docker swarm leave --force
```

## File Structure

```
dokploy-auto-installer-private-ip/
├── dokploy-installer-iplocal.sh    # Main installer script
├── one-liner-install.sh            # One-liner installer
├── install.sh                      # Auto installer with checks
├── install-oneliner.sh             # Helper for one-liner
├── README.md                       # Main documentation (EN)
├── README-ID.md                    # Indonesian documentation
└── README-EN.md                    # English documentation
```

## License

MIT License

## Contributing

Please create issues or pull requests for improvements and new features.

## Support

If you encounter problems, please:
1. Check the Troubleshooting section above
2. Create an issue in the GitHub repository
3. Contact the developer

---
**Created by TEGAR-SRC**