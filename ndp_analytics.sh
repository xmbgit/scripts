#!/bin/bash

# Purpose: Execute ndp command with a user-selected network interface.

# Retrieve list of available network interfaces, excluding loopback (lo)
interfaces=$(ifconfig | grep -v 'lo[0-9]*:' | grep -E '^[a-zA-Z0-9]+:' | awk -F: '{print $1}' | grep -v '^$')

# Check if any interfaces are available
if [ -z "$interfaces" ]; then
    echo "No network interfaces detected. Exiting."
    exit 1
fi

# Prompt user to select an interface using the select command
echo "Available network interfaces:"
PS3="Select an interface by number: "
select interface in $interfaces; do
    if [ -n "$interface" ]; then
        echo "Selected interface: $interface"
        break
    else
        echo "Invalid selection. Please choose a valid interface."
    fi
done

# Execute ndp command with the selected interface
echo "Executing ndp -i $interface -a"
ndp -i "$interface" -a

# Verify command execution success
if [ $? -eq 0 ]; then
    echo "Command completed successfully."
else
    echo "Error encountered while executing ndp command."
    exit 1
fi

exit 0