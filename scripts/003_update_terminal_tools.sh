#!/bin/bash
#
# Script: 003_update_terminal_tools.sh
# Description: Update Terminal Tools
# Author: supermarsx
#
echo "Updating Homebrew..."
brew update

echo "Upgrading installed Homebrew packages..."
brew upgrade

echo "Cleaning up..."
brew cleanup

echo "Terminal tools updated."
