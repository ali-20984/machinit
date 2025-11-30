#!/bin/bash

# Colors (cohesive muted palette)
GREEN='\033[38;5;114m'   # Soft green for success
RED='\033[38;5;174m'     # Muted coral for errors
YELLOW='\033[38;5;222m'  # Warm yellow for warnings
CYAN='\033[38;5;116m'    # Teal for info
GRAY='\033[38;5;245m'    # Neutral gray for dry-run
WHITE='\033[38;5;255m'   # Bright white for emphasis
NC='\033[0m'              # Reset


# Detect original user for commands that shouldn't run as root
if [ -z "$ORIGINAL_USER" ]; then
    if [ -n "$SUDO_USER" ]; then
        ORIGINAL_USER="$SUDO_USER"
    else
        ORIGINAL_USER="$USER"
    fi
fi
ORIGINAL_HOME=$(eval echo "~$ORIGINAL_USER")

# Configuration
if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="$(dirname "$(dirname "$0")")/config.toml"
fi
PARSER_SCRIPT="$(dirname "$0")/lib/config_parser.py"

# Check for Dry Run environment variable
if [ -z "$DRY_RUN" ]; then
    DRY_RUN=false
fi

# Function: print_success
# Description: Emit a green checkmark prefix so success logs stand out.
function print_success() {
    echo -e "${GREEN}✓${NC} ${WHITE}$1${NC}"
}

# Function: print_error
# Description: Emit a red X prefix to highlight failures.
function print_error() {
    echo -e "${RED}✗${NC} ${RED}$1${NC}"
}

# Function: print_info
# Description: Emit a teal info marker for progress messages.
function print_info() {
    echo -e "${CYAN}→${NC} ${GRAY}$1${NC}"
}

# Function: print_warning
# Description: Emit a yellow warning marker.
function print_warning() {
    echo -e "${YELLOW}⚠${NC} ${YELLOW}$1${NC}"
}

# Function: print_dry_run
# Description: Make it obvious when a command is only simulated.
function print_dry_run() {
    echo -e "${GRAY}⋯ [DRY RUN]${NC} ${GRAY}$1${NC}"
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

    # Installer's keep-alive loop handles sudo refresh
    if [ "$MACHINIT_SUDO_KEEPALIVE_ACTIVE" = true ]; then
        return 0
    fi

    if sudo -n true 2>/dev/null; then
        return 0
    fi

    if ! sudo -v; then
        print_error "Failed to refresh sudo credentials."
        return 1
    fi
}

# Function: execute_sudo
# Description: Run command with elevated privileges. Uses sudo -n (non-interactive)
#              since install.sh keeps credentials fresh with a keepalive loop.
function execute_sudo() {
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "sudo $*"
        return 0
    fi

    # Use sudo -n to avoid prompting (keepalive keeps credentials fresh)
    sudo -n "$@"
}

# Function: execute_as_user
# Description: Run command as the original user (useful for brew, npm, etc.)
function execute_as_user() {
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "(as $ORIGINAL_USER) $*"
        return 0
    fi

    # If we're root, drop to original user
    if [ "$EUID" -eq 0 ]; then
        sudo -u "$ORIGINAL_USER" "$@"
    else
        "$@"
    fi
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
