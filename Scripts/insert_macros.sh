#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Determine the script's directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration and script paths
CONFIRMED_MACROS_FILE="$BASE_DIR/Config/confirmed_macros.txt"
PRESET_ASSIGNMENTS_FILE="$BASE_DIR/Config/presets.conf"

echo "Script directory: $SCRIPT_DIR"
echo "Base directory: $BASE_DIR"

# Check existence of necessary files
if [ ! -f "$CONFIRMED_MACROS_FILE" ] || [ ! -f "$PRESET_ASSIGNMENTS_FILE" ]; then
    printf "${RED}Necessary configuration files are missing. Exiting.${NC}\n"
    read dummy
    exit 1
fi

# Function to read and apply presets from file
apply_preset() {
    local preset_key="$1"
    local preset_value
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
    local position="$3" # 'start', 'after', 'end'
    local match_pattern="$4"

    local preset_value=$(apply_preset "$preset_key")
    local insert_text="\tUPDATE_WLED PRESET=$preset_value" # Tab added for indentation

    echo "Attempting to update file: $file"
    if [ "$position" = "start" ]; then
        # Insert after macro definition start (after "gcode:")
        sed -i "/$match_pattern/a $insert_text" "$file" && echo "Inserted after $match_pattern: $insert_text"
    elif [ "$position" = "after" ] && [ -n "$match_pattern" ]; then
        # Insert immediately after the specific pattern
        sed -i "/$match_pattern/a $insert_text" "$file" && echo "Inserted after $match_pattern: $insert_text"
    elif [ "$position" = "end" ]; then
        # Insert before the end of macro (before next macro definition or file end)
        sed -i "/\[gcode_macro/!b;n;/\[gcode_macro\|$/i $insert_text" "$file" && echo "Inserted at end of macro: $insert_text"
    fi
}

# Read each confirmed macro entry
while IFS=':' read -r file line_number content; do
    macro_name=$(echo "$content" | grep -oE '\[gcode_macro\s+\w+\]' | cut -d ' ' -f 2 | tr -d '[]')
    echo "Processing macro: $macro_name in file $file"
    case "$macro_name" in
        "START_PRINT")
            insert_wled_update "$file" "Heating" "start" "gcode:"
            insert_wled_update "$file" "Printing" "end" 
            ;;
        "PAUSE")
            insert_wled_update "$file" "Pause" "start"
            ;;
        "RESUME")
            insert_wled_update "$file" "Resume" "start"
            insert_wled_update "$file" "Printing" "end"
            ;;
        "END_PRINT")
            insert_wled_update "$file" "Complete" "start"
            ;;
        "CANCEL_PRINT")
            insert_wled_update "$file" "Cancel" "start"
            ;;
    esac
done < "$CONFIRMED_MACROS_FILE"

printf "${GREEN}All modifications completed.${NC}\n"
printf "${CYAN}Press enter to continue...${NC}\n"
read dummy
