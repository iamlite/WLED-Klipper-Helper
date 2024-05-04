#!/bin/sh

# Check for necessary commands
for cmd in grep sed awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is not installed." >&2
        exit 1
    fi
done

# Directory for G-code macro files
gcode_dir="/usr/data/printer_data/config"

# List of macros to search for
macros="START_PRINT END_PRINT CANCEL PAUSE RESUME"

# Temporary file for storing findings
temp_file="found_macros.txt"
echo "" > "$temp_file" # Clear the contents initially

echo "==========================="
echo "   Macro Search Initiated  "
echo "==========================="
echo "Searching for macros..."

# Search for the macros and ignore commented lines
for macro in $macros; do
    grep -rIHn "^\\s*[^;]*\\b$macro\\b" "$gcode_dir" | sed 's/:/ /g' >> "$temp_file"
done

# Check if the temporary file has contents
if [ ! -s "$temp_file" ]; then
    echo "No active macros found."
    exit 1
fi

# Confirm each found macro with the user
echo "==========================="
echo "    Review Found Macros    "
echo "==========================="
temp_confirmed="temp_confirmed.txt"
echo "" > "$temp_confirmed" # Clear the contents initially
while IFS= read -r line; do
    set -- $line
    file=$1
    line_number=$2
    content="$3"
    echo "--------------------------------"
    echo "Found: '$content'"
    echo "Location: $file at line $line_number"
    echo "--------------------------------"
    echo "Confirm this is correct (y/n): "
    read confirm
    if [ "$confirm" = "y" ]; then
        echo "$line" >> "$temp_confirmed"
    fi
done < "$temp_file"

# Check if there are confirmed macros to modify
if [ ! -s "$temp_confirmed" ]; then
    echo "No macros confirmed for modification."
    exit 1
fi

echo "==========================="
echo "   Confirmed Macros to Modify  "
echo "==========================="
cat "$temp_confirmed"

# Cleanup
rm "$temp_file"
rm "$temp_confirmed"
