#!/bin/bash
#
# Script: 035_install_microsoft_word.sh
# Description: Install Microsoft Word
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Microsoft Word"
install_brew_package microsoft-word "--cask"
