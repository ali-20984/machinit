#!/bin/bash

# Hands-off Mac Initialization Launcher
# This script executes all scripts in the ./scripts directory in alphanumeric order.

set -e # Exit immediately if a command exits with a non-zero status.

SCRIPTS_DIR="./scripts"
LOG_FILE="./install.log"

echo "Starting Mac initialization..." | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Error: Scripts directory '$SCRIPTS_DIR' not found." | tee -a "$LOG_FILE"
    exit 1
fi

# Find and run scripts
for script in "$SCRIPTS_DIR"/*.sh; do
    # Check if file exists (in case glob matches nothing)
    [ -e "$script" ] || continue

    echo "--------------------------------------------------" | tee -a "$LOG_FILE"
    echo "Running $(basename "$script")..." | tee -a "$LOG_FILE"
    
    # Make script executable if it isn't
    if [ ! -x "$script" ]; then
        chmod +x "$script"
    fi

    # Execute script
    if "$script"; then
        echo "✓ $(basename "$script") completed successfully." | tee -a "$LOG_FILE"
    else
        echo "✗ $(basename "$script") failed." | tee -a "$LOG_FILE"
        exit 1
    fi
done

echo "--------------------------------------------------" | tee -a "$LOG_FILE"
echo "All scripts executed successfully!" | tee -a "$LOG_FILE"
echo "Initialization complete." | tee -a "$LOG_FILE"
