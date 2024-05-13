#!/bin/sh

################################
########### VARIABLES ##########
################################


VERSIONNUMBER=$(curl -s "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/master/VERSION")
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
if [ -z "$COMMIT_HASH" ]; then
    VERSION="$VERSIONNUMBER"
else
    VERSION="$VERSIONNUMBER ($COMMIT_HASH)"
fi
AUTHOR="Tariel D. (iamlite)"
GITHUB="https://github.com/iamlite/WLED-Klipper-Helper"
WIKI="https://github.com/iamlite/WLED-Klipper-Helper/wiki"




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

CONFIG_FILE_PATH="$BASE_DIR/Config/settings.conf"

# Check if the configuration file exists and source it
if [ -f "$CONFIG_FILE_PATH" ]; then
    . "$CONFIG_FILE_PATH"
else
    echo "Configuration file not found at $CONFIG_FILE_PATH."
    exit 1
fi


################################
############ COLORS ############
################################


# Basic Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold Colors
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Dimmed (Lower Intensity) Colors
DIM_BLACK='\033[2;30m'
DIM_RED='\033[2;31m'
DIM_GREEN='\033[2;32m'
DIM_YELLOW='\033[2;33m'
DIM_BLUE='\033[2;34m'
DIM_MAGENTA='\033[2;35m'
DIM_CYAN='\033[2;36m'
DIM_WHITE='\033[2;37m'

# Underlined Text
UNDERLINE_BLACK='\033[4;30m'
UNDERLINE_RED='\033[4;31m'
UNDERLINE_GREEN='\033[4;32m'
UNDERLINE_YELLOW='\033[4;33m'
UNDERLINE_BLUE='\033[4;34m'
UNDERLINE_MAGENTA='\033[4;35m'
UNDERLINE_CYAN='\033[4;36m'
UNDERLINE_WHITE='\033[4;37m'

# Background Colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# High Intensity Background Colors
BG_IBLACK='\033[0;100m'
BG_IRED='\033[0;101m'
BG_IGREEN='\033[0;102m'
BG_IYELLOW='\033[0;103m'
BG_IBLUE='\033[0;104m'
BG_IMAGENTA='\033[0;105m'
BG_ICYAN='\033[0;106m'
BG_IWHITE='\033[0;107m'

# No Color (to reset to default)
NC='\033[0m'


###########################################
############ STYLING FUNCTIONS ############
###########################################


print_separator() {
    local separator_length=$(stty size | awk '{print $2}')
    local separator_char="="
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
    printf "${CYAN}||${NC}\n"
}

print_separator_nospaces() {
    local separator_length=$(stty size | awk '{print $2}')
    local separator_char="="
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
}

print_menu_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
}

print_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
    printf "${CYAN}||${NC}\n"
}

print_nospaces() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
}
print_input_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}||${NC} ${color}${item}${NC}"
}

print_spacer() {
    printf "${CYAN}||${NC}\n"
}

print_ascii_line() {
    printf "${CYAN}||${NC} $1\n"
}


frame() {
    print_separator_nospaces
    print_spacer
    print_ascii_art
    print_spacer
    print_separator_nospaces
    print_spacer
}

#########################################
############### FUNCTIONS ###############
#########################################



confirm_proceed() {
    print_item "${BLUE}Selection: $1.${NC}\n"
    print_item "${MAGENTA}$2${NC}\n"
    print_item "${CYAN}||${NC} ${GREEN}Proceed? (y/n): ${NC}"
    read yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        sh "${SCRIPT_DIR}/$3"
    else
        print_item "${RED}Action cancelled by the user.${NC}\n"
    fi
}

print_ascii_art() {
    local idx=0
    
    for line in "    _   _  _   ___ __     _  ___   _ ___ ___ ___ ___    _  _ ___ _   ___ ___ ___  " \
                "   | | | || | | __| _\\ __| |/ / | | | _,\\ _,\\ __| _ \\__| || | __| | | _,\\ __| _ \\ " \
                "   | 'V' || |_| _|| v |__|   <| |_| | v_/ v_/ _|| v /__| >< | _|| |_| v_/ _|| v / " \
                "   !_/ \\_!|___|___|__/   |_|\\_\\___|_|_| |_| |___|_|_\\  |_||_|___|___|_| |___|_|_\\ "
    do
        case $idx in
            0) printf "${CYAN}||${NC}""${BOLD_BLUE}%s${NC}\n" "$line";;
            1) printf "${CYAN}||${NC}""${BOLD_RED}%s${NC}\n" "$line";;
            2) printf "${CYAN}||${NC}""${BOLD_CYAN}%s${NC}\n" "$line";;
            3) printf "${CYAN}||${NC}""${BOLD_YELLOW}%s${NC}\n" "$line";;
            4) printf "${CYAN}||${NC}""${BOLD_BLUE}%s${NC}\n" "$line";;
            5) printf "${CYAN}||${NC}""${BOLD_MAGENTA}%s${NC}\n" "$line";;
        esac
        idx=$((idx + 1))
    done
}
