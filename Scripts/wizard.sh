#!/bin/sh

########################################################################
########################################################################
########################################################################

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

# Config Directory
config_dir="${BASE_DIR}/Config"

# Search directory for configurations
search_dir="/usr/data/printer_data/config"
########################################################################
########################################################################
########################################################################


# Function to wait for user input to continue
continue_prompt() {
    print_item "${GREEN}Press enter to continue...${NC}"
    read dummy
}

# Ensure all scripts are executable
print_separator
print_item "Setting script permissions..." $BLUE
chmod +x "${SCRIPT_DIR}"/*.sh
print_item "Permissions set. Continuing with the wizard." $GREEN



# Step 1: Delegate WLED setup to setup_wled.sh
print_separator
print_item "Configuring WLED..." $YELLOW
"${SCRIPT_DIR}/WLED/setup_wled.sh"
continue_prompt

# Step 2: Handle presets
print_separator
print_item "Handling presets for printer events..." $MAGENTA

# Function to check if all presets have values
check_presets() {
    while IFS= read -r line; do
        # Trim leading and trailing whitespace and check if the line ends with a colon
        trimmed_line=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')
        if [[ "$trimmed_line" =~ :$ ]]; then
            return 1  # Return failure if any line ends with a colon (indicating no value assigned)
        fi
    done < "${BASE_DIR}/Config/presets.conf"
    return 0  # Return success if all lines have values
}

if [ -s "${BASE_DIR}/Config/presets.conf" ] && check_presets; then
    print_item "Presets already defined. Skipping preset assignment." $GREEN
else
    print_item "No presets found or some presets are empty. Let's assign some presets." $RED
    "${SCRIPT_DIR}/WLED/assign_presets.sh"
fi


# Step 3: Search and confirm macros
print_separator
print_item "Searching for user macros..." $BLUE

# Check if the confirmed_macros.txt exists and has exactly 5 lines in the config directory
if [ -s "${config_dir}/confirmed_macros.txt" ] && [ $(wc -l < "${config_dir}/confirmed_macros.txt") -eq 5 ]; then
    print_item "All necessary macros have been found and confirmed:" $GREEN
    cat "${config_dir}/confirmed_macros.txt"
else
    print_item "Searching for macros..." $RED
    "${SCRIPT_DIR}/Macro/macro_search.sh" "${config_dir}" # Assuming macro_search.sh can take a directory as an argument
fi

# Step 4: Insert macros
print_separator
print_item "Inserting macros..." $CYAN
"${SCRIPT_DIR}/Macro/insert_macros.sh"

# Completion message
print_separator
print_item "Wizard completed successfully :-)" $GREEN
print_spacer
