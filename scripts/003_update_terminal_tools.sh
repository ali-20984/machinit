#!/bin/bash
#
# Script: 003_update_terminal_tools.sh
# Description: Update Terminal Tools
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_info "Updating Homebrew..."
execute brew update

print_info "Upgrading installed Homebrew packages..."
execute brew upgrade

print_info "Cleaning up Homebrew caches..."
execute brew cleanup

print_success "Terminal tools updated."
