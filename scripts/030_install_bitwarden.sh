#!/bin/bash
#
# Script: 030_install_bitwarden.sh
# Description: Install Bitwarden
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Bitwarden..."
install_brew_package bitwarden "--cask"
