#!/bin/bash

# Check for sudo privileges
# if [ "$(id -u)" != "0" ]; then
#     echo "Sudo privileges are required to run this script. Please run with sudo or as root"
#     exit 1
# fi

echo "========== Starting n8n installation =========="

echo "--------- Checking and installing Docker -----------"
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Starting installation..."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-cache policy docker-ce
    sudo apt install -y docker-ce
    echo "Docker installed successfully"
else
    echo "Docker is already installed"
fi

echo "--------- Checking and installing Docker Compose -----------"
if ! command -v docker-compose &> /dev/null && ! command -v docker compose &> /dev/null; then
    echo "Docker Compose is not installed. Starting installation..."
    sudo apt install -y docker-compose-plugin
    echo "Docker Compose installed successfully"
else
    echo "Docker Compose is already installed"
fi

echo "--------- Creating n8n data storage directory -----------"
cd ~
mkdir -p vol_n8n
sudo chown -R 1000:1000 vol_n8n
sudo chmod -R 755 vol_n8n
echo "Created directory vol_n8n"

echo "--------- Opening ports 80,443,5678 on the firewall -----------"
if command -v ufw &> /dev/null; then
    sudo ufw allow 80,443,5678/tcp
    sudo ufw reload
    echo "Opened ports 80,443,5678 on the firewall"
else
    echo "UFW is not installed, skipping firewall port opening"
fi

echo "--------- Downloading configuration files -----------"
wget -q https://raw.githubusercontent.com/khanhvc-doc/n8n-install/refs/heads/master/Ubuntu/n8n-docker-http/docker-compose.yml -O compose.yml
if [ $? -ne 0 ]; then
    echo "Failed to download docker-compose.yml, please check your internet connection"
    exit 1
fi

wget -q https://raw.githubusercontent.com/khanhvc-doc/n8n-install/refs/heads/master/Ubuntu/n8n-docker-http/.env -O .env
if [ $? -ne 0 ]; then
    echo "Failed to download .env file, please check your internet connection"
    exit 1
fi

echo "--------- Setting up environment variables -----------"
# Get the server IP address
SERVER_IP=$(hostname -I | cut -f1 -d' ')

# Update the .env file with appropriate values
# sed -i "s|EXTERNAL_IP=.*|EXTERNAL_IP=http://$SERVER_IP|g" .env
sed -i '/EXTERNAL_IP=/ s/=.*/=http:\/\/'"$(grep -oP 'MY_SUBDOMAIN=\K.*' .env)"'.'"$(grep -oP 'MY_DOMAIN_NAME=\K.*' .env)"'/' .env
# sed -i '/EXTERNAL_IP=/ s/=.*/='"$(grep -oP 'MY_SUBDOMAIN=\K.*' .env)"'.'"$(grep -oP 'MY_DOMAIN_NAME=\K.*' .env)"'/' .env
sed -i "s|CURR_DIR=.*|CURR_DIR=$(pwd)|g" .env

# Export environment variables for docker-compose
export MY_PORT=$(grep MY_PORT .env | cut -d '=' -f2)
# export EXTERNAL_IP="http://$SERVER_IP"
export EXTERNAL_IP=$(grep EXTERNAL_IP .env | cut -d '=' -f2)
export CURR_DIR=$(pwd)
export MY_DOMAIN_NAME=$(grep MY_DOMAIN_NAME .env | cut -d '=' -f2)
export MY_SUBDOMAIN=$(grep MY_SUBDOMAIN .env | cut -d '=' -f2)
export MY_GENERIC_TIMEZONE=$(grep MY_GENERIC_TIMEZONE .env | cut -d '=' -f2)

echo "--------- Starting n8n with Docker Compose -----------"
sudo -E docker compose up -d
if [ $? -ne 0 ]; then
    echo "Error starting n8n container. Please check logs with the command: sudo docker compose logs -f"
    exit 1
fi

echo "========== Installation complete! =========="
echo "Please wait a few minutes for n8n to start completely"
echo "You can then access n8n via your browser at: http://$SERVER_IP:$MY_PORT"
echo "Or if you have configured DNS:$EXTERNAL_IP:$MY_PORT"