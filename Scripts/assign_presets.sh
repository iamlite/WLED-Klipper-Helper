#!/bin/sh

# Script directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")" 

# Config file and directory
config_dir="/usr/data/WLED-Klipper-Helper/Config"
config_file="$config_dir/presets.conf"

# Source common functions
. /"$SCRIPT_DIR"/common_functions.sh

# Introductory message
show_intro() {
    print_separator
    print_item "WLED Klipper Setup Helper" "$MAGENTA"
    print_separator
    print_item "We will be adding presets to WLED." "$GREEN"
    print_item "To begin, open your WLED instance and navigate to the \"Presets\" tab."
    print_item "Click on the \"Add Preset\" button."
    print_item "This script will guide you to create the necessary presets for various printer statuses/events."
    print_item "You can then modify the preset numbers as needed."
    print_spacer
    print_item "Please create a preset in WLED for the following events:"
    print_item "Idle - When the printer is idle" "$YELLOW"
    print_item "Pause - When the print is paused" "$YELLOW"
    print_item "Cancel - When the print is cancelled" "$YELLOW"
    print_item "Resume - When the print is resumed" "$YELLOW"
    print_item "Complete - When the print is completed" "$YELLOW"
    print_item "Heating - When the printer is heating up" "$YELLOW"
    print_item "Homing - When the printer is homing" "$YELLOW"
    print_item "Printing - When the printer is actively printing" "$YELLOW"
    print_spacer
}

# Ensure the configuration directory exists
check_and_create_dir() {
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        if [ $? -ne 0 ]; then
            print_item "\033[31mFailed to create configuration directory. Please check permissions.\033[0m\n"
            exit 1
        fi
    fi
}

# Function to read preset numbers from user and write to config file
read_and_store_presets() {
    > "$config_file"  # Clear the config file to start fresh
    for event in "Idle" "Pause" "Cancel" "Resume" "Complete" "Heating" "Homing" "Printing"; do
        print_input_item "Enter the preset number for $event:" "$MAGENTA"
        read preset_num
        # Validate the input is a number
        while ! echo "$preset_num" | grep -E -q '^[0-9]+$'; do
            print_input_item "Invalid input. Please enter a valid preset number:" "$RED"
            print_input_item "Enter the preset number for $event:" "$MAGENTA"
            read preset_num
        done
        # Write to config file
        echo "$event: $preset_num" >> "$config_file"
    done
    print_item "All presets have been recorded successfully." "$GREEN"
}

# Main logic
clear
show_intro
check_and_create_dir
print_item "\033[34mPress enter when you are ready to continue...\033[0m"
read dummy
read_and_store_presets
