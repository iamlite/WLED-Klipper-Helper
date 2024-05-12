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

# Config file path
config_file="$BASE_DIR/Config/presets.conf"

# Function to display the stored presets with options A, B, C, etc.
show_presets() {
    print_item "\033[32mCurrent WLED Presets:\033[0m\n"
    i=0
    while IFS= read -r line; do
        # Use awk to convert index to ASCII letter (A, B, C...)
        char=$(awk -v num=$i 'BEGIN {printf "%c", 65 + num}')
        print_nospaces "$char: $line\n"
        i=$((i + 1))
    done < "$config_file"
    print_separator
}

# Function to edit a preset
edit_preset() {
    print_input_item "$MAGENTA""Enter the letter of the preset you want to edit (A, B, C, etc.):"
    read choice
    # Convert letter to line number
    line_num=$(printf "%d" "'$choice")
    line_num=$((line_num - 65 + 1))

    if [ $line_num -gt 0 ] && [ $line_num -le $i ]; then
        # Get the event name from the line
        event_name=$(sed -n "${line_num}p" "$config_file" | cut -d':' -f1)
        print_input_item "\033[35mEnter the new preset number for $event_name:\033[0m\n"
        read new_number
        while ! echo "$new_number" | grep -E -q '^[0-9]+$'; do
            print_item "\033[31mInvalid input. Please enter a valid preset number:\033[0m\n"
            read new_number
        done
        # Update the preset in the file
        sed -i "${line_num}s/^$event_name: .*$/$event_name: $new_number/" "$config_file"
        if [ $? -eq 0 ]; then
            print_item "\033[32mPreset updated successfully.\033[0m\n"
        else
            print_item "\033[31mFailed to update preset. Check your permissions or path.\033[0m\n"
        fi
    else
        print_input_item "\033[31mInvalid selection. Please enter a valid letter.\033[0m\n"
    fi
}

# Main logic
clear
if [ -f "$config_file" ]; then
    show_presets
    edit_preset
else
    print_item "\033[31mNo preset configuration file found. Please run setup first.\033[0m\n"
fi

print_item "\033[34mPress enter to return to the menu...\033[0m\n"
read dummy
