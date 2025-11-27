#!/bin/bash
echo "Configuring Dock apps..."

# Check if dockutil is installed
if ! command -v dockutil &> /dev/null; then
    echo "dockutil not found. Installing via Homebrew..."
    brew install dockutil
fi

echo "Clearing existing Dock items..."
dockutil --remove all --no-restart

echo "Adding apps to Dock..."
# Add apps in the requested order
dockutil --add "/Applications/Visual Studio Code.app" --no-restart
dockutil --add "/Applications/Firefox.app" --no-restart
dockutil --add "/System/Applications/Utilities/Terminal.app" --no-restart

# Restart Dock to apply changes
killall Dock

echo "Dock apps configured."
