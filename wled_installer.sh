#!/bin/bash

# Check for necessary commands
commands=("grep" "sed" "awk")
for cmd in "${commands[@]}"; do
    if ! command -v $cmd &>/dev/null; then
        echo "Error: $cmd is not installed." >&2
        exit 1
    fi
done

# Directory for G-code macro files
gcode_dir="/path/to/gcode"

# List of macros to search for
declare -a macros=("Start_print" "End_print" "Cancel" "Pause" "Resume")

# Temporary file for storing findings
temp_file="found_macros.txt"
echo "" >$temp_file # Clear the contents initially

echo "==========================="
echo "   Macro Search Initiated  "
echo "==========================="
echo "Searching for macros..."

# Search for the macros and ignore commented lines
for macro in "${macros[@]}"; do
    grep -rIHn "^\\s*[^;]*\\b$macro\\b" $gcode_dir | sed 's/:/ /g' >>$temp_file
done

# Check if the temporary file has contents
if [ ! -s $temp_file ]; then
    echo "No active macros found."
    exit 1
fi

# Confirm each found macro with the user
echo "==========================="
echo "    Review Found Macros    "
echo "==========================="
while IFS= read -r line; do
    IFS=' ' read -r file line_number content <<<"$line"
    echo "--------------------------------"
    echo "Found: '$content'"
    echo "Location: $file at line $line_number"
    echo "--------------------------------"
    read -p "Confirm this is correct (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        sed -i "/$line/d" $temp_file # Remove unconfirmed entries from the temp file
    fi
done <$temp_file

# Check if there are confirmed macros to modify
if [ ! -s $temp_file ]; then
    echo "No macros confirmed for modification."
    exit 1
fi

echo "==========================="
echo "   Confirmed Macros to Modify  "
echo "==========================="
cat $temp_file

# Cleanup
rm $temp_file
