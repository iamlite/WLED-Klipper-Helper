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

# Function to display the stored presets with options A, B, C, etc., and an option to return to the main menu
show_presets() {
    print_item "$MAGENTA""Current WLED Presets: "
    i=0
    while IFS= read -r line; do
        if [ $i -gt 0 ]; then
            print_spacer
        fi
        char=$(awk -v num=$i 'BEGIN {printf "%c", 65 + num}')
        print_nospaces "$char: $line"
        i=$((i + 1))
    done < "$config_file"
    print_spacer
    print_nospaces "X: Return to main menu"
    print_separator
}

# Function to edit a preset or return to the main menu
edit_preset() {
    print_input_item "$MAGENTA""Enter the letter of the preset you want to edit (A, B, C, ..., X for main menu):"
    read choice
    choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')  # Normalize input
    if [ "$choice" = "X" ]; then
        return  # Exit the function to stop the loop and potentially return to a higher menu
    fi
    line_num=$(printf "%d" "'$choice")
    line_num=$((line_num - 65 + 1))
    if [ $line_num -gt 0 ] && [ $line_num -le $i ]; then
        event_name=$(sed -n "${line_num}p" "$config_file" | cut -d':' -f1)
        print_input_item "$MAGENTA""Enter the new preset number for $event_name: "
        read new_number
        while ! echo "$new_number" | grep -E -q '^[0-9]+$'; do
            print_item "$RED""Invalid input. Please enter a valid preset number: "
            read new_number
        done
        sed -i "${line_num}s/^$event_name: .*$/$event_name: $new_number/" "$config_file"
        [ $? -eq 0 ] && print_item "$GREEN""Preset updated successfully!" || print_item "$RED""Failed to update preset."
    else
        print_input_item "$RED""Invalid choice. Please enter a valid letter (A, B, C, ..., X for main menu):"
    fi
}

# Main logic
while true; do
    clear
    if [ -f "$config_file" ]; then
        show_presets
        edit_preset
    else
        print_item "$RED""No presets found. Please add some."
        break
    fi
done

print_item "$MAGENTA""Press enter to return to the main menu..."
read dummy
