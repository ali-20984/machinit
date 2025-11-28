#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Function to set a macOS default and verify it
function set_default() {
    local domain="$1"
    local key="$2"
    local type="$3"
    local value="$4"
    
    # Handle -array type specially if needed, but usually passed as separate args in raw command
    # For this helper, we assume simple types: string, int, float, bool
    
    if defaults write "$domain" "$key" "-$type" "$value"; then
        print_success "Set $domain $key to $value"
    else
        print_error "Failed to set $domain $key"
    fi
}

# Function to check if a brew package is installed, and install if not
function install_brew_package() {
    local package="$1"
    local options="${2:-}"
    
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
