#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$(realpath "$0")")" # Determines the absolute path of the directory of this script

# Function to print a horizontal line separator
print_separator() {
    local separator_length=$(stty size | awk '{print $2}')
    local separator_char="="
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
    printf "${CYAN}||${NC}\n"
}

# Function to print menu items with a double border on the left
print_menu_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
}

print_spacer() {
    printf "${CYAN}||${NC}\n"
}

# Function to display the main menu with spacing
show_main_menu() {
    clear
    print_separator
    print_menu_item "WLED Klipper Helper Script" "$GREEN"
    print_separator
    print_spacer
    print_menu_item "1. WLED Setup Wizard" "$YELLOW"
    print_spacer
    print_separator
    print_menu_item "If this is your first time running the script, please select option 1." "$GREEN"
    print_menu_item "Below are manual configuration options for your convenience." "$GREEN"
    print_separator
    print_spacer
    print_menu_item "2. Configure WLED with Moonraker" "$BLUE"
    print_spacer
    print_menu_item "3. Assign WLED Presets" "$BLUE"
    print_spacer
    print_menu_item "4. Macro Menu" "$BLUE"
    print_spacer
    print_separator
    print_spacer
    print_menu_item "Q. Quit" "$RED"
    print_spacer
    print_separator
    print_spacer
    printf "${CYAN}||${NC} ${MAGENTA}Please enter your choice: ${NC}"
}



# Function to show the macro menu
show_macro_menu() {
    clear
    print_separator
    print_spacer
    print_menu_item "WLED Klipper Helper Macro Configurator" "$GREEN"
    print_spacer
    print_separator
    print_spacer
    print_menu_item "1. Search for Macros" "$YELLOW"
    print_spacer
    print_menu_item "2. Inject WLED Macros" "$YELLOW"
    print_spacer
    print_menu_item "3. Edit Macros" "$YELLOW"
    print_spacer
    print_separator
    print_spacer
    print_menu_item "B. Back" "$RED"
    print_spacer
    print_separator
    print_spacer
    printf "${CYAN}||${NC} ${MAGENTA}Please enter your choice: ${NC}"
}



# Confirmation before proceeding
confirm_proceed() {
    printf "${BLUE}Selection: $1.${NC}\n"
    printf "${MAGENTA}$2${NC}\n"
    printf "${GREEN}Proceed? (y/n): ${NC}"
    read yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        sh "${SCRIPT_DIR}/$3" # Execute the script using its absolute path
    else
        printf "${RED}Action cancelled by the user.${NC}\n"
    fi
}

# Macro menu loop
macro_menu_loop() {
    while true; do
        show_macro_menu
        read -p "" macro_choice  # This will put user input on the same line as "Please enter your choice"
        case $macro_choice in
            1) $SCRIPT_DIR/macro_search.sh ;;
            2) $SCRIPT_DIR/insert_macros.sh ;;
            3) $SCRIPT_DIR/edit_macros.sh ;;
            b|B) return ;;
            *) printf "${RED}Invalid choice. Please try again.${NC}\n" ;;
        esac
    done
}

# Main loop
while true; do
    show_main_menu
    read -p "" choice  # This will put user input on the same line as "Please enter your choice"
    case "$choice" in
        1) sh "${SCRIPT_DIR}/wizard.sh" ;;
        2) confirm_proceed "Setup WLED" "This will configure your WLED instance with Moonraker. It will add your WLED instance to moonraker.conf." "setup_wled.sh" ;;
        3) confirm_proceed "Assign WLED Presets" "This will help you create and configure presets in your WLED setup for various printer events like pause, cancel, or resume." "assign_presets.sh" ;;
        4) macro_menu_loop; continue ;;  # Skips the rest of the loop, including the "Press enter to continue" prompt
        q|Q) printf "${BLUE}Exiting...${NC}\n"; break ;;
        *) printf "${RED}Invalid option, try again...${NC}\n" ;;
    esac
    printf "${BLUE}Press enter to continue...${NC}\n"
    read dummy
done
