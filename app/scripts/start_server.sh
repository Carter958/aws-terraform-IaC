#!/bin/bash

# Change to the directory where package.json is located
cd /var/www/html

# Start the server
npm start &

# Wait for the server to start
timeout=60
while ! curl -s http://localhost:3000 > /dev/null; do
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "Server failed to start within the timeout period"
    exit 1
  fi
  sleep 1
done

echo "Server is running on http://localhost:3000"