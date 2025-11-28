#!/bin/bash
#
# Script: 020_install_firefox.sh
# Description: Install Firefox
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Firefox..."
install_brew_package firefox
