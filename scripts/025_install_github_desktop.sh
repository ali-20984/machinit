#!/bin/bash
#
# Script: 025_install_github_desktop.sh
# Description: Install Github Desktop
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "GitHub Desktop"
install_brew_package github "--cask"
