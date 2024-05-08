# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color


# Function to print a horizontal line separator
print_separator() {
    local separator_length=$(stty size | awk '{print $2}')
    local separator_char="="
    printf "${CYAN}||${NC}\n"
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
    printf "${CYAN}||${NC}\n"
}

# Function to print menu items with a double border on the left
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