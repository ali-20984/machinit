#!/bin/bash
#
# Script: 024_install_beeper.sh
# Description: Install Beeper
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Beeper..."
install_brew_package beeper "--cask"
