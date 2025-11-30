#!/bin/bash
#
# Script: 029_install_nextcloud.sh
# Description: Install Nextcloud
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Nextcloud"
install_brew_package nextcloud "--cask"
