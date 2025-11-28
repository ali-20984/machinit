#!/bin/bash
#
# Script: 044_configure_dock_apps.sh
# Description: Configure Dock Apps
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Configuring Dock apps..."

echo "Ensuring dockutil is installed..."
install_brew_package dockutil

echo "Clearing existing Dock items..."
dockutil --remove all --no-restart

echo "Adding apps to Dock..."
# Add apps in the requested order
dockutil --add "/Applications/Visual Studio Code.app" --no-restart
dockutil --add "/Applications/Firefox.app" --no-restart
dockutil --add "/System/Applications/Utilities/Terminal.app" --no-restart
dockutil --add "/Applications/Beeper.app" --no-restart
dockutil --add "/Applications/Bitwarden.app" --no-restart
dockutil --add "/Applications/GitHub Desktop.app" --no-restart
dockutil --add "/Applications/Microsoft Word.app" --no-restart
dockutil --add "/Applications/Microsoft Excel.app" --no-restart

# Restart Dock to apply changes
killall Dock

echo "Dock apps configured."
