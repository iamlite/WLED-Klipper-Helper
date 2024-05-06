#!/bin/sh

# Define the installation directory and repository URL
INSTALL_DIR="/usr/data/WLED-Klipper-Helper"
REPO_URL="https://github.com/iamlite/WLED-Klipper-Helper.git"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Echo commands as they are executed, and exit immediately on error
set -ex

# Clone the repository
if [ -d "$INSTALL_DIR" ]; then
    echo "The directory $INSTALL_DIR already exists. Removing..."
    rm -rf "$INSTALL_DIR"
fi
echo "Cloning repository to $INSTALL_DIR..."
git clone "$REPO_URL" "$INSTALL_DIR"
echo "Repository cloned."

# Set permissions for all scripts
echo "Setting executable permissions on scripts..."
find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Output instruction for starting the menu
echo "Setup complete. To run the main menu, execute:"
echo "$INSTALL_DIR/Scripts/Menu/menu.sh"
