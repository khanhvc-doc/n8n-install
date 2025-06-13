```bash
#!/bin/bash
# Cài đặt Nginx
sudo apt update
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Tạo thư mục lưu chứng chỉ SSL
sudo mkdir -p /etc/ssl/n8n
cd /etc/ssl/n8n

# Tải file cấu hình OpenSSL
sudo wget https://raw.githubusercontent.com/khanhvc-doc/n8n-install/master/Ubuntu/http-to-https/openssl-n8n.cnf

# Tạo chứng chỉ SSL tự ký
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/n8n/n8n.key -out /etc/ssl/n8n/n8n.crt -config /etc/ssl/n8n/openssl-n8n.cnf

# Tạo file cấu hình Nginx
sudo bash -c 'cat > /etc/nginx/sites-available/n8n << EOL
server {
    listen 80;
    server_name n8n.hansollvina.com hansollvina.com localhost;

    # Chuyển hướng tất cả HTTP sang HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name n8n.hansollvina.com hansollvina.com localhost;

    ssl_certificate /etc/ssl/n8n/n8n.crt;
    ssl_certificate_key /etc/ssl/n8n/n8n.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL'

# Kích hoạt cấu hình
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/

# Kiểm tra và khởi động lại Nginx
sudo nginx -t
sudo systemctl restart nginx

# Mở port 443 trên tường lửa
sudo ufw allow 443
```
