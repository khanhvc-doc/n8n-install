#!/bin/bash

set -e

echo " Starting Nginx reverse proxy configuration for n8n..."

# 1. Install Nginx if it's not already installed
if ! command -v nginx > /dev/null; then
    echo " Installing Nginx..."
    sudo apt update
    sudo apt install nginx -y
fi

# 2. Create SSL directory
echo "Creating directory /etc/ssl/n8n..."
sudo mkdir -p /etc/ssl/n8n

# 3. Download SSL configuration file
echo "Downloading openssl-n8n.cnf configuration file..."
curl -L -o openssl-n8n.cnf https://raw.githubusercontent.com/khanhvc-doc/n8n-install/refs/heads/master/Ubuntu/http-to-https/openssl-n8n.cnf

# 4. Create self-signed SSL certificate
echo "Creating self-signed SSL certificate..."
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout n8n.key -out n8n.crt -config openssl-n8n.cnf

# 5. Move SSL files to the system directory
sudo cp n8n.crt /etc/ssl/n8n/
sudo cp n8n.key /etc/ssl/n8n/

# 6. Download Nginx configuration file for n8n
echo "Downloading Nginx configuration for n8n..."
sudo curl -L -o /etc/nginx/sites-available/n8n https://raw.githubusercontent.com/khanhvc-doc/n8n-install/refs/heads/master/Ubuntu/http-to-https/n8n

# sudo cp .env /etc/nginx/sites-available/

# Đọc giá trị từ file .env
SUBDOMAIN=$(grep -oP 'MY_SUBDOMAIN=\K.*' .env)
DOMAIN=$(grep -oP 'MY_DOMAIN_NAME=\K.*' .env)

# Tạo giá trị server_name mới
NEW_SERVER_NAME="${SUBDOMAIN}.${DOMAIN}"
cd /etc/nginx/sites-available/
# Cập nhật cả hai dòng server_name trong file n8n
sudo sed -i "s/server_name .*/server_name ${NEW_SERVER_NAME};/g" n8n


# 7. Enable configuration
echo "Creating symbolic link and reloading Nginx..."
sudo ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/n8n
sudo nginx -t && sudo systemctl reload nginx

# 8. Open firewall ports if applicable
if command -v ufw > /dev/null; then
    echo "Opening firewall (ufw)..."
    sudo ufw allow 80,443/tcp || true
fi
# export EXTERNAL_IP=$(grep EXTERNAL_IP .env | cut -d '=' -f2)
echo "Complete! Access https://$NEW_SERVER_NAME (accept self-signed certificate if necessary)."