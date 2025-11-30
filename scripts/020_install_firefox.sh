#!/bin/bash
#
# Script: 020_install_firefox.sh
# Description: Install Firefox
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Firefox"
install_brew_package firefox
