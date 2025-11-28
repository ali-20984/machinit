#!/bin/bash
#
# Script: 036_install_adobe_reader.sh
# Description: Install Adobe Reader
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Adobe Acrobat Reader..."
install_brew_package adobe-acrobat-reader "--cask"
