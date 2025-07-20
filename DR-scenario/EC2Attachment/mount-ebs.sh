#!/bin/bash
set -e # Putting this in since we don't want a silent continuation in case of a failure
echo "Waiting for volume attachment"
for i in {1..10}; do
  if [ -b /dev/nvme1n1 ]; then
    echo "Volume attached"
    break
  fi
  echo "Still waiting"
  sleep 5
done
if ! sudo blkid /dev/nvme1n1; then
  echo "No filesystem found - formatting volume"
  sudo mkfs.ext4 /dev/nvme1n1
else
  echo "Filesystem already exists - no need to format"
fi

echo "Mounting to /var/www/html"
sudo mkdir -p /var/www/html
sudo mount /dev/nvme1n1 /var/www/html

# Make the drive persistent across reboots
if ! grep -q '/var/www/html' /etc/fstab; then
  echo '/dev/nvme1n1 /var/www/html ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
fi

echo "<h1> Index file from EBS volume</h1>" | sudo tee -a /var/www/html/index.html

echo "Restarting Apache"
sleep 5
sudo systemctl restart apache2 || true