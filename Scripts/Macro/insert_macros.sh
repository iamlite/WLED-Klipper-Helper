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

# Configuration and script paths
CONFIRMED_MACROS_FILE="$BASE_DIR/Config/confirmed_macros.txt"
PRESET_ASSIGNMENTS_FILE="$BASE_DIR/Config/presets.conf"

frame

# Ensure script is run as root
if [ "$(id -u)" != "0" ]; then
    print_item "${RED}This script must be run as root${NC}\n" 1>&2
    exit 1
fi

# Check existence of necessary files
if [ ! -f "$CONFIRMED_MACROS_FILE" ] || [ ! -f "$PRESET_ASSIGNMENTS_FILE" ]; then
    print_item "${RED}Necessary configuration files are missing. Exiting.${NC}\n"
    read dummy
    exit 1
fi

# Function to read and apply presets from file
apply_preset() {
    local preset_key="$1"
    local preset_value=""
    while IFS=': ' read -r key value; do
        if [ "$key" = "$preset_key" ]; then
            preset_value="$value"
            break
        fi
    done < "$PRESET_ASSIGNMENTS_FILE"
    echo "$preset_value"
}

# Function to insert WLED update line into the macro file
insert_wled_update() {
    local file="$1"
    local preset_key="$2"
    local match_pattern="$3"
    local start_line="$4"

    local preset_value=$(apply_preset "$preset_key")
    local insert_text="  UPDATE_WLED PRESET=$preset_value"
    local in_macro=0
    local insert_done=0

    print_nospaces "Attempting to update file: $file in macro starting at line $start_line"

    if [ "$match_pattern" = "end_macro" ]; then
        awk -v line_num="$start_line" -v insert_text="$insert_text" '
            NR == line_num {in_macro=1}
            /^\[gcode_macro/ && NR > line_num {in_macro=0; if (!insert_done) {print insert_text; insert_done=1}}
            in_macro && index($0, insert_text) {exit 1}
            {print}
            END {if (in_macro && !insert_done) print insert_text}
        ' "$file" > "$file.tmp"

        if [ $? -eq 0 ]; then
            mv "$file.tmp" "$file"
            print_nospaces "Successfully inserted for $preset_key in $file."
        else
            print_item "Skipped insertion for $preset_key as it already exists in $file."
        fi
    else
        awk -v line_num="$start_line" -v pattern="$match_pattern" -v insert_text="$insert_text" '
            NR == line_num {p=1}
            p && $0 ~ pattern && !insert_done {print; print insert_text; insert_done=1; next}
            p && index($0, insert_text) {exit 1}
            {print}
        ' "$file" > "$file.tmp"

        if [ $? -eq 0 ]; then
            mv "$file.tmp" "$file"
            print_nospaces "Successfully inserted for $preset_key in $file."
        else
            print_item "Skipped insertion for $preset_key as it already exists in $file."
        fi
    fi
}


# Reading entries and processing updates
while IFS=':' read -r file line_number content; do
    macro_name=$(echo "$content" | grep -oE '\[gcode_macro\s+\w+\]' | cut -d ' ' -f 2 | tr -d '[]')
    clear
    frame
    print_nospaces "Processing macro: $macro_name in file $file at line $line_number"
    case "$macro_name" in
        "START_PRINT")
            insert_wled_update "$file" "Heating" "CLEAR_PAUSE" "$line_number"
            insert_wled_update "$file" "Printing" "end_macro" "$line_number"
            ;;
        "PAUSE")
            insert_wled_update "$file" "Pause" "gcode:" "$line_number"
            ;;
        "RESUME")
            insert_wled_update "$file" "Resume" "gcode:" "$line_number"
            ;;
        "END_PRINT")
            insert_wled_update "$file" "Complete" "gcode:" "$line_number"
            ;;
        "CANCEL_PRINT")
            insert_wled_update "$file" "Cancel" "gcode:" "$line_number"
            ;;
    esac
done < "$CONFIRMED_MACROS_FILE"

print_nospaces "${GREEN}All modifications completed.${NC}\n"
print_nospaces "${CYAN}Press enter to continue...${NC}\n"
read dummy
