#!/bin/bash
#
# Script: 009_install_fonts.sh
# Description: Install Fonts
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing custom fonts..."

# Install Fantasque Sans Mono
# A nice, slightly unusual monospace font with handwriting-like curves
echo "Installing Fantasque Sans Mono..."
install_brew_package font-fantasque-sans-mono "--cask"

echo "Fonts installed."
