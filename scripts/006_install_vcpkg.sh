#!/bin/bash
#
# Script: 006_install_vcpkg.sh
# Description: Install Vcpkg
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing vcpkg..."
install_brew_package vcpkg
echo "vcpkg installed."
