#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$(realpath "$0")")"  # Determines the absolute path of the directory of this script

# Function to print a horizontal line separator
print_separator() {
    local separator_length=$(stty size | awk '{print $2}')
    local separator_char="="
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
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

# Function to display the add macros menu with spacing. menu is: search, add, edit, rescan, and quit. 
show_menu() {
    clear
    print_separator
    print_spacer
    print_menu_item "WLED Klipper Setup Helper Script" "$GREEN"
    print_spacer
    print_separator
    print_spacer
    print_menu_item "1. Search for Macros" "$YELLOW"
    print_spacer
    print_menu_item "2. Add Macros" "$YELLOW"
    print_spacer
    print_menu_item "3. Edit Macros" "$YELLOW"
    print_spacer
    print_menu_item "4. Rescan Macros" "$YELLOW"
    print_spacer
    print_menu_item "5. Quit" "$YELLOW"
    print_spacer
    print_separator
}

# Main Loop
while true; do
    show_menu
    read -p "Enter your choice: " choice
    case $choice in
        1) $SCRIPT_DIR/macro_search.sh ;;
        2) $SCRIPT_DIR/add_macros.sh ;;
        3) $SCRIPT_DIR/edit_macros.sh ;;
        4) $SCRIPT_DIR/rescan_macros.sh ;;
        5) break ;;
        *) printf "${RED}Invalid choice. Please try again.${NC}\n" ;;
    esac
done
