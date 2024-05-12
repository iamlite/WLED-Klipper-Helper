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


echo "KLIPPER_CONFIG_DIR is set to $KLIPPER_CONFIG_DIR"
echo "Base directory is set to $BASE_DIR"
echo "INSTALL_DIR is set to $INSTALL_DIR"

echo "Path to script directory is $SCRIPT_DIR"
echo "Path to moonraker.conf is $conf_file"
echo "Path to printer.cfg is $PRINTER_CFG"
echo "Path to settings.conf is $SETTINGS_FILE"


########################################################
########################################################
########################################################

validate_ip() {
    while ! echo "$1" | grep -E -q '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; do
        print_item "${RED}Invalid IP address format. Please ensure it is in the form x.x.x.x where x is 0-255:${NC}\n"
        print_item "${YELLOW}Enter WLED IP address again: ${NC}"
        read ip
        set -- "$ip"
    done
}

validate_number() {
    while ! echo "$1" | grep -E -q '^[0-9]+$'; do
        print_item "${RED}Invalid number entered. Please ensure it is a positive integer:${NC}\n"
        print_item "${YELLOW}Enter the number again: ${NC}"
        read num
        set -- "$num"
    done
}

check_existing_instances() {
    if grep -q '^\[wled ' "$conf_file"; then
        print_item "${YELLOW}Existing WLED instances found. Do you want to add another? (yes/no): ${NC}"
        read add_new
        if [ "$add_new" = "yes" ]; then
            return 1
        else
            print_item "${YELLOW}Select an instance to configure from the list below:${NC}"
            grep '^\[wled ' "$conf_file" | cut -d ' ' -f 2 | tr -d '[]'
            read selected_instance
            wled_name=$selected_instance
            return 0
        fi
    else
        print_item "${GREEN}No existing WLED instances found. Continuing to add new instance.${NC}"
        return 1
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
    print_item "${GREEN}WLED configuration added for $1.${NC}"
}

### MAIN SCRIPT LOGIC

check_existing_instances
if [ $? -eq 1 ]; then
    print_input_item "${YELLOW}Enter a name for the new WLED instance (e.g., my_wled): ${NC}"
    read wled_name
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

# Create a symbolic link in the Klipper config directory
ln -s "$BASE_DIR/Config/WLED_Macros.cfg" "$KLIPPER_CONFIG_DIR/WLED_Macros.cfg"

print_nospaces "Macro file created and linked successfully."

# Check if the line already exists to avoid duplicates
if grep -q "\[include WLED_Macro.cfg\]" "$PRINTER_CFG"; then
    print_item "Include line for WLED_Macro.cfg already exists in printer.cfg."
else
    # Add the include line right after the last include in the top section
    awk '
        BEGIN {printed=0}
        /^\[include / && !printed {last_include=NR}
        {print}
        END {if (last_include) {print "[include WLED_Macro.cfg]"} else {print "[include WLED_Macro.cfg]"}}
    ' "$PRINTER_CFG" >"$PRINTER_CFG.tmp" && mv "$PRINTER_CFG.tmp" "$PRINTER_CFG"

    print_item "Include line for WLED_Macro.cfg added to printer.cfg."
fi

print_item "${GREEN}All done! Press enter to continue...${NC}\n"
read dummy
