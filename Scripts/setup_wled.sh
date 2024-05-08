#!/bin/sh

# Script directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")" # Determines the absolute path of the directory of this script

# Source common functions
. /"$SCRIPT_DIR"/common_functions.sh

# Validate IP address format
validate_ip() {
    while ! echo "$1" | grep -E -q '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; do
        print_item "${RED}Invalid IP address format. Please ensure it is in the form x.x.x.x where x is 0-255:${NC}\n"
        print_item "${YELLOW}Enter WLED IP address again: ${NC}"
        read ip
        set -- "$ip"
    done
}

# Validate numerical input
validate_number() {
    while ! echo "$1" | grep -E -q '^[0-9]+$'; do
        print_item "${RED}Invalid number entered. Please ensure it is a positive integer:${NC}\n"
        print_item "${YELLOW}Enter the number again: ${NC}"
        read num
        set -- "$num"
    done
}

# Function to add WLED configuration to moonraker.conf
add_wled_config() {
    conf_file="/usr/data/printer_data/config/moonraker.conf" 

    # Check if the entry already exists
    if grep -q "^\[wled $1\]$" "$conf_file"; then
        print_item "${RED}Configuration for WLED instance '$1' already exists in moonraker.conf.${NC}\n"
        return 1
    fi

    # Append configuration to the file
    printf "\n[wled $1]\ntype: http\naddress: $2\nchain_count: $3\ninitial_preset: $4\n" >> "$conf_file"
    if [ $? -eq 0 ]; then
        print_item "${GREEN}WLED configuration added successfully.${NC}\n"
    else
        print_item "${RED}Failed to write to moonraker.conf. Check file permissions and path.${NC}\n"
        return 1
    fi
}

# Main logic for checking existing WLED instances and adding new ones
conf_file="/usr/data/printer_data/config/moonraker.conf" 
print_separator
print_spacer
print_item "${YELLOW}Checking for existing WLED instances...${NC}\n"
print_spacer
if grep -q "wled" "$conf_file"; then
    print_item "${GREEN}Existing WLED configurations found in moonraker.conf:${NC}\n"
    grep "wled" "$conf_file"
    print_item "${YELLOW}Do you want to add another WLED instance? (Y/N): ${NC}"
    read answer
    if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
        print_item "${GREEN}No new WLED instance will be added. Exiting setup.${NC}\n"
        exit 0
    fi
else
    print_item "${GREEN}No existing WLED configurations found. Proceeding with new setup.${NC}\n"
fi

print_input_item "${YELLOW}Enter your WLED instance name (e.g., keled): ${NC}"
read wled_name
print_input_item "${YELLOW}Enter WLED IP address (e.g., x.x.x.x): ${NC}"
read wled_ip

# IP validation
validate_ip "$wled_ip"

print_input_item "${YELLOW}Enter the number of LEDs on the strip: ${NC}"
read led_count

# LED count validation
validate_number "$led_count"

print_input_item "${YELLOW}Enter the initial preset number (that will turn on with the printer): ${NC}"
read preset_num

# Preset number validation
validate_number "$preset_num"

# Call function to add the WLED configuration
add_wled_config "$wled_name" "$wled_ip" "$led_count" "$preset_num"
print_item "${GREEN}All done!${NC}\n"
