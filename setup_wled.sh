#!/bin/sh

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validate IP address format
validate_ip() {
    while ! echo "$1" | grep -E -q '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; do
        printf "${RED}Invalid IP address format. Please ensure it is in the form x.x.x.x where x is 0-255:${NC}\n"
        printf "${YELLOW}Enter WLED IP address again: ${NC}"
        read ip
        set -- "$ip"
    done
}

# Validate numerical input
validate_number() {
    while ! echo "$1" | grep -E -q '^[0-9]+$'; do
        printf "${RED}Invalid number entered. Please ensure it is a positive integer:${NC}\n"
        printf "${YELLOW}Enter the number again: ${NC}"
        read num
        set -- "$num"
    done
}

# Function to add WLED configuration to moonraker.conf
add_wled_config() {
    conf_file="/usr/data/printer_data/config/moonraker.conf" 

    # Check if the entry already exists
    if grep -q "^\[wled $1\]$" "$conf_file"; then
        printf "${RED}Configuration for WLED instance '$1' already exists in moonraker.conf.${NC}\n"
        return 1
    fi

    # Append configuration to the file
    printf "\n[wled $1]\ntype: http\naddress: $2\nchain_count: $3\ninitial_preset: $4\n" >> "$conf_file"
    if [ $? -eq 0 ]; then
        printf "${GREEN}WLED configuration added successfully.${NC}\n"
    else
        printf "${RED}Failed to write to moonraker.conf. Check file permissions and path.${NC}\n"
        return 1
    fi
}

# Main logic
printf "${YELLOW}Enter your WLED instance name (e.g., keled): ${NC}"
read wled_name
printf "${YELLOW}Enter WLED IP address (e.g., x.x.x.x): ${NC}"
read wled_ip

# IP validation
validate_ip "$wled_ip"

printf "${YELLOW}Enter the number of LEDs on the strip: ${NC}"
read led_count

# LED count validation
validate_number "$led_count"

printf "${YELLOW}Enter the initial preset number (that will turn on with the printer): ${NC}"
read preset_num

# Preset number validation
validate_number "$preset_num"

# Call function to add the WLED configuration
add_wled_config "$wled_name" "$wled_ip" "$led_count" "$preset_num"
