#!/bin/bash
#
# Script: 033_install_microsoft_outlook.sh
# Description: Install Microsoft Outlook
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Microsoft Outlook"
install_brew_package microsoft-outlook "--cask"
