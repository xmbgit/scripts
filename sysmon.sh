#!/bin/bash
# Filename: sys_monitor.sh
# Description: A system monitoring dashboard with interactive options.

echo "System Monitoring Dashboard"
echo "==========================="

# Define menu options
PS3="Select a monitoring option (enter the number): "
options=("CPU Usage" "Memory Usage" "Disk Space" "Running Processes" "Network Status" "Quit")

# Main menu loop
select option in "${options[@]}"; do
    case $option in
        "CPU Usage")
            echo "Current CPU Usage:"
            top -bn1 | grep "%Cpu" | awk '{print "User: "$2"%, System: "$4"%, Idle: "$8"%"}'
            ;;
        "Memory Usage")
            echo "Current Memory Usage:"
            free -h | awk 'NR==2 {print "Total: "$2", Used: "$3", Free: "$4}'
            ;;
        "Disk Space")
            echo "Disk Space Usage:"
            df -h | awk 'NR==1 || $NF=="/" {print $1" "$2" "$3" "$4" "$5}'
            ;;
        "Running Processes")
            echo "Number of Running Processes:"
            ps -e | wc -l
            echo "Top 5 CPU-intensive processes:"
            ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
            ;;
        "Network Status")
            echo "Network Interfaces and Status:"
            ip -brief addr show | awk '{print $1" "$3}'
            echo "Open ports:"
            ss -tuln | awk 'NR>1 {print $1" "$5}'
            ;;
        "Quit")
            echo "Exiting System Monitoring Dashboard."
            exit 0
            ;;
        *)
            echo "Error: Invalid selection. Please choose a valid option."
            ;;
    esac
    echo "==========================="
done