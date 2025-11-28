#!/bin/bash
#
# Script: 034_install_microsoft_powerpoint.sh
# Description: Install Microsoft Powerpoint
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Microsoft PowerPoint..."
install_brew_package microsoft-powerpoint "--cask"
