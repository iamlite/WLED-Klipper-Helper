#!/bin/sh

########################################################################
########################################################################
########################################################################

# Start from the directory of the current script and find the base directory
DIR=$(dirname "$(realpath "$0")")
while [ "$DIR" != "/" ]; do
    if [ -f "$DIR/VERSION" ]; then
        BASE_DIR=$DIR
        break
    fi
    DIR=$(dirname "$DIR")
done

if [ -z "$BASE_DIR" ]; then
    echo "Failed to find the base directory. Please check your installation." >&2
    exit 1
fi

# Script directory
SCRIPT_DIR="$BASE_DIR/Scripts"

# Source common functions
. "$SCRIPT_DIR/common_functions.sh"

########################################################################
########################################################################
########################################################################

# Apply executable permissions recursively to all .sh files
find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;

SETTINGS_FILE="$BASE_DIR/Config/settings.conf"

check_settings() {

    clear

    # Ensure settings file exists
    [ -f "$SETTINGS_FILE" ] || touch "$SETTINGS_FILE"

    # Default values
    DEFAULT_INSTALL_DIR="/usr/data/WLED-Klipper-Helper"
    DEFAULT_KLIPPER_CONFIG_DIR="/usr/data/printer_data/config"

    # Helper function to update or append setting
    update_or_append_setting() {
        local setting_key=$1
        local setting_value=$2
        local default_value=$3

        # Check if setting exists and is not empty
        if grep -q "^$setting_key=" "$SETTINGS_FILE"; then
            # Setting exists, check if it's empty
            if [ -z "$(grep "^$setting_key=" "$SETTINGS_FILE" | cut -d'=' -f2)" ]; then
                # Setting is empty, update it with user provided or default value
                sed -i "s|^$setting_key=.*|$setting_key=$setting_value|" "$SETTINGS_FILE"
            fi
        else
            # Setting does not exist, append it
            echo "$setting_key=$setting_value" >> "$SETTINGS_FILE"
        fi
    }

    # Check and update INSTALL_DIR
    if [ -z "$INSTALL_DIR" ]; then
        INSTALL_DIR="$DEFAULT_INSTALL_DIR"
    fi
    update_or_append_setting "INSTALL_DIR" "$INSTALL_DIR" "$DEFAULT_INSTALL_DIR"

    # Check and update KLIPPER_CONFIG_DIR
    if [ -z "$KLIPPER_CONFIG_DIR" ]; then
        print_nospaces "KLIPPER_CONFIG_DIR is not set."
        print_nospaces "Enter the path to your Klipper config directory"
        print_input_item "or press enter to use default [$DEFAULT_KLIPPER_CONFIG_DIR]:"
        read -p "> " input_klipper_dir
        KLIPPER_CONFIG_DIR="${input_klipper_dir:-$DEFAULT_KLIPPER_CONFIG_DIR}"
    fi
    update_or_append_setting "KLIPPER_CONFIG_DIR" "$KLIPPER_CONFIG_DIR" "$DEFAULT_KLIPPER_CONFIG_DIR"

    # Ensure moonraker.conf is updated
    update_moonraker_config "$KLIPPER_CONFIG_DIR" "$INSTALL_DIR"
}

update_moonraker_config() {
    local klipper_config_dir=$1
    local install_dir=$2

    # Ensure moonraker.conf exists
    local moonraker_conf="$klipper_config_dir/moonraker.conf"
    [ -f "$moonraker_conf" ] || touch "$moonraker_conf"

    # Define the block of text to add
    local block_text=$(cat <<EOF
[update_manager WLED-Klipper-Helper]
type: git_repo
channel: dev
path: "$INSTALL_DIR"
origin: https://github.com/iamlite/WLED-Klipper-Helper.git
primary_branch: main
managed_services: klipper
EOF
    )

    # Add block of text to moonraker.conf if it does not already exist
    if ! grep -q "\[update_manager WLED-Klipper-Helper\]" "$moonraker_conf"; then
        echo "$block_text" >> "$moonraker_conf"
        print_item "Added WLED-Klipper-Helper update_manager block to moonraker.conf"
    else
        print_item "WLED-Klipper-Helper update_manager block already exists in moonraker.conf"
    fi
}

# Function to display the main menu with spacing
show_main_menu() {
    clear
    frame
    print_menu_item "Version: $VERSION" "$DIM_WHITE"
    print_menu_item "Author: $AUTHOR" "$DIM_WHITE"
    # print_menu_item "GitHub: $GITHUB" "$DIM_WHITE"
    print_menu_item "Wiki: $WIKI" "$DIM_WHITE"
    print_spacer
    print_text_separator "Main Menu"
    print_spacer
    print_menu_item "1. WLED Setup Wizard" "$BOLD_YELLOW"
    print_spacer
    print_separator_nospaces
    print_spacer
    print_menu_item "2. Configure WLED with Moonraker" "$RED"
    print_spacer
    print_menu_item "3. Assign WLED Presets" "$BLUE"
    print_spacer
    print_menu_item "4. Edit WLED Presets" "$CYAN"
    print_separator
    print_menu_item "5. Search for Macros" "$YELLOW"
    print_spacer
    print_menu_item "6. Inject WLED Macros" "$GREEN"
    print_spacer
    print_menu_item "7. Edit Macros (not implemented yet)" "$DIM_CYAN" 
    print_separator
    print_menu_item "Q. Quit" "$RED"
    print_separator
    print_input_item "Please enter your choice: " "$BLUE"
}

check_settings

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
