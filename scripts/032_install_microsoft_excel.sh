#!/bin/bash
#
# Script: 032_install_microsoft_excel.sh
# Description: Install Microsoft Excel
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Microsoft Excel"
install_brew_package microsoft-excel "--cask"
