#!/bin/bash

# Update the package list and install dependencies
sudo apt-get update

# Install Node.js and npm
# You can adjust the Node.js version if needed
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify the installation
node -v
npm -v

# Navigate to the application directory
cd /var/www/html

# Install Node.js dependencies
npm install
