#!/bin/sh
# Script directory determination
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Source common functions
. "$SCRIPT_DIR/common_functions.sh"

# Function to wait for user input to continue
continue_prompt() {
    printf "${GREEN}Press enter to continue...${NC}"
    read dummy
    print_spacer
}

# Ensure all scripts are executable
print_separator
print_item "Setting script permissions..." $BLUE
chmod +x "${SCRIPT_DIR}"/*.sh
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
