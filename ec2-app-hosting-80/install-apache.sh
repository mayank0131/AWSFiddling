#!/bin/bash

# Logging starts
exec > >(tee -a /var/log/userdata.log) 2>&1
set -x

echo "===== User data script started ====="

# Wait for apt locks (prevents failure due to background updates)
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
      sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
      sudo fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
  echo "Waiting for apt lock..."
  sleep 5
done

# Wait for internet connectivity
until ping -c1 archive.ubuntu.com &>/dev/null; do
  echo "Waiting for internet..."
  sleep 5
done

# Update and install
sudo apt-get update -y
sudo apt-get install apache2 -y

# Enable and start apache
sudo systemctl enable apache2
sudo systemctl start apache2

# Add a test page
echo "It's the app landing page" | sudo tee /var/www/html/index.html
