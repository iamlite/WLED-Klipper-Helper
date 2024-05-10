#!/bin/sh

# Script directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Apply executable permissions recursively to all .sh files
find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Source common functions
. "$SCRIPT_DIR/common_functions.sh"

# Function to display the main menu with spacing
show_main_menu() {
    clear
    print_spacer
    print_ascii_art
    print_spacer
    print_separator
    print_menu_item "Version: $VERSION" "$DIM_WHITE"
    print_menu_item "Author: $AUTHOR" "$DIM_WHITE"
    print_menu_item "GitHub: $GITHUB" "$DIM_WHITE"
    print_menu_item "Wiki: $WIKI" "$DIM_WHITE"
    print_separator
    print_spacer
    print_menu_item "1. WLED Setup Wizard" "$YELLOW"
    print_spacer
    print_separator
    print_spacer
    print_menu_item "2. Configure WLED with Moonraker" "$BLUE"
    print_spacer
    print_menu_item "3. Assign WLED Presets" "$BLUE"
    print_spacer
    print_menu_item "4. Edit WLED Presets" "$BLUE"
    print_spacer
    print_separator
    print_spacer
    print_menu_item "5. Search for Macros" "$YELLOW"
    print_spacer
    print_menu_item "6. Inject WLED Macros" "$YELLOW"
    print_spacer
    print_menu_item "7. Edit Macros" "$YELLOW"
    print_spacer
    print_separator
    print_spacer
    print_menu_item "Q. Quit" "$RED"
    print_spacer
    print_separator
    print_spacer
    print_input_item "${MAGENTA}Please enter your choice: ${NC}"
}

# Main loop
while true; do
    show_main_menu
    read -p "" choice
    case "$choice" in

    1) sh "$SCRIPT_DIR/wizard.sh" ;;
    2) sh "$SCRIPT_DIR/WLED/setup_wled.sh" ;;
    3) sh "$SCRIPT_DIR/WLED/assign_presets.sh" ;;
    4) sh "$SCRIPT_DIR/WLED/edit_presets.sh" ;;
    5) sh "$SCRIPT_DIR/Macro/macro_search.sh" ;;
    6) sh "$SCRIPT_DIR/Macro/insert_macros.sh" ;;
    7) sh "$SCRIPT_DIR/Macro/edit_macros.sh" ;;

    q | Q)
        print_input_item "${BLUE}Exiting...${NC}\n"
        break
        ;;
    *) print_input_item "${RED}Invalid option, try again...${NC}\n" ;;
    esac
done
