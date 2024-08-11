#!/bin/bash
# Before install script

# Exit immediately if a command exits with a non-zero status
set -e

# Update package repositories
echo "Updating package repositories..."
sudo yum update -y

# Install essential system packages
echo "Installing essential system packages..."
sudo yum install -y git curl

# Any other preparation steps
echo "Running additional preparation steps..."
# e.g., stopping existing services, cleaning up old files, etc.

echo "before_install.sh completed successfully."