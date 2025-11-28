#!/bin/bash
#
# Script: 033_install_microsoft_outlook.sh
# Description: Install Microsoft Outlook
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Microsoft Outlook..."
install_brew_package microsoft-outlook "--cask"
