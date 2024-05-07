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

# Function to insert WLED update line into the macro file after the 'gcode:' line
insert_wled_update() {
    local file="$1"
    local preset_key="$2"
    local line_number="$3"

    local preset_value=$(apply_preset "$preset_key")
    local insert_text="    UPDATE_WLED PRESET=$preset_value"  # 4 spaces for indentation

    echo "Attempting to update file: $file at line $line_number"
    # Use awk to insert text after 'gcode:' within the macro, ensuring no duplicate lines
    awk -v line_num="$line_number" -v text="$insert_text" -v patt="gcode:" '
    NR==line_num {
        print
        getline
        if ($0 !~ text) {
            print text
        }
        print
        next
    }
    1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# Read each confirmed macro entry
while IFS=':' read -r file line_number content; do
    macro_name=$(echo "$content" | grep -oE '\[gcode_macro\s+\w+\]' | cut -d ' ' -f 2 | tr -d '[]')
    echo "Processing macro: $macro_name in file $file at line $line_number"
    case "$macro_name" in
        "START_PRINT")
            insert_wled_update "$file" "Heating" "$((line_number+1))"
            insert_wled_update "$file" "Printing" "$((line_number+1))"
            ;;
        "PAUSE")
            insert_wled_update "$file" "Pause" "$((line_number+1))"
            ;;
        "RESUME")
            insert_wled_update "$file" "Resume" "$((line_number+1))"
            ;;
        "END_PRINT")
            insert_wled_update "$file" "Complete" "$((line_number+1))"
            ;;
        "CANCEL_PRINT")
            insert_wled_update "$file" "Cancel" "$((line_number+1))"
            ;;
    esac
done < "$CONFIRMED_MACROS_FILE"

printf "${GREEN}All modifications completed.${NC}\n"
printf "${CYAN}Press enter to continue...${NC}\n"
read dummy
