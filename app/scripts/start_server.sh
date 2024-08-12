#!/bin/bash

# Change to the directory where package.json is located
cd /var/www/html || { echo "Failed to change directory"; exit 1; }

# Start the server and redirect output to a log file
npm start > server.log 2>&1 &

# Get the PID of the background process
server_pid=$!

# Output the server status
echo "Server is starting with PID $server_pid. Check server.log for details."

# Exit the script successfully
exit 0