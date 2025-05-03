#!/bin/bash

#setup_python_env.sh

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Python and pip
echo "Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv python3-full

# Create and activate virtual environment
echo "Creating virtual environment..."
python3 -m venv ~/python_env

echo "Activating virtual environment..."
source ~/python_env/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

echo "Done."
echo "Run: source ~/python_env/bin/activate"
echo "Then: pip install <package_name>"
echo "To exit: deactivate"
