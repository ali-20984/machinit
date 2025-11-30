#!/bin/bash
#
# Script: 009_install_fonts.sh
# Description: Install Fonts
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_header "Custom Fonts"

# Install Fantasque Sans Mono
# A nice, slightly unusual monospace font with handwriting-like curves
print_install "Fantasque Sans Mono"
install_brew_package font-fantasque-sans-mono "--cask"

echo "Fonts installed."
