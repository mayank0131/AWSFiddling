#!/bin/bash
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo systemctl enable apache2
echo "It's the app landing page" | sudo tee /var/www/html/index.html
sudo systemctl start apache2