#!/bin/sh

########################################################
#################  FIND BASE DIRECTORY #################
########################################################

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

########################################################
########################################################
########################################################

config_dir="BASE_DIR/Config"
config_file="$config_dir/presets.conf"


show_intro() {
    print_separator
    print_item "Welcome to the WLED Klipper Setup Helper" "$MAGENTA"
    print_separator
    print_nospaces "This guide will help you link WLED lighting presets to specific events on your Klipper 3D printer." "$GREEN"
    print_nospaces "Start by opening your WLED instance in a web browser and navigate to the 'Presets' tab."
    print_nospaces "Click on the 'Add Preset' button to begin creating presets."
    print_nospaces "You will create presets that correspond to various printer events, each triggered by a unique macro."
    print_spacer
    print_item "Please follow these steps to create a preset for each printer status. You can choose any visual effect and color you like for each event:"
    print_item "Idle - The printer is not active." "$YELLOW"
    print_item "Pause - The print has been paused." "$YELLOW"
    print_item "Cancel - The print has been cancelled." "$YELLOW"
    print_item "Resume - The print is resuming." "$YELLOW"
    print_item "Complete - The print has finished successfully." "$YELLOW"
    print_item "Heating - The printer is heating up." "$YELLOW"
    print_item "Homing - The printer is preparing to print by homing its axes." "$YELLOW"
    print_item "Printing - The printer is in the process of printing." "$YELLOW"
    print_spacer
    print_nospaces "Assign each preset a unique number in WLED. This number will be used in your printer's configuration to trigger the correct lighting effect for each event."
    print_spacer
}


check_and_create_dir() {
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        if [ $? -ne 0 ]; then
            print_item "\033[31mFailed to create configuration directory. Please check permissions.\033[0m\n"
            exit 1
        fi
    fi
}


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
