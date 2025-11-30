#!/bin/bash
#
# Script: 028_install_google_chrome.sh
# Description: Install Google Chrome
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Google Chrome"
install_brew_package google-chrome "--cask"
