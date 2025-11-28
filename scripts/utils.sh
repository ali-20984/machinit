#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

function print_dry_run() {
    echo -e "${BLUE}[DRY RUN] $1${NC}"
}

# Function to execute a command, respecting DRY_RUN
function execute() {
    local cmd="$@"
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "$cmd"
    else
        eval "$cmd"
    fi
}

# Function to execute a command with sudo, respecting DRY_RUN
function execute_sudo() {
    local cmd="$@"
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "sudo $cmd"
    else
        sudo eval "$cmd"
    fi
}

# Function to read a value from the TOML config
function get_config() {
    local key="$1"
    if [ -f "$CONFIG_FILE" ] && [ -f "$PARSER_SCRIPT" ]; then
        python3 "$PARSER_SCRIPT" "$CONFIG_FILE" "$key"
    fi
}

# Function to set a macOS default and verify it
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

# Function to check if a brew package is installed, and install if not
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
        if brew install $options "$package"; then
            print_success "$package installed."
        else
            print_error "Failed to install $package."
        fi
    fi
}

# Function to check if a command exists
function check_command() {
    local cmd="$1"
    if command -v "$cmd" &> /dev/null; then
        print_success "Command '$cmd' is available."
        return 0
    else
        print_error "Command '$cmd' is missing."
        return 1
    fi
}
