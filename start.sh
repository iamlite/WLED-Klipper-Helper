#!/bin/sh

# ASCII Art and Colors
echo "\033[1;34m"
echo "WLED Klipper Helper Installation"
echo "\033[0m"

# Define the installation directory and repository URL
INSTALL_DIR="/usr/data/WLED-Klipper-Helper"
REPO_URL="https://github.com/iamlite/WLED-Klipper-Helper.git"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "\033[1;31mError: This script must be run as root.\033[0m"
    exit 1
fi

# Echo commands as they are executed, and exit immediately on error
set -ex

# Clone the repository
if [ -d "$INSTALL_DIR" ]; then
    echo "\033[1;33mThe directory $INSTALL_DIR already exists. Removing...\033[0m"
    rm -rf "$INSTALL_DIR"
fi
echo "\033[1;32mCloning repository to $INSTALL_DIR...\033[0m"
git clone "$REPO_URL" "$INSTALL_DIR"
echo "\033[1;32mRepository cloned.\033[0m"

# Set permissions for all scripts
echo "\033[1;34mSetting executable permissions on scripts...\033[0m"
find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Output instruction for starting the menu
echo "\033[1;36mSetup complete. To run the main menu, execute:\033[0m"
echo "\033[1;35m$INSTALL_DIR/Scripts/Menu/menu.sh\033[0m"
