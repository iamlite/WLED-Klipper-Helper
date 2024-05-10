#!/bin/sh

# ASCII Art and Header
printf "\033[0;34m%s\033[0m\n" "WLED Klipper Helper Installation"

# Check if Git is installed and install it if not
if ! command -v git &> /dev/null
then
    printf "\033[0;33m%s\033[0m\n" "Git is not installed. Installing..."
    apt-get update && apt-get install -y git
    printf "\033[0;32m%s\033[0m\n" "Git has been installed."
fi

# Define default installation directory and repository URL
DEFAULT_INSTALL_DIR="/usr/data/WLED-Klipper-Helper"
REPO_URL="https://github.com/iamlite/WLED-Klipper-Helper.git"
CONFIG_FILE="Config/settings.conf"  # Changed the path to save inside Config folder

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    printf "\033[0;31m%s\033[0m\n" "Error: This script must be run as root."
    exit 1
fi

# Use environment variable or default for the installation directory
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

printf "\033[0;33m%s\033[0m\n" "Installation directory is set to $INSTALL_DIR"

# Ensure the configuration directory exists
mkdir -p "$(dirname "$INSTALL_DIR/$CONFIG_FILE")"

# Write the installation directory to a configuration file
echo "INSTALL_DIR=$INSTALL_DIR" > "$INSTALL_DIR/$CONFIG_FILE"

# Check if the target directory exists and clear it
if [ -d "$INSTALL_DIR" ]; then
    printf "\033[0;33m%s\033[0m\n" "The directory $INSTALL_DIR already exists. Removing..."
    rm -rf "$INSTALL_DIR"
fi

# Create the installation directory
mkdir -p "$INSTALL_DIR"

printf "\033[0;32m%s\033[0m\n" "Cloning repository to $INSTALL_DIR..."
git clone "$REPO_URL" "$INSTALL_DIR"
printf "\033[0;32m%s\033[0m\n" "Repository cloned."

# Set permissions for all scripts
printf "\033[0;34m%s\033[0m\n" "Setting executable permissions on scripts..."
find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Output instruction for starting the menu
printf "\033[0;36m%s\033[0m\n" "Setup complete. To run the main menu, execute:"
printf "\033[0;35m%s\033[0m\n" "$INSTALL_DIR/Scripts/menu.sh"
