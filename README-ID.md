# Dokploy Auto Installer - Private IP

Script otomatis untuk menginstall Dokploy dengan konfigurasi private IP address.

## Fitur

- ✅ Update sistem otomatis (apt update & upgrade)
- ✅ Install paket yang diperlukan (curl, wget, bash, git)
- ✅ Install Docker otomatis
- ✅ Setup Docker Swarm dengan private IP
- ✅ Deploy Dokploy dengan PostgreSQL dan Redis
- ✅ Setup Traefik reverse proxy
- ✅ Informasi progress yang jelas dengan prefix "tegar-aja"

## Cara Penggunaan

### 🚀 Instalasi One-Liner (Paling Mudah)
```bash
# Cara 1: Menggunakan curl
curl -sSL https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh | bash

# Cara 2: Menggunakan wget (jika curl tidak tersedia)
wget -qO- https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh | bash

# Cara 3: Download dulu lalu jalankan (seperti aapanel)
URL=https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/one-liner-install.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O one-liner-install.sh "$URL";fi;bash one-liner-install.sh
```

### 📦 Instalasi Manual
```bash
# Download dan jalankan script
curl -sSL https://raw.githubusercontent.com/TEGAR-SRC/dokploy-auto-installer-private-ip/main/install.sh | bash

# Atau clone repository dan jalankan
git clone https://github.com/TEGAR-SRC/dokploy-auto-installer-private-ip.git
cd dokploy-auto-installer-private-ip
chmod +x dokploy-installer-iplocal.sh
sudo ./dokploy-installer-iplocal.sh
```

### Update
```bash
# Update Dokploy ke versi terbaru
sudo ./dokploy-installer-iplocal.sh update
```

## Persyaratan

- Ubuntu/Debian Linux
- Root access
- Koneksi internet
- Port 80 dan 443 tidak digunakan

## Akses

Setelah instalasi selesai, akses Dokploy di:
- **HTTP**: `http://[IP-SERVER]:3000`
- **HTTPS**: `https://[IP-SERVER]:3000` (setelah setup SSL)

## Konfigurasi

Script akan otomatis mendeteksi private IP address. Jika ingin menggunakan IP manual:

```bash
export ADVERTISE_ADDR=192.168.1.100
sudo ./dokploy-installer-iplocal.sh
```

## Troubleshooting

### Port sudah digunakan
```bash
# Cek port yang digunakan
sudo ss -tulnp | grep ':80\|:443'

# Stop service yang menggunakan port
sudo systemctl stop apache2  # atau nginx
```

### Docker tidak terinstall
```bash
# Install Docker manual
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

### Tidak bisa akses web interface
```bash
# Cek status service
docker service ls
docker service ps dokploy

# Cek log
docker service logs dokploy
```

### Reset instalasi
```bash
# Hapus semua service dan data
docker service rm dokploy dokploy-postgres dokploy-redis
docker container rm -f dokploy-traefik
docker volume rm dokploy-postgres-database redis-data-volume dokploy-docker-config
docker network rm dokploy-network
docker swarm leave --force
```

## Struktur File

```
dokploy-auto-installer-private-ip/
├── dokploy-installer-iplocal.sh    # Script installer utama
├── one-liner-install.sh            # One-liner installer
├── install.sh                      # Auto installer dengan checks
├── install-oneliner.sh             # Helper untuk one-liner
├── README.md                       # Dokumentasi utama (EN)
├── README-ID.md                    # Dokumentasi bahasa Indonesia
└── README-EN.md                    # Dokumentasi bahasa Inggris
```

## Lisensi

MIT License

## Kontribusi

Silakan buat issue atau pull request untuk perbaikan dan fitur baru.

## Support

Jika mengalami masalah, silakan:
1. Cek bagian Troubleshooting di atas
2. Buat issue di GitHub repository
3. Hubungi developer

---
**Dibuat oleh TEGAR-SRC**