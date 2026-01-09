#!/bin/bash
# Filename: net_firewall_dashboard.sh
# Description: A comprehensive network and firewall management tool with an interactive menu.

# Ensure the script runs with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be executed with root privileges. Please use sudo."
    exit 1
fi

# Log file for operations
LOG_FILE="/var/log/net_firewall_dashboard.log"
echo "$(date): Script started by $(whoami)" >> "$LOG_FILE"

# Function to check if a command is available
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: Required command '$1' is not installed or not in PATH."
        exit 1
    fi
}

# Verify required commands are available
for cmd in iptables ip nmcli udevadm dnsmasq arp chroot; do
    check_command "$cmd"
done

# Function to add an iptables rule
add_iptables_rule() {
    echo "Adding a new iptables rule"
    read -p "Enter chain (e.g., INPUT, OUTPUT, FORWARD): " chain
    read -p "Enter protocol (e.g., tcp, udp, icmp): " proto
    read -p "Enter destination port (or press Enter to skip): " dport
    read -p "Enter action (e.g., ACCEPT, DROP, REJECT): " action
    read -p "Enter source IP (or press Enter for any): " src_ip

    local rule="iptables -A $chain"
    [ -n "$proto" ] && rule="$rule -p $proto"
    [ -n "$dport" ] && rule="$rule --dport $dport"
    [ -n "$src_ip" ] && rule="$rule -s $src_ip"
    rule="$rule -j $action"

    if eval "$rule"; then
        echo "Rule added successfully: $rule" | tee -a "$LOG_FILE"
    else
        echo "Error: Failed to add rule: $rule" | tee -a "$LOG_FILE"
    fi
}

# Function to list iptables rules
list_iptables_rules() {
    echo "Current iptables rules:"
    iptables -L -v -n --line-numbers
}

# Function to manage network interfaces with ip addr and NetworkManager
manage_interfaces() {
    echo "Network Interface Management"
    PS3="Select an action: "
    options=("List Interfaces" "Enable Interface" "Disable Interface" "Back")
    select opt in "${options[@]}"; do
        case $opt in
            "List Interfaces")
                ip addr show
                nmcli connection show
                ;;
            "Enable Interface")
                read -p "Enter interface name (e.g., eth0): " iface
                if nmcli connection up "$iface"; then
                    echo "Interface $iface enabled" | tee -a "$LOG_FILE"
                else
                    echo "Error: Failed to enable $iface" | tee -a "$LOG_FILE"
                fi
                ;;
            "Disable Interface")
                read -p "Enter interface name (e.g., eth0): " iface
                if nmcli connection down "$iface"; then
                    echo "Interface $iface disabled" | tee -a "$LOG_FILE"
                else
                    echo "Error: Failed to disable $iface" | tee -a "$LOG_FILE"
                fi
                ;;
            "Back")
                break
                ;;
            *)
                echo "Error: Invalid selection."
                ;;
        esac
    done
}

# Function to manipulate ARP table
manage_arp() {
    echo "ARP Table Management"
    PS3="Select an action: "
    options=("Show ARP Table" "Add ARP Entry" "Delete ARP Entry" "Back")
    select opt in "${options[@]}"; do
        case $opt in
            "Show ARP Table")
                arp -n
                ;;
            "Add ARP Entry")
                read -p "Enter IP address: " ip
                read -p "Enter MAC address (XX:XX:XX:XX:XX:XX): " mac
                if arp -s "$ip" "$mac"; then
                    echo "ARP entry added: $ip -> $mac" | tee -a "$LOG_FILE"
                else
                    echo "Error: Failed to add ARP entry" | tee -a "$LOG_FILE"
                fi
                ;;
            "Delete ARP Entry")
                read -p "Enter IP address to delete: " ip
                if arp -d "$ip"; then
                    echo "ARP entry deleted: $ip" | tee -a "$LOG_FILE"
                else
                    echo "Error: Failed to delete ARP entry" | tee -a "$LOG_FILE"
                fi
                ;;
            "Back")
                break
                ;;
            *)
                echo "Error: Invalid selection."
                ;;
        esac
    done
}

# Function to configure dnsmasq
configure_dnsmasq() {
    echo "DNSmasq Configuration"
    read -p "Enter domain name (e.g., example.local): " domain
    read -p "Enter IP range start (e.g., 192.168.1.100): " range_start
    read -p "Enter IP range end (e.g., 192.168.1.200): " range_end

    local config="/etc/dnsmasq.conf"
    {
        echo "domain=$domain"
        echo "dhcp-range=$range_start,$range_end,12h"
    } > "$config"

    if systemctl restart dnsmasq; then
        echo "DNSmasq configured and restarted" | tee -a "$LOG_FILE"
    else
        echo "Error: Failed to restart dnsmasq" | tee -a "$LOG_FILE"
    fi
}

# Function to trigger udev rules
trigger_udev() {
    echo "Triggering udev rules"
    if udevadm trigger; then
        echo "udev rules triggered successfully" | tee -a "$LOG_FILE"
    else
        echo "Error: Failed to trigger udev rules" | tee -a "$LOG_FILE"
    fi
}

# Function to execute a command in a chroot environment
run_in_chroot() {
    echo "Chroot Environment"
    read -p "Enter chroot directory path: " chroot_dir
    read -p "Enter command to execute: " cmd
    if [ -d "$chroot_dir" ]; then
        if chroot "$chroot_dir" /bin/bash -c "$cmd"; then
            echo "Command executed in chroot: $cmd" | tee -a "$LOG_FILE"
        else
            echo "Error: Failed to execute command in chroot" | tee -a "$LOG_FILE"
        fi
    else
        echo "Error: Directory $chroot_dir does not exist" | tee -a "$LOG_FILE"
    fi
}

# Main menu
echo "Network and Firewall Management Dashboard"
echo "========================================"
PS3="Select an option (enter the number): "
options=(
    "Add iptables Rule"
    "List iptables Rules"
    "Manage Network Interfaces"
    "Manage ARP Table"
    "Configure DNSmasq"
    "Trigger udev Rules"
    "Run Command in Chroot"
    "Exit"
)

select choice in "${options[@]}"; do
    case $choice in
        "Add iptables Rule")
            add_iptables_rule
            ;;
        "List iptables Rules")
            list_iptables_rules
            ;;
        "Manage Network Interfaces")
            manage_interfaces
            ;;
        "Manage ARP Table")
            manage_arp
            ;;
        "Configure DNSmasq")
            configure_dnsmasq
            ;;
        "Trigger udev Rules")
            trigger_udev
            ;;
        "Run Command in Chroot")
            run_in_chroot
            ;;
        "Exit")
            echo "Exiting Network and Firewall Management Dashboard."
            echo "$(date): Script terminated" >> "$LOG_FILE"
            exit 0
            ;;
        *)
            echo "Error: Invalid selection. Please choose a valid option."
            ;;
    esac
    echo "========================================"
done