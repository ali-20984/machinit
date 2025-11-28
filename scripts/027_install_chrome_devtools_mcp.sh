#!/bin/bash
#
# Script: 027_install_chrome_devtools_mcp.sh
# Description: Install Chrome Devtools Mcp
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Chrome DevTools MCP..."
install_brew_package chrome-devtools-mcp
