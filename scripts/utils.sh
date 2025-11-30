#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Configuration
if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="$(dirname "$(dirname "$0")")/config.toml"
fi
PARSER_SCRIPT="$(dirname "$0")/lib/config_parser.py"

# Check for Dry Run environment variable
if [ -z "$DRY_RUN" ]; then
    DRY_RUN=false
fi

if [ -z "$MACHINIT_SUDO_MANAGED" ]; then
    MACHINIT_SUDO_MANAGED=false
fi

SUDO_STATUS_MESSAGE_SHOWN=false

# Function: print_success
# Description: Emit a green checkmark prefix so success logs stand out even in
#              verbose output from nested scripts.
function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function: print_error
# Description: Emit a red X prefix to highlight failures or missing tools.
function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function: print_info
# Description: Emit a yellow info marker for neutral progress messages.
function print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Function: print_dry_run
# Description: Make it obvious when a command is only simulated in DRY_RUN
#              mode so the operator knows no system change occurred.
function print_dry_run() {
    echo -e "${GRAY}[DRY RUN] $1${NC}"
}

# Function: execute
# Description: Evaluate an arbitrary command string, printing instead of
#              executing when DRY_RUN=true.
function execute() {
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "$*"
        return 0
    fi

    "$@"
}

# Function: ensure_sudo
# Description: Refresh sudo credentials on demand so privilege prompts happen
#              in a predictable place before we run the real command.
function ensure_sudo() {
    if [ "$DRY_RUN" = true ]; then
        return 0
    fi

    if [ "$MACHINIT_SUDO_MANAGED" = true ]; then
        return 0
    fi

    if sudo -n true 2>/dev/null; then
        return 0
    fi

    if [ "$SUDO_STATUS_MESSAGE_SHOWN" != true ]; then
        echo "Sudo access required. Please enter your password (if prompted)."
        SUDO_STATUS_MESSAGE_SHOWN=true
    fi
    if ! sudo -v; then
        print_error "Failed to refresh sudo credentials."
        return 1
    fi
}

# Function: execute_sudo
# Description: Same as execute but prefixes commands with sudo when applying
#              real changes.
function execute_sudo() {
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "sudo $*"
        return 0
    fi

    if ! ensure_sudo; then
        return 1
    fi

    sudo "$@"
}

# Function: get_config
# Description: Read a TOML key via the shared Python parser when config-driven
#              toggles are needed inside child scripts.
function get_config() {
    local key="$1"
    if [ -f "$CONFIG_FILE" ] && [ -f "$PARSER_SCRIPT" ]; then
        python3 "$PARSER_SCRIPT" "$CONFIG_FILE" "$key"
    fi
}

# Function: set_default
# Description: Wrapper for defaults write that logs the intent and obeys
#              DRY_RUN; targeted at simple scalar types.
function set_default() {
    local domain="$1"
    local key="$2"
    local type="$3"
    local value="$4"

    # Handle -array type specially if needed, but usually passed as separate args in raw command
    # For this helper, we assume simple types: string, int, float, bool

    if [ "$DRY_RUN" = true ]; then
        print_dry_run "defaults write $domain $key -$type $value"
    else
        if defaults write "$domain" "$key" "-$type" "$value"; then
            print_success "Set $domain $key to $value"
        else
            print_error "Failed to set $domain $key"
        fi
    fi
}

# Function: install_brew_package
# Description: Installs either formulae or casks if missing, emitting helpful
#              logs and supporting DRY_RUN-friendly output.
function install_brew_package() {
    local package="$1"
    local options="${2:-}"

    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew install $options $package"
        return 0
    fi

    if brew list --formula "$package" &>/dev/null || brew list --cask "$package" &>/dev/null; then
        print_success "$package is already installed."
    else
        print_info "Installing $package..."
        local cmd=(brew install)
        if [ -n "$options" ]; then
            # shellcheck disable=SC2206
            local extra_opts=($options)
            cmd+=("${extra_opts[@]}")
        fi
        cmd+=("$package")

        if "${cmd[@]}"; then
            print_success "$package installed."
        else
            print_error "Failed to install $package."
        fi
    fi
}

# Function: check_command
# Description: Confirm a binary exists in PATH before running follow-up logic.
function check_command() {
    local command_name="$1"
    if command -v "$command_name" &>/dev/null; then
        print_success "Command '$command_name' is available."
        return 0
    else
        print_error "Command '$command_name' is missing."
        return 1
    fi
}
