#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Script directory determination
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Function to print a horizontal line separator
print_separator() {
    local separator_length=$(stty size | awk '{print $2}')
    local separator_char="="
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
}

# Function to print items with a double border on the left
print_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
}

print_spacer() {
    printf "${CYAN}||${NC}\n"
}

# Function to wait for user input to continue
continue_prompt() {
    printf "${GREEN}Press enter to continue...${NC}"
    read dummy
    print_spacer
}

# Ensure all scripts are executable
print_separator
print_item "Setting script permissions..." $BLUE
chmod +x "${SCRIPT_DIR}/setup_wled.sh"
chmod +x "${SCRIPT_DIR}/assign_presets.sh"
chmod +x "${SCRIPT_DIR}/macro_search.sh"
chmod +x "${SCRIPT_DIR}/insert_macros.sh"
print_item "Permissions set. Continuing with the wizard." $GREEN

# Search directory for configurations
search_dir="/usr/data/printer_data/config"

# Step 1: Delegate WLED setup to setup_wled.sh
print_separator
print_item "Configuring WLED..." $YELLOW
"${SCRIPT_DIR}/setup_wled.sh"
continue_prompt

# Step 2: Handle presets
print_separator
print_item "Handling presets for printer events..." $MAGENTA
if [ -s "${SCRIPT_DIR}/Config/presets.conf" ]; then
    print_item "Presets already defined. Skipping preset assignment." $GREEN
    continue_prompt
else
    print_item "No presets found. Let's assign some presets." $RED
    "${SCRIPT_DIR}/assign_presets.sh"
    continue_prompt
fi

# Step 3: Search and confirm macros
print_separator
print_item "Searching for user macros..." $BLUE
if [ -s "${search_dir}/confirmed_macros.txt" ] && [ $(wc -l < "${search_dir}/confirmed_macros.txt") -eq 5 ]; then
    print_item "All necessary macros have been found and confirmed:" $GREEN
    cat "${search_dir}/confirmed_macros.txt"
    continue_prompt
else
    print_item "Searching for macros..." $RED
    "${SCRIPT_DIR}/macro_search.sh"
    continue_prompt
fi

# Step 4: Insert macros
print_separator
print_item "Inserting macros..." $CYAN
"${SCRIPT_DIR}/insert_macros.sh"
continue_prompt

# Completion message
print_separator
print_item "Wizard completed successfully :-)" $GREEN
print_spacer
