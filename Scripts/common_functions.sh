#!/bin/sh

################################
########### VARIABLES ##########
################################


# VERSIONNUMBER=$(curl -s "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/master/VERSION")
# COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "Unknown")
# VERSION="$VERSIONNUMBER ($COMMIT_HASH)"
AUTHOR="Tariel Davidashvili"
GITHUB="https://github.com/iamlite/WLED-Klipper-Helper"
WIKI="https://github.com/iamlite/WLED-Klipper-Helper/wiki"


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

RAINBOW_COLORS="$RED $YELLOW $GREEN $CYAN $BLUE $MAGENTA"

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
    print_ascii_line "${RAINBOW_COLORS[idx%6]}    _   _  _   ___ __     _  ___   _ ___ ___ ___ ___    _  _ ___ _   ___ ___ ___  ${NC}"
    idx=$((idx+1))
    print_ascii_line "${RAINBOW_COLORS[idx%6]}   | | | || | | __| _\\ __| |/ / | | | _,\\ _,\\ __| _ \\__| || | __| | | _,\\ __| _ \\ ${NC}"
    idx=$((idx+1))
    print_ascii_line "${RAINBOW_COLORS[idx%6]}   | 'V' || |_| _|| v |__|   <| |_| | v_/ v_/ _|| v /__| >< | _|| |_| v_/ _|| v / ${NC}"
    idx=$((idx+1))
    print_ascii_line "${RAINBOW_COLORS[idx%6]}   !_/ \\_!|___|___|__/   |_|\\_\\___|_|_| |_| |___|_|_\\  |_||_|___|___|_| |___|_|_\\ ${NC}"
}


