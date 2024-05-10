#!/bin/sh

# ASCII Art and Header
printf "\033[0;34m%s\033[0m\n" "WLED Klipper Helper Installation"

# Define default installation directory and repository URL
DEFAULT_INSTALL_DIR="/usr/data/WLED-Klipper-Helper"
REPO_URL="https://github.com/iamlite/WLED-Klipper-Helper.git"
CONFIG_FILE="/Config/settings.conf"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    printf "\033[0;31m%s\033[0m\n" "Error: This script must be run as root."
    exit 1
fi

# Ask user for the installation directory
printf "\033[0;33m%s\033[0m\n" "Default installation directory is $DEFAULT_INSTALL_DIR"
printf "\033[0;33m%s\033[0m" "Would you like to change the installation directory? [Y/N]: "
read user_choice

if [ "$user_choice" = "y" ] || [ "$user_choice" = "Y" ]; then
    printf "\033[0;33m%s\033[0m" "Enter new installation directory: "
    read user_added_dir
    INSTALL_DIR="$user_added_dir"
else
    INSTALL_DIR="$DEFAULT_INSTALL_DIR"
fi

# Remove existing installation directory if it exists
if [ -d "$INSTALL_DIR" ]; then
    printf "\033[0;33m%s\033[0m\n" "The directory $INSTALL_DIR already exists. Removing..."
    rm -rf "$INSTALL_DIR"
fi

# Create the installation directory
mkdir -p "$INSTALL_DIR"

# Clone the repository
printf "\033[0;32m%s\033[0m\n" "Cloning repository to $INSTALL_DIR..."
git clone "$REPO_URL" "$INSTALL_DIR"
printf "\033[0;32m%s\033[0m\n" "Repository cloned."

# Set permissions for all scripts
printf "\033[0;34m%s\033[0m\n" "Setting executable permissions on scripts..."
find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Write the installation directory to a configuration file
mkdir -p "$(dirname "$CONFIG_file")"
echo "INSTALL_DIR=$INSTALL_DIR" > "$CONFIG_FILE"

# Output instruction for starting the menu
printf "\033[0;36m%s\033[0m\n" "Setup complete. To run the main menu, execute:"
printf "\033[0;35m%s\033[0m\n" "$INSTALL_DIR/Scripts/menu.sh"
