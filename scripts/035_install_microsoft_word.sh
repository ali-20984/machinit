#!/bin/bash
#
# Script: 035_install_microsoft_word.sh
# Description: Install Microsoft Word
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Microsoft Word..."
install_brew_package microsoft-word "--cask"
