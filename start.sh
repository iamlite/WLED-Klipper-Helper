#!/bin/sh

################################
############ COLORS ############
################################


# Basic Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold Colors
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Dimmed (Lower Intensity) Colors
DIM_BLACK='\033[2;30m'
DIM_RED='\033[2;31m'
DIM_GREEN='\033[2;32m'
DIM_YELLOW='\033[2;33m'
DIM_BLUE='\033[2;34m'
DIM_MAGENTA='\033[2;35m'
DIM_CYAN='\033[2;36m'
DIM_WHITE='\033[2;37m'

# Underlined Text
UNDERLINE_BLACK='\033[4;30m'
UNDERLINE_RED='\033[4;31m'
UNDERLINE_GREEN='\033[4;32m'
UNDERLINE_YELLOW='\033[4;33m'
UNDERLINE_BLUE='\033[4;34m'
UNDERLINE_MAGENTA='\033[4;35m'
UNDERLINE_CYAN='\033[4;36m'
UNDERLINE_WHITE='\033[4;37m'

# Background Colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# High Intensity Background Colors
BG_IBLACK='\033[0;100m'
BG_IRED='\033[0;101m'
BG_IGREEN='\033[0;102m'
BG_IYELLOW='\033[0;103m'
BG_IBLUE='\033[0;104m'
BG_IMAGENTA='\033[0;105m'
BG_ICYAN='\033[0;106m'
BG_IWHITE='\033[0;107m'

# No Color (to reset to default)
NC='\033[0m'


###########################################
############ STYLING FUNCTIONS ############
###########################################


print_separator() {
    local separator_length=$(stty size | awk '{print $2}')
    local separator_char="="
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
    printf "${CYAN}||${NC}\n"
}


print_menu_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
}

print_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
    printf "${CYAN}||${NC}\n"
}

print_input_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}||${NC} ${color}${item}${NC}"
}

print_spacer() {
    printf "${CYAN}||${NC}\n"
}

print_ascii_line() {
    printf "${CYAN}||${NC} $1\n"
}


#########################################
############### FUNCTIONS ###############
#########################################


print_ascii_art() {
    local idx=0
    
    for line in "    _   _  _   ___ __     _  ___   _ ___ ___ ___ ___    _  _ ___ _   ___ ___ ___  " \
                "   | | | || | | __| _\\ __| |/ / | | | _,\\ _,\\ __| _ \\__| || | __| | | _,\\ __| _ \\ " \
                "   | 'V' || |_| _|| v |__|   <| |_| | v_/ v_/ _|| v /__| >< | _|| |_| v_/ _|| v / " \
                "   !_/ \\_!|___|___|__/   |_|\\_\\___|_|_| |_| |___|_|_\\  |_||_|___|___|_| |___|_|_\\ "
    do
        case $idx in
            0) printf "${CYAN}||${NC}""${BOLD_BLUE}%s${NC}\n" "$line";;
            1) printf "${CYAN}||${NC}""${BOLD_RED}%s${NC}\n" "$line";;
            2) printf "${CYAN}||${NC}""${BOLD_CYAN}%s${NC}\n" "$line";;
            3) printf "${CYAN}||${NC}""${BOLD_YELLOW}%s${NC}\n" "$line";;
            4) printf "${CYAN}||${NC}""${BOLD_BLUE}%s${NC}\n" "$line";;
            5) printf "${CYAN}||${NC}""${BOLD_MAGENTA}%s${NC}\n" "$line";;
        esac
        idx=$((idx + 1))
    done
}


#########################################
###########   ### LOOP ###   ############
#########################################

clear
print_spacer
print_ascii_art
print_spacer

    # Check if Git is installed
    if command -v git > /dev/null 2>&1; then
        echo "Git is already installed."
    else
        echo "Git is not installed. Installing Git..."
    
        # Check for the presence of known package managers and attempt to install Git
        if [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y git
        elif [ -f /etc/redhat-release ]; then
        sudo yum install -y git
        elif [ -f /etc/arch-release ]; then
        sudo pacman -Syu --noconfirm git
        elif [ -f /etc/SuSE-release ]; then
        sudo zypper install -y git
        elif command -v brew > /dev/null 2>&1; then
        brew install git
        elif [ -f /etc/alpine-release ]; then
        sudo apk add git
        elif command -v opkg > /dev/null 2>&1; then
        sudo opkg install git
        else
        echo "No supported package manager found. Please install Git manually."
        return 1
    fi
    
    echo "Git has been installed."
    fi


# Define default installation directory and repository URL
DEFAULT_INSTALL_DIR="/usr/data/WLED-Klipper-Helper"
REPO_URL="https://github.com/iamlite/WLED-Klipper-Helper.git"
CONFIG_FILE="Config/settings.conf"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    print_item "Error: This script must be run as root." $RED
    exit 1
fi

# Use environment variable or default for the installation directory
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
print_item "Installation directory is set to $INSTALL_DIR" $YELLOW


# Check if the target directory exists and rename it
if [ -d "$INSTALL_DIR" ]; then
    print_item "The directory $INSTALL_DIR already exists. Renaming..." $YELLOW
    count=1
    while [ -d "$INSTALL_DIR.old$count" ]; do
        count=$((count + 1))
    done
    mv "$INSTALL_DIR" "$INSTALL_DIR.old$count"
fi

# Create the installation directory
mkdir -p "$INSTALL_DIR"
print_item "Cloning repository to $INSTALL_DIR..." $GREEN
{ git clone "$REPO_URL" "$INSTALL_DIR" 2>&1; } | while read line; do
    print_item "$line" $GREEN
done
print_item "Repository cloned." $GREEN

# Ensure the configuration directory exists
mkdir -p "$(dirname "$INSTALL_DIR/$CONFIG_FILE")"

# Write the installation directory to a configuration file
if echo "INSTALL_DIR=$INSTALL_DIR" > "$INSTALL_DIR/$CONFIG_FILE"; then
    print_item "Installation directory saved in settings file." $GREEN
else
    print_item "Failed to write installation directory to settings file." $RED
    exit 1
fi

# Set permissions for all scripts
print_item "Setting executable permissions on scripts..." $BLUE
find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;


# Output instruction for starting the menu
print_item "Setup complete. To run the main menu, execute:" $CYAN
print_spacer
print_item "$INSTALL_DIR/Scripts/menu.sh" $MAGENTA
print_spacer