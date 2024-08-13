#!/bin/bash
# Validate service script

# Wait for a few seconds to ensure the server has time to start
sleep 10

# Example: Checking if the server is running
if curl -f http://localhost:3000; then
  echo "Server is running."
else
  echo "Server is not running."
  exit 1
fi