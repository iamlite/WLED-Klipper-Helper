#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print an ASCII line border
print_line() {
    echo -e "${CYAN}+--------------------------------------------------------------------------------+${NC}"
}

# Function to print a blank line with border for spacing
print_spacer() {
    echo -e "${CYAN}|${NC}                                                                                ${CYAN}|${NC}"
}

# Function to print centered text within the ASCII border, preserving color
print_centered() {
    local message=$1
    local color=$2
    local len=$((${#message} + ${#color} + ${#NC}))
    printf "${CYAN}|${NC}"
    # Calculate the padding needed to center the text
    printf "${color}%*s" $(( (len + 80) / 2 )) "$message"
    printf "${NC}%*s${CYAN}|${NC}\n" $(( 80 - (len + 80) / 2 )) ""
}

# Function to display the main menu with spacing between options
show_menu() {
    clear
    print_line
    print_spacer
    print_centered "WLED Klipper Setup Helper" "$GREEN"
    print_spacer
    print_line
    print_spacer
    print_centered "1. Setup WLED" "$YELLOW"
    print_spacer
    print_centered "2. Setup WLED Presets" "$YELLOW"
    print_spacer
    print_centered "3. Add Macros" "$YELLOW"
    print_spacer
    print_centered "4. View and Edit Preset Numbers" "$YELLOW"
    print_spacer
    print_centered "5. Quit" "$YELLOW"
    print_spacer
    print_line
    print_spacer
    print_centered "Please enter your choice:" "$MAGENTA"
    print_spacer
}

# Confirmation before proceeding
confirm_proceed() {
    clear
    print_line
    print_spacer
    print_centered "You chose to $1" "$BLUE"
    print_spacer
    print_centered "$2" "$MAGENTA"
    print_spacer
    print_line
    print_spacer
    echo -e "${GREEN}Proceed? (y/n): ${NC}"
    read yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        sh "${SCRIPT_DIR}/$3"  # Execute the script using its absolute path
    else
        echo -e "${RED}Action cancelled by the user.${NC}"
        print_spacer
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
        5) echo -e "${BLUE}Exiting...${NC}"; print_spacer; break ;;
        *) echo -e "${RED}Invalid option, try again...${NC}"; print_spacer ;;
    esac
    print_spacer
    echo -e "${BLUE}Press enter to continue...${NC}"
    read dummy
done
