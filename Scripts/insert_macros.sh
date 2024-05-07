#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration and script paths
CONFIRMED_MACROS_FILE="/WLED-Klipper-Helper/Config/confirmed_macros.txt"
PRESET_ASSIGNMENTS_FILE="/WLED-Klipper-Helper/Config/presets.conf"

# Check existence of necessary files
if [ ! -f "$CONFIRMED_MACROS_FILE" ] || [ ! -f "$PRESET_ASSIGNMENTS_FILE" ]; then
    printf "${RED}Necessary configuration files are missing. Exiting.${NC}\n"
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

    if [ "$position" = "start" ]; then
        # Insert at the start of the file
        sed -i "1i $insert_text" "$file"
    elif [ "$position" = "after" ] && [ -n "$match_pattern" ]; then
        # Insert after the line containing the pattern
        sed -i "/$match_pattern/a $insert_text" "$file"
    elif [ "$position" = "end" ]; then
        # Insert at the end of the file
        echo "$insert_text" >> "$file"
    fi
}

# Read each confirmed macro entry
while IFS=':' read -r file line_number content; do
    macro_name=$(echo "$content" | sed -n 's/^\s*\[gcode_macro\s\+\(\w\+\)\]\s*$/\1/p')
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

        
    esac
done < "$CONFIRMED_MACROS_FILE"

printf "${GREEN}All modifications completed.${NC}\n"
