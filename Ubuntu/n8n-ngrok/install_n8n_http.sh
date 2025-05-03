#!/bin/bash
echo "Start docker install"
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

install_docker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update
    sudo apt install -y docker-ce
}

install_docker

echo "Docker install done"

echo "Create folder"
cd ~
mkdir -p vol_n8n
sudo chown -R 1000:1000 vol_n8n
sudo chmod -R 755 vol_n8n
echo "Folder created"

echo "Start docker compose"
wget https://raw.githubusercontent.com/khanhvc-doc/n8n-install/refs/heads/master/Ubuntu/n8n-ngrok/docker-compose.yml -O compose.yml
export EXTERNAL_IP=http://"$(hostname -I | cut -f1 -d' ')"
export CURR_DIR=$(pwd)
sudo -E docker compose up -d
echo "Done, open $EXTERNAL_IP in browser"
