#!/bin/bash
#
# Script: 037_install_openvpn.sh
# Description: Install Openvpn
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "OpenVPN Connect"
install_brew_package openvpn-connect "--cask"
