#!/bin/bash

# Hands-off Mac Initialization Launcher
# This script executes all scripts in the ./scripts directory in alphanumeric order.

set -e # Exit immediately if a command exits with a non-zero status.

SCRIPTS_DIR="./scripts"
LOG_FILE="./install.log"
CONFIG_FILE="./config.toml"
PARSER_SCRIPT="./lib/config_parser.py"
DRY_RUN=false
UPDATE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
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
    esac
done

# Self-update mechanism
if [ "$UPDATE" = true ]; then
    echo "Checking for updates..."
    if [ -d ".git" ]; then
        if git pull; then
            echo "Update completed. Restarting script..."
            exec "$0" "$@"
        else
            echo "Update failed. Continuing with current version..."
        fi
    else
        echo "Not a git repository. Cannot self-update."
    fi
fi

export DRY_RUN

echo "Starting Mac initialization..." | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"

if [ "$DRY_RUN" = false ]; then
    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# Ask for computer name
if [ "$DRY_RUN" = false ]; then
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
else
    echo "[DRY RUN] Would ask for computer name and set it."
fi

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Error: Scripts directory '$SCRIPTS_DIR' not found." | tee -a "$LOG_FILE"
    exit 1
fi

# Find and run scripts
for script in "$SCRIPTS_DIR"/*.sh; do
    # Check if file exists (in case glob matches nothing)
    [ -e "$script" ] || continue

    script_name=$(basename "$script")
    
    # Check config to see if script should run
    # We use python helper to check scripts."script_name"
    # Note: TOML keys with dots need to be quoted in the file, but our parser handles the lookup path
    # We pass scripts."filename" to the parser.
    should_run=$(python3 "$PARSER_SCRIPT" "$CONFIG_FILE" "scripts.\"$script_name\"")
    
    # If config returns "false", skip. If empty or "true", run.
    if [ "$should_run" == "false" ]; then
        echo "Skipping $script_name (disabled in config)..." | tee -a "$LOG_FILE"
        continue
    fi

    echo "--------------------------------------------------" | tee -a "$LOG_FILE"
    echo "Running $script_name..." | tee -a "$LOG_FILE"
    
    # Make script executable if it isn't
    if [ ! -x "$script" ]; then
        chmod +x "$script"
    fi

    # Execute script
    # We use pipefail to ensure we catch script errors even when piping to tee
    set -o pipefail
    if "$script" 2>&1 | tee -a "$LOG_FILE"; then
        echo "✓ $script_name completed successfully." | tee -a "$LOG_FILE"
        set +o pipefail
    else
        echo "✗ $script_name failed." | tee -a "$LOG_FILE"
        exit 1
    fi
done

echo "--------------------------------------------------" | tee -a "$LOG_FILE"
echo "All scripts executed successfully!" | tee -a "$LOG_FILE"
echo "Initialization complete." | tee -a "$LOG_FILE"
