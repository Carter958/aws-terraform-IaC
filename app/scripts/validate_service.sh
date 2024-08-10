#!/bin/bash
# Validate service script

# Example: Checking if the server is running
if curl -f http://localhost:3000; then
  echo "Server is running."
else
  echo "Server is not running."
  exit 1
fi