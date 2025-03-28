#!/bin/bash
# Filename: file_manager.sh
# Description: An interactive file management tool using a menu-driven interface.

echo "File Management Menu"
echo "===================="

# List files in the current directory
files=(*)
if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No files found in the current directory."
    exit 1
fi

# Define menu options (removed "Quit" from visible options)
PS3="Select an action (enter the number, or 0 to quit): "
options=("List Files" "Delete File" "Copy File" "Move File" "View File")

# Main menu loop
select action in "${options[@]}"; do
    # Check if user entered 0 to quit
    if [ "$REPLY" = "0" ]; then
        echo "Exiting File Management Menu."
        exit 0
    fi

    case $action in
        "List Files")
            echo "Files in current directory:"
            ls -l
            ;;
        "Delete File")
            echo "Available files:"
            printf '%s\n' "${files[@]}"
            read -p "Enter the file to delete: " target
            if [ -f "$target" ]; then
                rm -f "$target" && echo "File '$target' deleted successfully."
            else
                echo "Error: File '$target' not found."
            fi
            ;;
        "Copy File")
            echo "Available files:"
            printf '%s\n' "${files[@]}"
            read -p "Enter the file to copy: " source
            read -p "Enter the destination path: " dest
            if [ -f "$source" ]; then
                cp "$source" "$dest" && echo "File copied to '$dest'."
            else
                echo "Error: File '$source' not found."
            fi
            ;;
        "Move File")
            echo "Available files:"
            printf '%s\n' "${files[@]}"
            read -p "Enter the file to move: " source
            read -p "Enter the destination path: " dest
            if [ -f "$source" ]; then
                mv "$source" "$dest" && echo "File moved to '$dest'."
            else
                echo "Error: File '$source' not found."
            fi
            ;;
        "View File")
            echo "Available files:"
            printf '%s\n' "${files[@]}"
            read -p "Enter the file to view: " target
            if [ -f "$target" ]; then
                cat "$target"
            else
                echo "Error: File '$target' not found."
            fi
            ;;
        *)
            echo "Error: Invalid selection. Please choose a valid option (1-${#options[@]}) or 0 to quit."
            ;;
    esac
    echo "===================="
done

