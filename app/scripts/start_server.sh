#!/bin/bash
# Start server script

# Navigate to the application directory
cd /var/www/html || { echo "Directory /var/www/html not found"; exit 1; }

# Start the Node.js server
if npm start; then
  echo "Server started successfully."
else
  echo "Failed to start the server."
  exit 1
fi