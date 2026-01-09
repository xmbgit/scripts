#!/bin/bash

# Process killer script for macOS
# Runs as root, kills processes from a text file every 3 seconds for 60 seconds total

# Configuration
PROCESS_LIST_FILE="/var/root/pkill/pkill.sh"
LOG_FILE="/var/root/pkill/pkill.log"
SCRIPT_TIMEOUT=60
KILL_INTERVAL=3

# Function to log messages with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if script should continue running
should_continue() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    
    if [ $elapsed -ge $SCRIPT_TIMEOUT ]; then
        return 1  # Stop execution
    else
        return 0  # Continue execution
    fi
}

# Main execution starts here
start_time=$(date +%s)
log_message "Process killer script started (PID: $$)"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log_message "ERROR: This script must be run as root"
    exit 1
fi

# Check if process list file exists
if [ ! -f "$PROCESS_LIST_FILE" ]; then
    log_message "ERROR: Process list file not found: $PROCESS_LIST_FILE"
    log_message "Creating example file with common processes..."
    
    # Create example file
    cat > "$PROCESS_LIST_FILE" << EOF
# Example processes to kill (one per line)
# Remove the # to activate
#Chrome
#Safari
#Firefox
#Spotify
#Discord
EOF
    
    log_message "Example file created. Please edit $PROCESS_LIST_FILE and add processes to kill"
    exit 1
fi

# Validate file is readable
if [ ! -r "$PROCESS_LIST_FILE" ]; then
    log_message "ERROR: Cannot read process list file: $PROCESS_LIST_FILE"
    exit 1
fi

log_message "Starting process termination loop (timeout: ${SCRIPT_TIMEOUT}s, interval: ${KILL_INTERVAL}s)"

# Main loop - runs while true but with timeout check
while true; do
    # Check if we should continue (60-second timeout)
    if ! should_continue; then
        log_message "Script timeout reached (${SCRIPT_TIMEOUT}s). Exiting."
        break
    fi
    
    # Read process list file and process each line
    process_count=0
    killed_count=0
    
    while IFS= read -r process_name || [ -n "$process_name" ]; do
        # Skip empty lines and comments
        if [[ -z "$process_name" ]] || [[ "$process_name" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Trim whitespace
        process_name=$(echo "$process_name" | xargs)
        
        if [ -n "$process_name" ]; then
            process_count=$((process_count + 1))
            
            # Check if process is running before attempting to kill
            if pgrep -x "$process_name" > /dev/null 2>&1; then
                log_message "Terminating process: $process_name"
                
                # Attempt to kill the process
                if killall -TERM "$process_name" 2>/dev/null; then
                    killed_count=$((killed_count + 1))
                    log_message "Successfully sent TERM signal to: $process_name"
                else
                    log_message "WARNING: Failed to terminate process: $process_name"
                fi
            else
                log_message "Process not running: $process_name"
            fi
        fi
    done < "$PROCESS_LIST_FILE"
    
    if [ $process_count -eq 0 ]; then
        log_message "No valid processes found in $PROCESS_LIST_FILE"
    else
        log_message "Processed $process_count processes, killed $killed_count"
    fi
    
    # Sleep for specified interval before next iteration
    log_message "Sleeping for ${KILL_INTERVAL} seconds..."
    sleep $KILL_INTERVAL
done

# Calculate total runtime
end_time=$(date +%s)
total_runtime=$((end_time - start_time))
log_message "Process killer script completed. Total runtime: ${total_runtime} seconds"

exit 0