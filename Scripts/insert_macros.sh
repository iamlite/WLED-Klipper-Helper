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
    read -p "Press enter to continue..."
    exit 1
fi

# Load presets into an associative array
declare -A presets
while IFS=': ' read -r key value; do
    presets[$key]=$value
done < "$PRESET_ASSIGNMENTS_FILE"

# Debug: Print loaded presets
for key in "${!presets[@]}"; do
    printf "Loaded preset: %s = %s\n" "$key" "${presets[$key]}"
done

# Function to insert WLED update line into the macro file
insert_wled_update() {
    local file="$1"
    local insert_text="$2"
    local position="$3" # 'start', 'after', 'end'
    local match_pattern="$4"

    echo "Attempting to update file: $file"
    if [ "$position" = "start" ]; then
        sed -i "1i $insert_text" "$file" && echo "Inserted at start: $insert_text"
    elif [ "$position" = "after" ] && [ -n "$match_pattern" ]; then
        sed -i "/$match_pattern/a $insert_text" "$file" && echo "Inserted after $match_pattern: $insert_text"
    elif [ "$position" = "end" ]; then
        echo "$insert_text" >> "$file" && echo "Inserted at end: $insert_text"
    fi
}

# Read each confirmed macro entry
while IFS=':' read -r file line_number content; do
    macro_name=$(echo "$content" | sed -n 's/^\s*\[gcode_macro\s\+\(\w\+\)\]\s*$/\1/p')
    echo "Processing macro: $macro_name in file $file"
    case "$macro_name" in
        "START_PRINT")
            insert_wled_update "$file" "UPDATE_WLED PRESET=${presets[Heating]}" "after" "CLEAR_PAUSE"
            insert_wled_update "$file" "UPDATE_WLED PRESET=${presets[Printing]}" "end"
            ;;
        "PAUSE")
            insert_wled_update "$file" "UPDATE_WLED PRESET=${presets[Pause]}" "start"
            ;;
        "RESUME")
            insert_wled_update "$file" "UPDATE_WLED PRESET=${presets[Resume]}" "start"
            insert_wled_update "$file" "UPDATE_WLED PRESET=${presets[Printing]}" "end"
            ;;
        "END_PRINT")
            insert_wled_update "$file" "UPDATE_WLED PRESET=${presets[Complete]}" "start"
            ;;
        "CANCEL_PRINT")
            insert_wled_update "$file" "UPDATE_WLED PRESET=${presets[Cancel]}" "start"
            ;;
    esac
done < "$CONFIRMED_MACROS_FILE"

printf "${GREEN}All modifications completed.${NC}\n"
printf "${CYAN}Press enter to continue...${NC}\n"
read dummy
