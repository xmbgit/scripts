#!/bin/sh

# Purpose: Execute arp command with a user-selected network interface.

# Retrieve list of available network interfaces, excluding loopback (lo)
interfaces=$(ip link show | grep -v 'lo:' | awk -F: '{print $2}' | awk '{print $1}' | grep -v '^$')

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

# Execute arp command with the selected interface
echo "Executing arp -nx -i $interface -l -a"
arp '-nxla -i' "$interface" '-l -a'

# Verify command execution success
if [ $? -eq 0 ]; then
    echo "Command completed successfully."
else
    echo "Error encountered while executing arp command."
    exit 1
fi

exit 0
