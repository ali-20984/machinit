#!/bin/bash
#
# Script: 023_install_opencode.sh
# Description: Install Opencode
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "OpenCode"
install_brew_package opencode
