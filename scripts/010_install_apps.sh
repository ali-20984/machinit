#!/bin/bash
#
# Script: 010_install_apps.sh
# Description: Install Apps
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_header "Applications"

print_install "iTerm2"
install_brew_package iterm2

print_install "Mark Text"
install_brew_package mark-text "--cask"

print_install "Standard Notes"
install_brew_package standard-notes "--cask"

echo "Applications installed."
