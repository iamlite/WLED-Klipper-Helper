#!/bin/sh

# Ensure script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Fixed directory and list of macros
search_dir="/usr/data/printer_data/config"
base_dir="/usr/data/WLED-Klipper-Helper"
macros="START_PRINT END_PRINT PAUSE CANCEL RESUME"

# Max number of rejections allowed
max_rejections=5
rejection_count=0

# Check if the directory exists
if [ ! -d "$search_dir" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

# Temporary file for storing findings and a file to store confirmed macros
temp_file=$(mktemp)
confirmed_macros_file="$base_dir/confirmed_macros.txt"

# Initialize or clear the confirmed macros file
echo "" > "$confirmed_macros_file"

# Process each macro one by one
for macro in $macros; do
    echo "Searching for $macro in $search_dir..."
    grep -RIHn "^\s*\[gcode_macro\s\+$macro\]" "$search_dir" > "$temp_file"
    # Check if the temporary file has contents
    if [ ! -s "$temp_file" ]; then
        echo "No active instances of $macro found."
        continue
    fi

    # Review found macros with the user
    echo "Review the found instances of $macro:"
    while IFS=: read -r file line_number content; do
        # Ensure the line number calculations stay within valid file bounds
        total_lines=$(wc -l < "$file")
        start_line=$line_number
        end_line=$((line_number+10)) # Showing 10 lines after the found line for better context
        if [ "$end_line" -gt "$total_lines" ]; then
            end_line=$total_lines
        fi

        echo "--------------------------------"
        echo "Macro: $content"
        echo "Preview of macro content starting at line $line_number in file $file:"
        sed -n "${start_line},${end_line}p" "$file"
        echo "--------------------------------"
        echo "Confirm this is correct (y/n): "
        read confirm </dev/tty
        if [ "$confirm" = "y" ]; then
            echo "Confirmed for modification. Saving..."
            echo "$file:$line_number:$content" >> "$confirmed_macros_file"
            rejection_count=0 # Reset rejection count on confirmation
        else
            echo "Skipped modification."
            rejection_count=$((rejection_count + 1))
            if [ "$rejection_count" -ge "$max_rejections" ]; then
                echo "Max rejections reached. Moving to next macro."
                break
            fi
        fi
    done < "$temp_file"
    # Cleanup the temporary file after each macro
    echo "" > "$temp_file"
done

# Cleanup and finish
rm "$temp_file"
echo "Process completed. Confirmed macros are stored in $confirmed_macros_file"
read -p "Press enter to continue..."
