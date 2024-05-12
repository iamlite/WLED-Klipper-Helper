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

# Directory for configuration and macros
search_dir="/usr/data/printer_data/config"

# Ensure script is run as root
if [ "$(id -u)" != "0" ]; then
    print_item "${RED}This script must be run as root${NC}\n" 1>&2
    exit 1
fi

# Create the Config directory if it does not exist
mkdir -p "$BASE_DIR"
if [ $? -ne 0 ]; then
    print_item "${RED}Failed to create directory: $BASE_DIR${NC}\n"
    exit 1
else
    print_item "${GREEN}Directory $BASE_DIR created successfully.${NC}\n"
fi

# Check if the Config directory is writable
if [ ! -w "$BASE_DIR" ]; then
    print_item "${RED}Directory $BASE_DIR is not writable.${NC}\n"
    exit 1
else
    print_item "${GREEN}Directory $BASE_DIR is confirmed to be writable.${NC}\n"
fi


# List of macros to search for
macros="START_PRINT END_PRINT CANCEL_PRINT PAUSE RESUME"

# Max number of rejections allowed
max_rejections=5
rejection_count=0

# Check if the search directory exists
if [ ! -d "$search_dir" ]; then
    print_item "${RED}Error: Directory $search_dir does not exist.${NC}\n"
    exit 1
else
    print_item "${GREEN}Directory $search_dir found!${NC}\n"
fi

# Temporary file for storing findings and a file to store confirmed macros
temp_file=$(mktemp)
confirmed_macros_file="$BASE_DIR/Config/confirmed_macros.txt"
print_nospaces "${GREEN}Temporary file for findings: $temp_file${NC}\n"

# Initialize or clear the confirmed macros file
echo "" > "$confirmed_macros_file"
print_nospaces "${GREEN}Initialized confirmed macros file: $confirmed_macros_file${NC}\n"

# Process each macro one by one
for macro in $macros; do
    clear
    print_nospaces "${GREEN}Searching for $macro in $search_dir...${NC}\n"
    grep -RIHn "^\s*\[gcode_macro\s\+$macro\]" "$search_dir" > "$temp_file"
    if [ ! -s "$temp_file" ]; then
        print_item "${YELLOW}No active instances of $macro found.${NC}\n"
        continue
    fi

    print_nospaces "${CYAN}Review the found instances of $macro:${NC}\n"
    while IFS=: read -r file line_number content; do
        total_lines=$(wc -l < "$file")
        start_line=$line_number
        end_line=$((line_number+10))
        if [ "$end_line" -gt "$total_lines" ]; then
            end_line=$total_lines
        fi
        print_nospaces "${GREEN}Macro: $content${NC}\n"
        print_nospaces "${CYAN}Preview of macro content starting at line $line_number in file $file:${NC}\n"
        sed -n "${start_line},${end_line}p" "$file"

        print_input_item "${GREEN}Confirm this is correct (Y/N or Q to quit): ${NC}"
        read confirm </dev/tty
        if [ "$confirm" = "q" ] || [ "$confirm" = "Q" ]; then
            print_item "${RED}Quitting process as requested.${NC}\n"
            break 2  # Exit from both loops
        elif [ "$confirm" = "y" ]; then
            print_item "${YELLOW}Confirmed for modification. Saving...${NC}\n"
            echo "$file:$line_number:$content" >> "$confirmed_macros_file"
            rejection_count=0
        else
            print_item "${RED}Skipped modification.${NC}\n"
            rejection_count=$((rejection_count + 1))
            if [ "$rejection_count" -ge "$max_rejections" ]; then
                print_item "${RED}Max rejections reached. Moving to next macro.${NC}\n"
                break
            fi
        fi
    done < "$temp_file"
    echo "" > "$temp_file"
done

# Cleanup and finish
rm "$temp_file"
if [ -s "$confirmed_macros_file" ]; then
    print_nospaces "${GREEN}Process completed. Confirmed macros are stored in $confirmed_macros_file${NC}\n"
else
    print_nospaces "${YELLOW}No macros confirmed for modification.${NC}\n"
fi
print_input_item "${CYAN}Press enter to continue...${NC}\n"
read dummy
