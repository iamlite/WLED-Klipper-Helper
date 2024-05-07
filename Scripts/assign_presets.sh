#!/bin/sh

# Config file and directory
config_dir="/usr/data/WLED-Klipper-Helper/Config"
config_file="$config_dir/presets.conf"

# Introductory message
show_intro() {
    printf "\033[35mWLED Klipper Setup Helper\033[0m\n"
    printf "\033[33m---------------------------\033[0m\n"
    printf "\033[32mWe will be adding presets to WLED.\033[0m\n"
    printf "To begin, open your WLED instance and navigate to the \"Presets\" tab.\n"
    printf "Click on the \"Add Preset\" button.\n"
    printf "This script will guide you to create the necessary presets for various printer statuses/events.\n"
    printf "You can then modify the preset numbers as needed.\n\n"
    printf "Please create a preset in WLED for the following events:\n"
    printf "\033[33mIdle - When the printer is idle\n"
    printf "Pause - When the print is paused\n"
    printf "Cancel - When the print is cancelled\n"
    printf "Resume - When the print is resumed\n"
    printf "Complete - When the print is completed\n"
    printf "Heating - When the printer is heating up\n"
    printf "Homing - When the printer is homing\n"
    printf "Printing - When the printer is actively printing\033[0m\n\n"
}

# Ensure the configuration directory exists
check_and_create_dir() {
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        if [ $? -ne 0 ]; then
            printf "\033[31mFailed to create configuration directory. Please check permissions.\033[0m\n"
            exit 1
        fi
    fi
}

# Function to read preset numbers from user and write to config file
read_and_store_presets() {
    > "$config_file"  # Clear the config file to start fresh
    for event in "Idle" "Pause" "Cancel" "Resume" "Complete" "Heating" "Homing" "Printing"; do
        printf "\033[35mEnter the preset number for $event: \033[0m"
        read preset_num
        # Validate the input is a number
        while ! echo "$preset_num" | grep -E -q '^[0-9]+$'; do
            printf "\033[31mInvalid input. Please enter a valid preset number:\033[0m\n"
            printf "\033[35mEnter the preset number for $event: \033[0m"
            read preset_num
        done
        # Write to config file
        echo "$event: $preset_num" >> "$config_file"
    done
    printf "\033[32mAll presets have been recorded successfully.\033[0m\n"
}

# Main logic
clear
show_intro
check_and_create_dir
printf "\033[34mPress enter when you are ready to continue...\033[0m"
read dummy
read_and_store_presets
