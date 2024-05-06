#!/bin/sh

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$(realpath "$0")")"  # Determines the absolute path of the directory of this script

print_line() {
    printf "${CYAN}%*s\n" 80 | tr ' ' -
}

# Function to display the main menu
show_menu() {
    clear
    echo "Current directory: $(pwd)"
    echo "Listing files in the current directory:"
    ls -l
    print_line
    printf "${GREEN}%s\n" "WLED Klipper Setup Helper"
    print_line
    printf "${YELLOW}%s\n" "1. Setup WLED"
    printf "${YELLOW}%s\n" "2. Setup WLED Presets"
    printf "${YELLOW}%s\n" "3. Add Macros"
    printf "${YELLOW}%s\n" "4. View and Edit Preset Numbers"
    printf "${YELLOW}%s\n" "5. Quit"
    print_line
    printf "${MAGENTA}Please enter your choice: ${NC}"
}

# Function to display a confirmation before proceeding
confirm_proceed() {
    printf "${BLUE}You chose to $1. Here's what this will do:\n${NC}"
    printf "${MAGENTA}$2\n${NC}"
    print_line
    printf "${GREEN}Proceed? (y/n): ${NC}"
    read yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        sh "${SCRIPT_DIR}/$3"  # Execute the script using its absolute path
    else
        printf "${RED}Action cancelled by the user.${NC}\n"
    fi
}

# Main loop
while true; do
    show_menu
    read choice
    case "$choice" in
        1) confirm_proceed "setup WLED" "This will configure your WLED instance including IP address, LED count, and initial presets. It's essential for integrating WLED with your Klipper printer." "setup_wled.sh" ;;
        2) confirm_proceed "setup WLED Presets" "This will help you create and configure presets in your WLED setup for various printer events like pause, cancel, or resume." "setup_presets.sh" ;;
        3) confirm_proceed "add Macros" "This option allows you to search and add specific macros to your printer's configuration, enabling more sophisticated control over your printer's behaviors." "add_macros.sh" ;;
        4) confirm_proceed "view and edit preset numbers" "This allows you to view and modify the preset numbers assigned to different printer states, ensuring they match your current WLED setup." "view_edit_presets.sh" ;;
        5) printf "${BLUE}Exiting...${NC}\n"; break ;;
        *) printf "${RED}Invalid option, try again...${NC}\n" ;;
    esac
    printf "${BLUE}Press enter to continue...${NC}"
    read dummy
done
