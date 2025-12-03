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

# Color codes for terminal output (cohesive muted palette using 256-color mode)
GREEN='\033[38;5;114m'    # Soft sage green for success
YELLOW='\033[38;5;222m'   # Warm honey for warnings/skips
RED='\033[38;5;174m'      # Muted coral for errors
BLUE='\033[38;5;111m'     # Soft sky blue for script names
CYAN='\033[38;5;116m'     # Soft teal for progress arrows
GRAY='\033[38;5;245m'     # Neutral gray for secondary text
WHITE='\033[38;5;255m'    # Bright white for emphasis
PURPLE='\033[38;5;183m'   # Lavender for special highlights
ORANGE='\033[38;5;216m'   # Soft peach for notices
PINK='\033[38;5;218m'     # Soft pink for decorative elements
DIM='\033[38;5;240m'      # Darker gray for timestamps
BOLD='\033[1m'            # Bold text
NC='\033[0m'              # Reset

# Detect original user (works whether run with sudo or not)
if [ -n "$SUDO_USER" ]; then
    ORIGINAL_USER="$SUDO_USER"
else
    ORIGINAL_USER="$USER"
fi
export ORIGINAL_USER
export ORIGINAL_HOME=$(eval echo "~$ORIGINAL_USER")

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
DRY_RUN=false # If true, commands are printed but not executed
UPDATE=false  # If true, the script updates itself via git and exits
NO_LOG=false  # If true, logging to file is disabled
VERBOSE=false # If true, enables shell debug mode (set -x)
RESTART_UI=false # If true, run final UI restart script at the end (non-interactive)

# State variables
START_FROM=""        # Script name to resume execution from
RUN_ONLY_INDEX=""    # If non-empty, run only this 1-based script index
SET_COMPUTER_NAME="" # Computer name passed via argument
KEEPALIVE_PID=""     # PID of the sudo keep-alive loop

# ==============================================================================
# Helper Functions
# ==============================================================================

# Function: show_help
# Description: Prints CLI usage plus available arguments so the user knows
#              how to toggle dry-run, logging, configs, and resume points.
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
    echo "  --run-only <N>          Run only the script with 1-based index N from the scripts list."
    echo "  --restart-ui             Run the final UI restart (equivalent to scripts/999_restart_apps.sh --yes) when the run completes."
    echo "  --computer-name <name>  Set computer name non-interactively."
    echo "  --help, -h              Show this help message."
    echo ""
}

# Function: start_sudo_keepalive
# Description: Authenticates once with sudo and launches a background loop
#              to refresh credentials so child scripts never prompt again.
function start_sudo_keepalive() {
    echo "Requesting administrator privileges (you'll only be asked once)..."
    sudo -v
    
    # Start background loop to keep sudo alive
    # The loop runs sudo -v to refresh the timestamp (not sudo -n which just checks)
    while true; do
        sleep 50
        sudo -v 2>/dev/null
    done &
    KEEPALIVE_PID=$!
    export MACHINIT_SUDO_KEEPALIVE_ACTIVE=true
}

# Function: stop_sudo_keepalive
# Description: Cleans up the background refresh loop.
function stop_sudo_keepalive() {
    if [ -n "$KEEPALIVE_PID" ] && kill -0 "$KEEPALIVE_PID" 2>/dev/null; then
        kill "$KEEPALIVE_PID" 2>/dev/null || true
    fi
}

# Function: refresh_sudo_credentials
# Description: No-op since keepalive handles this.
function refresh_sudo_credentials() {
    return 0
}

# Function: normalize_hostname
# Description: Convert a friendly computer name into a HostName-safe value by
#              lowercasing, replacing whitespace with hyphens, and stripping
#              unsupported characters.
function normalize_hostname() {
    local raw="$1"
    local normalized
    normalized=$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')
    normalized=${normalized// /-}
    normalized=$(printf '%s' "$normalized" | tr -cd '[:alnum:]-')
    if [ -z "$normalized" ]; then
        normalized="mac"
    fi
    echo "$normalized"
}

# Function: apply_computer_name
# Description: Sets the various macOS identifiers (ComputerName/HostName/
#              LocalHostName/NetBIOS) using a friendly name and a sanitized
#              hostname for network-safe fields.
function apply_computer_name() {
    local friendly_name="$1"
    local sanitized
    sanitized=$(normalize_hostname "$friendly_name")

    echo "Setting computer name to '$friendly_name' (hostname '$sanitized')..."
    sudo scutil --set ComputerName "$friendly_name"
    sudo scutil --set HostName "$sanitized"
    sudo scutil --set LocalHostName "$sanitized"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$sanitized"
    printf "%b\n" "${GREEN}Computer name set to '$friendly_name' (HostName: '$sanitized')${NC}" | tee -a "$LOG_FILE"
}

trap stop_sudo_keepalive EXIT

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
        --verbose | -v)
            VERBOSE=true
            shift
            ;;
        --start-from)
            START_FROM="$2"
            shift 2
            ;;
        --restart-ui)
            RESTART_UI=true
            shift
            ;;
            --run-only)
                RUN_ONLY_INDEX="$2"
                shift 2
                ;;
        --computer-name)
            SET_COMPUTER_NAME="$2"
            shift 2
            ;;
        --help | -h)
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

echo "" | tee -a "$LOG_FILE"
printf "%b\n" "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "${PURPLE}▶${NC} ${BOLD}${WHITE}Starting Mac initialization...${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "${DIM}  $(date)${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"

# Request sudo permissions upfront (unless in dry-run mode)
if [ "$DRY_RUN" = false ]; then
    start_sudo_keepalive
    refresh_sudo_credentials
fi

# ==============================================================================
# System Configuration (Computer Name)
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    if [ -n "$SET_COMPUTER_NAME" ]; then
        refresh_sudo_credentials
        # Use the name provided via CLI argument
        COMPUTER_NAME="$SET_COMPUTER_NAME"
        apply_computer_name "$COMPUTER_NAME"
    else
        # Interactive prompt
        current_name=$(scutil --get ComputerName)
        echo "Current Computer Name: $current_name"
        read -r -p "Enter new computer name (or press Enter to keep '$current_name'): " COMPUTER_NAME

        if [ -z "$COMPUTER_NAME" ]; then
            COMPUTER_NAME="$current_name"
        fi

        read -r -n 1 -p "Set computer name to '$COMPUTER_NAME'? (y/n) "
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            refresh_sudo_credentials
            apply_computer_name "$COMPUTER_NAME"
        else
            echo "Skipping computer name change." | tee -a "$LOG_FILE"
        fi
    fi
else
    printf "%b\n" "${BLUE}[DRY RUN] Would ask for computer name and set it.${NC}"
fi

# ==============================================================================
# Script Execution Loop
# ==============================================================================

# Verify scripts directory exists
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Error: Scripts directory '$SCRIPTS_DIR' not found." | tee -a "$LOG_FILE"
    exit 1
fi

# Count total scripts for progress tracking (exclude utils.sh which is a library)
TOTAL_SCRIPTS=$(find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" ! -name "utils.sh" | wc -l | xargs)
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
    
    # Skip utility/library files that aren't meant to be executed directly
    if [[ "$script_name" == "utils.sh" ]]; then
        continue
    fi

    ((++CURRENT_COUNT))

    # If user requested --run-only, skip everything except the chosen index
    if [ -n "$RUN_ONLY_INDEX" ]; then
        if ! [[ "$RUN_ONLY_INDEX" =~ ^[0-9]+$ ]]; then
            echo "Error: --run-only expects a numeric 1-based index." | tee -a "$LOG_FILE"
            exit 1
        fi
        if [ "$CURRENT_COUNT" -ne "$RUN_ONLY_INDEX" ]; then
            printf "%b
" "${DIM}⊘${NC} ${GRAY}[$CURRENT_COUNT/$TOTAL_SCRIPTS] Skipping $script_name (not selected by --run-only)${NC}" | tee -a "$LOG_FILE"
            ((++SKIPPED_COUNT))
            continue
        fi
    fi

    # --------------------------------------------------------------------------
    # Logic: Resume from specific script
    # --------------------------------------------------------------------------
    if [ "$SKIPPING_UNTIL_START" = true ]; then
        if [[ "$script_name" == *"$START_FROM"* ]]; then
            SKIPPING_UNTIL_START=false
            printf "%b\n" "${ORANGE}○${NC} ${WHITE}Found start script: $script_name. Resuming execution.${NC}" | tee -a "$LOG_FILE"
        else
            printf "%b\n" "${DIM}⊘${NC} ${GRAY}[$CURRENT_COUNT/$TOTAL_SCRIPTS] Skipping $script_name (before start point)${NC}" | tee -a "$LOG_FILE"
            ((++SKIPPED_COUNT))
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
        printf "%b\n" "${DIM}⊘${NC} ${GRAY}[$CURRENT_COUNT/$TOTAL_SCRIPTS] Skipping $script_name (disabled in config)${NC}" | tee -a "$LOG_FILE"
        ((++SKIPPED_COUNT))
        continue
    fi

    # --------------------------------------------------------------------------
    # Logic: Execute Script
    # --------------------------------------------------------------------------
    printf "%b\n" "${DIM}──────────────────────────────────────────────────${NC}" | tee -a "$LOG_FILE"
    printf "%b\n" "${PURPLE}▶${NC} ${WHITE}[$CURRENT_COUNT/$TOTAL_SCRIPTS]${NC} ${BLUE}$script_name${NC}" | tee -a "$LOG_FILE"

    refresh_sudo_credentials

    # Ensure script is executable
    if [ ! -x "$script" ]; then
        chmod +x "$script"
    fi

    # Run the script
    # We use pipefail to ensure we catch script errors even when piping to tee
    set -o pipefail
    if "$script" 2>&1 | tee -a "$LOG_FILE"; then
        printf "%b\n" "${GREEN}✓${NC} ${WHITE}$script_name${NC} ${GREEN}completed${NC}" | tee -a "$LOG_FILE"
        ((++SUCCESS_COUNT))
        set +o pipefail
    else
        printf "%b\n" "${RED}✗${NC} ${WHITE}$script_name${NC} ${RED}failed${NC}" | tee -a "$LOG_FILE"
        ((++FAILED_COUNT))
        set +o pipefail
    fi
done

# ==============================================================================
# Final Summary
# ==============================================================================

echo "" | tee -a "$LOG_FILE"
printf "%b\n" "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "${BOLD}${WHITE}Summary${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "  ${DIM}Total:${NC}   ${WHITE}$TOTAL_SCRIPTS${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "  ${GREEN}✓${NC} ${GRAY}Success:${NC} ${GREEN}$SUCCESS_COUNT${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "  ${ORANGE}⊘${NC} ${GRAY}Skipped:${NC} ${ORANGE}$SKIPPED_COUNT${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "  ${RED}✗${NC} ${GRAY}Failed:${NC}  ${RED}$FAILED_COUNT${NC}" | tee -a "$LOG_FILE"
printf "%b\n" "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"

if [ "$FAILED_COUNT" -gt 0 ]; then
    printf "%b\n" "${RED}⚠${NC} ${YELLOW}Some scripts failed. Review above for details.${NC}" | tee -a "$LOG_FILE"
    exit 1
fi

printf "%b\n" "${GREEN}✓${NC} ${BOLD}${WHITE}Initialization complete!${NC}" | tee -a "$LOG_FILE"

# Optionally restart UI (Dock/Finder/etc) after a successful run
if [ "$RESTART_UI" = true ]; then
    printf "%b\n" "${CYAN}→${NC} ${WHITE}--restart-ui requested: running scripts/999_restart_apps.sh --yes${NC}" | tee -a "$LOG_FILE"
    ./scripts/999_restart_apps.sh --yes 2>&1 | tee -a "$LOG_FILE" || true
fi
