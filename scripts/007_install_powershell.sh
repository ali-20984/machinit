#!/bin/bash
#
# Script: 007_install_powershell.sh
# Description: Install Powershell
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing PowerShell..."
install_brew_package powershell "--cask"
