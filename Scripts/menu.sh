#!/bin/sh

# Script directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")" # Determines the absolute path of the directory of this script

# Source common functions
. /"$SCRIPT_DIR"/common_functions.sh


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
    print_item "${BLUE}Selection: $1.${NC}\n"
    print_item "${MAGENTA}$2${NC}\n"
    printf "${CYAN}||${NC} ${GREEN}Proceed? (y/n): ${NC}"
    read yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        sh "${SCRIPT_DIR}/$3"
    else
        print_item "${RED}Action cancelled by the user.${NC}\n"
    fi
}

# Macro menu loop
macro_menu_loop() {
    while true; do
        show_macro_menu
        read -p "" macro_choice 
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
    read -p "" choice
    case "$choice" in
        1) sh "${SCRIPT_DIR}/wizard.sh" ;;
        2) confirm_proceed "Setup WLED" "This will configure your WLED instance with Moonraker. It will add your WLED instance to moonraker.conf." "setup_wled.sh" ;;
        3) confirm_proceed "Assign WLED Presets" "This will help you create and configure presets in your WLED setup for various printer events like pause, cancel, or resume." "assign_presets.sh" ;;
        4) macro_menu_loop; continue ;;
        q|Q) printf "${BLUE}Exiting...${NC}\n"; break ;;
        *) printf "${RED}Invalid option, try again...${NC}\n" ;;
    esac
done
