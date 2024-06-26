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

config_dir="$BASE_DIR/Config"
config_file="$config_dir/presets.conf"


show_intro() {
    frame
    print_nospaces "$GREEN""This process will link WLED lighting presets to specific events on your printer."
    print_spacer
    print_nospaces "$GREEN""Start by opening your WLED instance in a web browser and navigate to the 'Presets' tab."
    print_nospaces "$GREEN""Click on the 'Add Preset' button to begin creating presets."
    print_nospaces "$GREEN""Create presets that correspond to various printer events."
    print_nospaces "$GREEN""Assign each preset a unique number in WLED which will be used in the macro to trigger the correct lighting effect for each event."
    print_nospaces "$GREEN""You should choose any visual effect and color you like for each event. "
    print_spacer
    print_nospaces "$MAGENTA""List of presets for you to make:"
    print_spacer
    print_nospaces  "Pause" "$YELLOW"
    print_spacer
    print_nospaces  "Cancel" "$YELLOW"
    print_spacer   
    print_nospaces  "Resume" "$YELLOW"
    print_spacer
    print_nospaces  "Homing" "$YELLOW"
    print_spacer
    print_nospaces  "Idle - Your default state when the printer is idle." "$YELLOW"
    print_spacer
    print_nospaces  "Heating - Make your printer glow fancy red and orange while its heating 0_0" "$YELLOW"
    print_spacer
    print_nospaces  "Printing - Effect when the printer is printing." "$YELLOW"
    print_spacer
    print_nospaces  "Complete - When the print has finished successfully." "$YELLOW"
    print_spacer
    print_input_item "$BLUE""Once you have created all your presets, press enter to continue..."
    read dummy

}


check_and_create_dir() {
    if [ ! -d "$config_dir" ]; then
        print_item "${YELLOW}Config directory not found. Creating it now...${NC}"
        mkdir -p "$config_dir"
        if [ $? -ne 0 ]; then
            print_item "${RED}Failed to create the config directory. Please check your permissions.${NC}"
            exit 1
        fi
    fi
}


read_and_store_presets() {
    > "$config_file"
    for event in "Idle" "Pause" "Cancel" "Resume" "Complete" "Heating" "Homing" "Printing"; do
        clear
        frame
        print_input_item "Enter the preset number for $event: " "$MAGENTA"
        read preset_num
        # Validate the input is a number
        while ! echo "$preset_num" | grep -E -q '^[0-9]+$'; do
            print_item "$RED""Invalid input. Please enter a valid preset number."
            print_input_item "Enter the preset number for $event:" "$GREEN"
            read preset_num
        done
        # Write to config file
        echo "$event: $preset_num" >> "$config_file"
        print_item "Preset for $event has been recorded." "$GREEN"
        print_input_item "Press enter to continue..."
        read dummy
    done
    print_item "All presets have been recorded successfully." "$GREEN"
}

# Main logic
clear
show_intro
check_and_create_dir
read_and_store_presets
