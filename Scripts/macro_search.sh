#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Ensure script is run as root
if [ "$(id -u)" != "0" ]; then
    printf "${RED}This script must be run as root${NC}\n" 1>&2
    exit 1
fi

# Directory for configuration and macros
search_dir="/usr/data/printer_data/config"
base_dir="/WLED-Klipper-Helper/Config"

# Create the directory if it does not exist
mkdir -p "$base_dir"

# List of macros
macros="START_PRINT END_PRINT PAUSE CANCEL RESUME"

# Max number of rejections allowed
max_rejections=5
rejection_count=0

# Check if the directory exists
if [ ! -d "$search_dir" ]; then
    printf "${RED}Error: Directory $search_dir does not exist.${NC}\n"
    exit 1
fi

# Temporary file for storing findings and a file to store confirmed macros
temp_file=$(mktemp)
confirmed_macros_file="$base_dir/confirmed_macros.txt"

# Initialize or clear the confirmed macros file
echo "" > "$confirmed_macros_file"

# Process each macro one by one
for macro in $macros; do
    printf "${GREEN}Searching for $macro in $search_dir...${NC}\n"
    grep -RIHn "^\s*\[gcode_macro\s\+$macro\]" "$search_dir" > "$temp_file"
    if [ ! -s "$temp_file" ]; then
        printf "${YELLOW}No active instances of $macro found.${NC}\n"
        continue
    fi

    printf "${CYAN}Review the found instances of $macro:${NC}\n"
    while IFS=: read -r file line_number content; do
        total_lines=$(wc -l < "$file")
        start_line=$line_number
        end_line=$((line_number+10))
        if [ "$end_line" -gt "$total_lines" ]; then
            end_line=$total_lines
        fi

        printf "${CYAN}--------------------------------${NC}\n"
        printf "${GREEN}Macro: $content${NC}\n"
        printf "${CYAN}Preview of macro content starting at line $line_number in file $file:${NC}\n"
        sed -n "${start_line},${end_line}p" "$file"
        printf "${CYAN}--------------------------------${NC}\n"
        printf "${GREEN}Confirm this is correct (y/n/q to quit): ${NC}"
        read confirm </dev/tty
        if [ "$confirm" = "q" ] || [ "$confirm" = "Q" ]; then
            printf "${RED}Quitting process as requested.${NC}\n"
            break 2  # Exit from both loops
        elif [ "$confirm" = "y" ]; then
            printf "${YELLOW}Confirmed for modification. Saving...${NC}\n"
            echo "$file:$line_number:$content" >> "$confirmed_macros_file"
            rejection_count=0
        else
            printf "${RED}Skipped modification.${NC}\n"
            rejection_count=$((rejection_count + 1))
            if [ "$rejection_count" -ge "$max_rejections" ]; then
                printf "${RED}Max rejections reached. Moving to next macro.${NC}\n"
                break
            fi
        fi
    done < "$temp_file"
    echo "" > "$temp_file"
done

# Cleanup and finish
rm "$temp_file"
if [ -s "$confirmed_macros_file" ]; then
    printf "${GREEN}Process completed. Confirmed macros are stored in $confirmed_macros_file${NC}\n"
else
    printf "${YELLOW}No macros confirmed for modification.${NC}\n"
fi
printf "${CYAN}Press enter to continue...${NC}\n"
read dummy
