#!/bin/bash
# Stop server script

# Stopping a Node.js server
if pkill -f node; then
  echo "Node.js server stopped successfully."
else
  echo "Failed to stop the Node.js server or no Node.js process found."
  exit 1
fi