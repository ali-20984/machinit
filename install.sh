#!/bin/bash

# ==============================================================================
# Script: install.sh
# Description: Hands-off Mac Initialization Launcher
# Author: supermarsx
#
# This script serves as the main entry point for the MachInit project.
# It orchestrates the execution of modular scripts located in the ./scripts directory.
# It handles configuration parsing, logging, dry-run modes, and self-updates.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# ==============================================================================
# Configuration & Defaults
# ==============================================================================

# Directory containing the modular scripts
SCRIPTS_DIR="./scripts"

# Configuration file path (default is empty, meaning no config filtering)
CONFIG_FILE=""

# Python script used to parse the TOML configuration
PARSER_SCRIPT="./scripts/lib/config_parser.py"

# Flags
DRY_RUN=false       # If true, commands are printed but not executed
UPDATE=false        # If true, the script updates itself via git and exits
NO_LOG=false        # If true, logging to file is disabled
VERBOSE=false       # If true, enables shell debug mode (set -x)

# State variables
START_FROM=""       # Script name to resume execution from
SET_COMPUTER_NAME="" # Computer name passed via argument

# ==============================================================================
# Helper Functions
# ==============================================================================

# Function: show_help
# Description: Displays the usage information and available options.
function show_help() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run               Simulate actions without making changes."
    echo "  --update                Self-update the repository and exit."
    echo "  --config <file>         Use a specific configuration file to filter scripts."
    echo "  --no-log                Disable logging to file."
    echo "  --verbose, -v           Enable verbose output (set -x)."
    echo "  --start-from <script>   Resume execution from a specific script."
    echo "  --computer-name <name>  Set computer name non-interactively."
    echo "  --help, -h              Show this help message."
    echo ""
}

# ==============================================================================
# Argument Parsing
# ==============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            echo "!!! DRY RUN MODE ENABLED !!!"
            echo "No changes will be made to the system."
            shift
            ;;
        --update)
            UPDATE=true
            shift
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --no-log)
            NO_LOG=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --start-from)
            START_FROM="$2"
            shift 2
            ;;
        --computer-name)
            SET_COMPUTER_NAME="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Enable verbose mode if requested
if [ "$VERBOSE" = true ]; then
    set -x
fi

# Set up logging
if [ "$NO_LOG" = true ]; then
    LOG_FILE="/dev/null"
else
    LOG_FILE="./install_$(date +"%Y-%m-%d_%H-%M-%S").log"
fi

# ==============================================================================
# Self-Update Mechanism
# ==============================================================================

if [ "$UPDATE" = true ]; then
    echo "Checking for updates..."
    if [ -d ".git" ]; then
        if git pull; then
            echo "Update completed successfully."
            exit 0
        else
            echo "Update failed."
            exit 1
        fi
    else
        echo "Not a git repository. Cannot self-update."
        exit 1
    fi
fi

# Export variables for child scripts
export CONFIG_FILE
export DRY_RUN

# ==============================================================================
# Initialization
# ==============================================================================

echo "Starting Mac initialization..." | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"

# Request sudo permissions upfront (unless in dry-run mode)
if [ "$DRY_RUN" = false ]; then
    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# ==============================================================================
# System Configuration (Computer Name)
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    if [ -n "$SET_COMPUTER_NAME" ]; then
        # Use the name provided via CLI argument
        COMPUTER_NAME="$SET_COMPUTER_NAME"
        echo "Setting computer name to '$COMPUTER_NAME' (from argument)..."
        sudo scutil --set ComputerName "$COMPUTER_NAME"
        sudo scutil --set HostName "$COMPUTER_NAME"
        sudo scutil --set LocalHostName "$COMPUTER_NAME"
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
        echo "Computer name set to '$COMPUTER_NAME'" | tee -a "$LOG_FILE"
    else
        # Interactive prompt
        current_name=$(scutil --get ComputerName)
        echo "Current Computer Name: $current_name"
        read -p "Enter new computer name (or press Enter to keep '$current_name'): " COMPUTER_NAME

        if [ -z "$COMPUTER_NAME" ]; then
            COMPUTER_NAME="$current_name"
        fi

        read -p "Set computer name to '$COMPUTER_NAME'? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Setting computer name to '$COMPUTER_NAME'..."
            sudo scutil --set ComputerName "$COMPUTER_NAME"
            sudo scutil --set HostName "$COMPUTER_NAME"
            sudo scutil --set LocalHostName "$COMPUTER_NAME"
            sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
            echo "Computer name set to '$COMPUTER_NAME'" | tee -a "$LOG_FILE"
        else
            echo "Skipping computer name change." | tee -a "$LOG_FILE"
        fi
    fi
else
    echo "[DRY RUN] Would ask for computer name and set it."
fi

# ==============================================================================
# Script Execution Loop
# ==============================================================================

# Verify scripts directory exists
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Error: Scripts directory '$SCRIPTS_DIR' not found." | tee -a "$LOG_FILE"
    exit 1
fi

# Count total scripts for progress tracking
TOTAL_SCRIPTS=$(find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" | wc -l | xargs)
CURRENT_COUNT=0
SUCCESS_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

# Determine if we need to skip scripts until a specific start point
SKIPPING_UNTIL_START=false
if [ -n "$START_FROM" ]; then
    SKIPPING_UNTIL_START=true
fi

# Iterate through all .sh files in the scripts directory
for script in "$SCRIPTS_DIR"/*.sh; do
    # Check if file exists (in case glob matches nothing)
    [ -e "$script" ] || continue

    script_name=$(basename "$script")
    ((CURRENT_COUNT++))

    # --------------------------------------------------------------------------
    # Logic: Resume from specific script
    # --------------------------------------------------------------------------
    if [ "$SKIPPING_UNTIL_START" = true ]; then
        if [[ "$script_name" == *"$START_FROM"* ]]; then
            SKIPPING_UNTIL_START=false
            echo "Found start script: $script_name. Resuming execution." | tee -a "$LOG_FILE"
        else
            echo "[$CURRENT_COUNT/$TOTAL_SCRIPTS] Skipping $script_name (before start point)..." | tee -a "$LOG_FILE"
            ((SKIPPED_COUNT++))
            continue
        fi
    fi
    
    # --------------------------------------------------------------------------
    # Logic: Check Configuration
    # --------------------------------------------------------------------------
    # If no config file is specified, run everything by default.
    # Otherwise, check the TOML file for scripts."filename" = true/false
    if [ -z "$CONFIG_FILE" ]; then
        should_run="true"
    else
        should_run=$(python3 "$PARSER_SCRIPT" "$CONFIG_FILE" "scripts.\"$script_name\"")
    fi
    
    if [ "$should_run" == "false" ]; then
        echo "[$CURRENT_COUNT/$TOTAL_SCRIPTS] Skipping $script_name (disabled in config)..." | tee -a "$LOG_FILE"
        ((SKIPPED_COUNT++))
        continue
    fi

    # --------------------------------------------------------------------------
    # Logic: Execute Script
    # --------------------------------------------------------------------------
    echo "--------------------------------------------------" | tee -a "$LOG_FILE"
    echo "[$CURRENT_COUNT/$TOTAL_SCRIPTS] Running $script_name..." | tee -a "$LOG_FILE"
    
    # Ensure script is executable
    if [ ! -x "$script" ]; then
        chmod +x "$script"
    fi

    # Run the script
    # We use pipefail to ensure we catch script errors even when piping to tee
    set -o pipefail
    if "$script" 2>&1 | tee -a "$LOG_FILE"; then
        echo "✓ $script_name completed successfully." | tee -a "$LOG_FILE"
        ((SUCCESS_COUNT++))
        set +o pipefail
    else
        echo "✗ $script_name failed." | tee -a "$LOG_FILE"
        ((FAILED_COUNT++))
        echo "--------------------------------------------------" | tee -a "$LOG_FILE"
        echo "Execution aborted due to failure." | tee -a "$LOG_FILE"
        echo "Summary:" | tee -a "$LOG_FILE"
        echo "  Total: $TOTAL_SCRIPTS" | tee -a "$LOG_FILE"
        echo "  Success: $SUCCESS_COUNT" | tee -a "$LOG_FILE"
        echo "  Skipped: $SKIPPED_COUNT" | tee -a "$LOG_FILE"
        echo "  Failed: $FAILED_COUNT" | tee -a "$LOG_FILE"
        exit 1
    fi
done

# ==============================================================================
# Final Summary
# ==============================================================================

echo "--------------------------------------------------" | tee -a "$LOG_FILE"
echo "All scripts executed successfully!" | tee -a "$LOG_FILE"
echo "Summary:" | tee -a "$LOG_FILE"
echo "  Total: $TOTAL_SCRIPTS" | tee -a "$LOG_FILE"
echo "  Success: $SUCCESS_COUNT" | tee -a "$LOG_FILE"
echo "  Skipped: $SKIPPED_COUNT" | tee -a "$LOG_FILE"
echo "  Failed: $FAILED_COUNT" | tee -a "$LOG_FILE"
echo "Initialization complete." | tee -a "$LOG_FILE"
