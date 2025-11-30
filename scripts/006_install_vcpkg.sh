#!/bin/bash
#
# Script: 006_install_vcpkg.sh
# Description: Install Vcpkg
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "vcpkg"
install_brew_package vcpkg
print_success "vcpkg installed."
