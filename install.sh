#!/bin/sh

# Variables
SCRIPT_NAME="wled_installer.sh"
REPO_URL="https://raw.githubusercontent.com/iamlite/klipperwled/main"
INSTALL_DIR="/usr/data/klipperwled" # e.g., /usr/local/bin

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download the script
curl -s "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"

# Make the script executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Feedback to user
echo "Installation complete. You can run the script with: $INSTALL_DIR/$SCRIPT_NAME"
