#!/bin/bash
#
# Script: 026_install_keepassxc.sh
# Description: Install Keepassxc
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing KeePassXC..."
install_brew_package keepassxc "--cask"
