#!/bin/sh

# ASCII Art and Header
printf "\033[0;34m%s\033[0m\n" "WLED Klipper Helper Installation"

# Check if Git is installed and install it if not
if ! command -v git &> /dev/null
then
    printf "\033[0;33m%s\033[0m\n" "Git is not installed. Installing..."
    apt-get update && apt-get install -y git
    if [ $? -eq 0 ]; then
        printf "\033[0;32m%s\033[0m\n" "Git has been installed."
    else
        printf "\033[0;31m%s\033[0m\n" "Failed to install Git."
        exit 1
    fi
fi

# Define default installation directory and repository URL
DEFAULT_INSTALL_DIR="/usr/data/WLED-Klipper-Helper"
REPO_URL="https://github.com/iamlite/WLED-Klipper-Helper.git"
CONFIG_FILE="Config/settings.conf" 

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    printf "\033[0;31m%s\033[0m\n" "Error: This script must be run as root."
    exit 1
fi

# Use environment variable or default for the installation directory
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

printf "\033[0;33m%s\033[0m\n" "Installation directory is set to $INSTALL_DIR"

# Clone the repository first into a temporary location
TEMP_DIR=$(mktemp -d)
printf "\033[0;32m%s\033[0m\n" "Cloning repository to temporary directory $TEMP_DIR..."
git clone "$REPO_URL" "$TEMP_DIR"
printf "\033[0;32m%s\033[0m\n" "Repository cloned."

# Ensure the configuration directory exists
mkdir -p "$INSTALL_DIR"
if mkdir -p "$(dirname "$INSTALL_DIR/$CONFIG_FILE")"; then
    printf "\033[0;32m%s\033[0m\n" "Configuration directory created at $(dirname "$INSTALL_DIR/$CONFIG_SYS")"
else
    printf "\033[0;31m%s\033[0m\n" "Failed to create configuration directory."
    exit 1
fi

# Move files from temp directory to final installation directory
mv "$TEMP_DIR"/* "$INSTALL_DIR"
rm -rf "$TEMP_DIR"

# Write the installation directory to a configuration file
if echo "INSTALL_DIR=$INSTALL_DIR" > "$INSTALL_DIR/$CONFIG_FILE"; then
    printf "\033[0;32m%s\033[0m\n" "Installation directory saved in settings file."
else
    printf "\033[0;31m%s\033[0m\n" "Failed to write installation directory to settings file."
    exit 1
fi

# Set permissions for all scripts
printf "\033[0;34m%s\033[0m\n" "Setting executable permissions on scripts..."
find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Output instruction for starting the menu
printf "\033[0;36m%s\033[0m\n" "Setup complete. To run the main menu, execute:"
printf "\033[0;35m%s\033[0m\n" "$INSTALL_DIR/Scripts/menu.sh"
