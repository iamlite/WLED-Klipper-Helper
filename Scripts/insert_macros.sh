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
    local start_line="$4"  # This is the line number of the macro title

    local preset_value=$(apply_preset "$preset_key")
    local insert_text="  UPDATE_WLED PRESET=$preset_value"  # Using spaces for indentation

    echo "Attempting to update file: $file in macro starting at line $start_line"
    if [ "$match_pattern" = "end_macro" ]; then
        awk -v start_line="$start_line" -v insert_text="$insert_text" '
            BEGIN {inserted = 0}
            NR == start_line {inside_macro = 1}  # Detect start of the macro
            NR > start_line && /^\[gcode_macro/ {inside_macro = 0}  # Detect start of next macro
            inside_macro && !inserted && /^$/ {  # Find the first empty line to insert
                print insert_text;
                inserted = 1;
            }
            {print}
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    else
        awk -v start_line="$start_line" -v match_pattern="$match_pattern" -v insert_text="$insert_text" '
            BEGIN {inserted = 0}
            NR == start_line {inside_macro = 1}  # Detect start of the macro
            NR > start_line && /^\[gcode_macro/ {inside_macro = 0}  # Detect start of next macro
            inside_macro && !inserted && $0 ~ match_pattern {  # Match the pattern within the macro
                print $0;
                print insert_text;
                inserted = 1;
                next;
            }
            {print}
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
}

# Reading entries and processing updates
while IFS=':' read -r file line_number content; do
    macro_name=$(echo "$content" | grep -oE '\[gcode_macro\s+\w+\]' | cut -d ' ' -f 2 | tr -d '[]')
    echo "Processing macro: $macro_name in file $file at line $line_number"
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

printf "${GREEN}All modifications completed.${NC}\n"
printf "${CYAN}Press enter to continue...${NC}\n"
read dummy
