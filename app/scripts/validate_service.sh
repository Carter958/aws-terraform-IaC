#!/bin/bash
# Validate service script

# Example: Checking if the server is running
curl -f http://localhost:3000 || exit 1