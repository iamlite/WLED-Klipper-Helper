#!/bin/sh

# Script directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Ensure all necessary scripts are executable
chmod +x "$SCRIPT_DIR"/*.sh

# Source common functions
. "$SCRIPT_DIR/common_functions.sh"



print_ascii_art() {
    print_menu_item '    _   _  _   ___ __     _  ___   _ ___ ___ ___ ___    _  _ ___ _   ___ ___ ___  '
    print_menu_item '   | | | || | | __| _\ __| |/ / | | | _,\ _,\ __| _ \__| || | __| | | _,\ __| _ \ '
    print_menu_item '   | '\''V'\'' || |_| _|| v |__|   <| |_| | v_/ v_/ _|| v /__| >< | _|| |_| v_/ _|| v / '
    print_menu_item '   !_/ \_!|___|___|__/   |_|\_\___|_|_| |_| |___|_|_\  |_||_|___|___|_| |___|_|_\ '
}



# Function to display the main menu with spacing
show_main_menu() {
    clear
    print_ascii_art
    print_spacer
    print_separator
    print_spacer
    print_menu_item "Version: $VERSION" "$DIM_WHITE"
    print_menu_item "Author: $AUTHOR" "$DIM_WHITE"
    print_menu_item "GitHub: $GITHUB" "$DIM_WHITE"
    print_menu_item "Wiki: $WIKI" "$DIM_WHITE"
    print_spacer
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
    print_menu_item "4. Search for Macros" "$YELLOW"
    print_spacer
    print_menu_item "5. Inject WLED Macros" "$YELLOW"
    print_spacer
    print_menu_item "6. Edit Macros" "$YELLOW"
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
    4) sh "$SCRIPT_DIR/Macro/macro_search.sh" ;;
    5) sh "$SCRIPT_DIR/Macro/insert_macros.sh" ;;
    6) sh "$SCRIPT_DIR/Macro/edit_macros.sh" ;;
    q|Q) 
        print_input_item "${BLUE}Exiting...${NC}\n"
        break
        ;;
    *) print_input_item "${RED}Invalid option, try again...${NC}\n" ;;
    esac
done
