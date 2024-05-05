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
echo "Installation complete. Script installed at: $INSTALL_DIR/$SCRIPT_NAME"

# Ask user if they want to run the script
echo "Do you want to run the script now? (y/n)"
read answer

# Check user's response
if [ "$answer" = "y" ]; then
    echo "Running The Script now: $INSTALL_DIR/$SCRIPT_NAME"
    # Run the script
    "$INSTALL_DIR/$SCRIPT_NAME"
else
    echo "Script installation complete. You can run the script later by executing: $INSTALL_DIR/$SCRIPT_NAME"
fi
