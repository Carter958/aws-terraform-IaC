#!/bin/bash

# Change to the directory where package.json is located
cd /var/www/html

# Start the server and redirect output to a log file
npm start > server.log 2>&1 &

# Get the PID of the background process
server_pid=$!

# Wait for the server to start
timeout=60
while ! curl -s http://localhost:3000 > /dev/null; do
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "Server failed to start within the timeout period"
    kill $server_pid
    exit 1
  fi
  sleep 1
done

echo "Server is running on http://localhost:3000"

# Wait for the background process to finish
wait $server_pid