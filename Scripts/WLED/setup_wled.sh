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

# Paths
SCRIPT_DIR="$BASE_DIR/Scripts"

SETTINGS_FILE="$BASE_DIR/Config/settings.conf"

. "$SCRIPT_DIR/common_functions.sh"
. "$SETTINGS_FILE"

PRINTER_CFG="$KLIPPER_CONFIG_DIR/printer.cfg"

conf_file="$KLIPPER_CONFIG_DIR/moonraker.conf" 




########################################################
########################################################
########################################################

validate_ip() {
    while ! echo "$1" | grep -E -q '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; do
        print_item "${RED}Invalid IP address format. Please ensure it is in the form x.x.x.x where x is 0-255"
        print_input_item "${YELLOW}Enter WLED IP address again: "
        read ip
        set -- "$ip"
    done
}

validate_number() {
    while ! echo "$1" | grep -E -q '^[0-9]+$'; do
        print_item "${RED}Invalid number entered. Please ensure it is a positive integer"
        print_input_item "${YELLOW}Enter the number again: "
        read num
        set -- "$num"
    done
}

validate_name() {
    while ! echo "$1" | grep -E -q '^[a-zA-Z0-9_]+$'; do
        print_item "${RED}Invalid name entered. Please ensure it only contains letters, numbers, and underscores: "
        print_input_item "${YELLOW}Enter the name again: "
        read name
        set -- "$name"
    done
}

check_existing_instances() {
    instances=$(grep '^\[wled ' "$conf_file" | cut -d ' ' -f 2 | tr -d '[]')
    print_item "${YELLOW}Checking for existing WLED instances...${NC}"

    if [ -n "$instances" ]; then
        print_item "${YELLOW}Existing WLED instances found:${NC}"
        echo "$instances" | while IFS= read -r instance; do
            print_nospaces "$instance"
        done
        while true; do
            print_input_item "${YELLOW}Type the name of an instance to use, or hit 'Y' to create a new instance:${NC}"
            read user_choice
            
            if [ "$user_choice" = "y" ] || [ "$user_choice" = "Y" ]; then
                return 1  # Continue to add new instance
            elif echo "$instances" | grep -qw "$user_choice"; then
                wled_name=$user_choice
                print_item "${GREEN}Configuring selected instance: $wled_name${NC}"
                return 0  # Configure the selected instance
            else
                print_item "${RED}Invalid selection. No such instance: $user_choice${NC}"
            fi
        done
    else
        print_item "${GREEN}No existing WLED instances found. Continuing to add new instance.${NC}"
        return 1  # No instances found, continue to add new instance
    fi
}

add_wled_config() {
    if grep -q "^\[wled $1\]$" "$conf_file"; then
        print_item "${RED}Configuration for WLED instance '$1' already exists in moonraker.conf.${NC}\n"
        return 1
    fi
    echo "[wled $1]" >> "$conf_file"
    echo "address: $2" >> "$conf_file"
    echo "led_count: $3" >> "$conf_file"
    echo "preset: $4" >> "$conf_file"
    clear
    frame
    print_item "${GREEN}WLED configuration added for $1.${NC}"
}

### MAIN SCRIPT LOGIC

clear
frame
print_nospaces "$MAGENTA""Initiating WLED configuration script..."
check_existing_instances
if [ $? -eq 1 ]; then
    print_input_item "${YELLOW}Enter a name for the new WLED instance (e.g., my_wled): ${NC}"
    read wled_name
    validate_name "$wled_name"
    print_input_item "${YELLOW}Enter WLED IP address (e.g., x.x.x.x): ${NC}"
    read wled_ip
    validate_ip "$wled_ip"
    print_input_item "${YELLOW}Enter the number of LEDs on the strip: ${NC}"
    read led_count
    validate_number "$led_count"
    print_input_item "${YELLOW}Enter the initial preset number (that will turn on with the printer) - typically its the preset number of the 'Idle' event: ${NC}"
    read preset_num
    validate_number "$preset_num"
    add_wled_config "$wled_name" "$wled_ip" "$led_count" "$preset_num"
fi

# Create the macro file
print_item "${YELLOW}Creating macro file...${NC}"
cat <<EOF >"$BASE_DIR/Config/WLED_Macros.cfg"
[gcode_macro UPDATE_WLED]
description: update wled state
gcode:
  {% set PRESET = params.PRESET | default(0) | int %}
  {action_call_remote_method("set_wled_state", strip="$wled_name", state=True, preset=PRESET)}

[gcode_macro WLED_OFF]
description: Turn WLED off
gcode:
  {% set strip = params.STRIP|string %}
  {action_call_remote_method("set_wled_state", strip="$wled_name", state=False)}
EOF

# Remove the existing symbolic link if it exists
if [ -L "$KLIPPER_CONFIG_DIR/WLED_Macros.cfg" ]; then
    rm "$KLIPPER_CONFIG_DIR/WLED_Macros.cfg"
    print_item "${YELLOW}Removing existing symbolic link...${NC}"
fi

# Create a new symbolic link in the Klipper config directory
print_item "${BLUE}Creating symbolic link...${NC}"
ln -s "$BASE_DIR/Config/WLED_Macros.cfg" "$KLIPPER_CONFIG_DIR/WLED_Macros.cfg"

print_item "${GREEN}Macro file created and linked successfully.${NC}"

# Check if the line already exists to avoid duplicates
if grep -q "\[include WLED_Macro.cfg\]" "$PRINTER_CFG"; then
    print_item "${YELLOW}Include line for WLED_Macro.cfg already exists in printer.cfg.${NC}"
else
    # Find the line number where the first sequence of includes ends
    include_block_end=$(awk '/^\[include/ {last_include = NR; next} /^[^\[#]/ && last_include {print last_include; exit}' "$PRINTER_CFG")

    # Add the include line after the last include in the first sequence
    awk -v line="$include_block_end" 'NR==line {print; print "[include WLED_Macro.cfg]"; next} 1' "$PRINTER_CFG" > "$PRINTER_CFG.tmp" && mv "$PRINTER_CFG.tmp" "$PRINTER_CFG"

    print_item "${GREEN}Include line for WLED_Macro.cfg added to printer.cfg successfully.${NC}"
    print_item "${GREEN}Inserted at line: $include_block_end${NC}"
fi

print_input_item "${GREEN}All done! Press enter to continue...${NC}\n"
read dummy
