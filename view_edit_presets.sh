#!/bin/sh

# Config file path
config_file="/usr/data/klipperwled/config/presets.conf"

# Function to display the stored presets with options A, B, C, etc.
show_presets() {
    printf "\033[32mCurrent WLED Presets:\033[0m\n"
    i=0
    while IFS= read -r line; do
        char=$(awk "BEGIN {printf \"%c\", 65+$i}") # Convert index to ASCII letter (A, B, C...)
        printf "$char: %b\n" "$line"
        i=$((i + 1))
    done < "$config_file"
    printf "\033[33m---------------------------\033[0m\n"
}

# Function to edit a preset
edit_preset() {
    printf "\033[35mEnter the letter of the event you want to edit (A, B, C, ...):\033[0m\n"
    read choice
    # Convert letter to line number
    line_num=$(printf "%d" "'$choice")
    line_num=$((line_num - 65 + 1))

    if [ $line_num -gt 0 ] && [ $line_num -le $i ]; then
        # Get the event name from the line
        event_name=$(sed -n "${line_num}p" "$config_file" | cut -d':' -f1)
        printf "\033[35mEnter the new preset number for $event_name:\033[0m\n"
        read new_number
        while ! echo "$new_number" | grep -E -q '^[0-9]+$'; do
            printf "\033[31mInvalid input. Please enter a valid preset number:\033[0m\n"
            read new_number
        done
        # Update the preset in the file
        sed -i "${line_num}s/^$event_name: .*$/$event_name: $new_number/" "$config_file"
        if [ $? -eq 0 ]; then
            printf "\033[32mPreset updated successfully.\033[0m\n"
        else
            printf "\033[31mFailed to update preset. Check your permissions or path.\033[0m\n"
        fi
    else
        printf "\033[31mInvalid selection. Please enter a valid letter.\033[0m\n"
    fi
}

# Main logic
clear
if [ -f "$config_file" ]; then
    show_presets
    edit_preset
else
    printf "\033[31mNo preset configuration file found. Please run setup first.\033[0m\n"
fi

printf "\033[34mPress enter to return to the menu...\033[0m\n"
read dummy
