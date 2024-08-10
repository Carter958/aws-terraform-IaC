#!/bin/bash
# Create the target directory if it doesn't exist
mkdir -p /var/www/html

# Navigate to the application directory
cd /var/www/html || { echo "Directory /var/www/html not found"; exit 1; }

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Node.js dependencies
npm install
