#!/bin/bash

# Variables
SCRIPT_NAME="wled_installer.sh"
REPO_URL="https://github.com/iamlite/klipperwled/blob/main"
INSTALL_DIR="/usr/data" # e.g., /usr/local/bin

# Download the script
curl -s "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"

# Make the script executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Feedback to user
echo "Installation complete. You can run the script with: $INSTALL_DIR/$SCRIPT_NAME"
