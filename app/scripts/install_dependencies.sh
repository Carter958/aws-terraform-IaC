#!/bin/bash
# Create the target directory if it doesn't exist
mkdir -p /var/www/html

# Navigate to the application directory
cd /var/www/html || { echo "Directory /var/www/html not found"; exit 1; }

# Install Node.js and npm
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install Node.js dependencies
npm install