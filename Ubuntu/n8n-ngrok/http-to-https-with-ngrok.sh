#!/bin/bash
 echo "Start docker compose down"
 sudo -E docker compose down
 
 echo "Start ngrok setup"
 wget -O ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
 sudo tar xvzf ngrok.tgz -C /usr/local/bin
 sudo rm ngrok.tgz
 sudo apt install -y jq
 
 echo "Login ngrok and enter token and optional domain"
 read -p "Ngrok Token: " token
 read -p "Ngrok Domain: " domain
 
 ngrok config add-authtoken $token
 
 # Chạy ngrok
 if [ -z "$domain" ]; then
     # Không custom domain
     ngrok http 80 > /dev/null &
 else
     # Có custom domain
     ngrok http --domain="$domain" 80 > /dev/null &
 fi
 
 # Lưu PID của ngrok để tiện quản lý
 NGROK_PID=$!
 
 echo "Waiting ngrok to start..."
 sleep 8
 
 # Lấy URL từ ngrok
 EXTERNAL_IP=$(curl -s http://localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url")
 echo "Ngrok URL: $EXTERNAL_IP"
 
 # Ghi vào file .env
 echo "EXTERNAL_IP=$EXTERNAL_IP" > .env
 echo "CURR_DIR=$(pwd)" >> .env

 echo "Start docker compose up"
 export EXTERNAL_IP
 export CURR_DIR=$(pwd)
 sudo -E docker compose up -d
 
 echo "Finish! Access n8n at $EXTERNAL_IP"
 