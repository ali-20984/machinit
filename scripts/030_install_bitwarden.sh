#!/bin/bash
#
# Script: 030_install_bitwarden.sh
# Description: Install Bitwarden
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Bitwarden"
install_brew_package bitwarden "--cask"
