#!/bin/bash

# Update system and install required tools
sudo apt-get update -y
sudo apt-get install -y nginx curl git

# Install Node.js and PM2
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2

# Create app directory (as ubuntu user)
sudo -u ubuntu mkdir -p /home/ubuntu/nodeapp
cd /home/ubuntu/nodeapp

# Create sample Node.js app (as ubuntu user)
cat <<EOF | sudo -u ubuntu tee /home/ubuntu/nodeapp/app.js
const http = require('http');
const port = 3000;
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.end("Hello from Node.js!");
});
server.listen(port);
EOF

# PM2 startup and app launch (as ubuntu)
sudo -u ubuntu -i bash <<'EOF'
cd /home/ubuntu/nodeapp
pm2 start app.js
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu
EOF

# Nginx reverse proxy config
cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Restart Nginx
sudo systemctl restart nginx
