#!/bin/bash
#
# Script: 002_install_homebrew.sh
# Description: Install Homebrew
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_info "Checking for Homebrew..."

if command -v brew &>/dev/null; then
    print_success "Homebrew is already installed."
    exit 0
fi

print_info "Homebrew not found. Installing..."
INSTALLER="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

if [ "$DRY_RUN" = true ]; then
    print_dry_run "NONINTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL $INSTALLER)\""
else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$INSTALLER")"
fi

if [ "$DRY_RUN" = true ]; then
    print_dry_run "eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    print_dry_run "eval \"\$(/usr/local/bin/brew shellenv)\""
else
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

print_success "Homebrew installation script completed."
