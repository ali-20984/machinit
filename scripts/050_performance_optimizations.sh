#!/bin/bash
echo "Running performance optimizations..."

function check_status() {
    if [ $? -eq 0 ]; then
        echo "✓ $1"
    else
        echo "✗ Failed to: $1"
    fi
}

echo "Disabling Spotlight indexing..."
sudo mdutil -a -i off
check_status "Spotlight indexing disabled"

echo "Disabling global animations..."
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
check_status "Global animations disabled"

echo "Optimizing SSD settings..."
# SSD optimizations 
# Note: 'trimforce enable' requires a reboot and user confirmation.
# It is commented out to prevent interrupting the script flow.
# echo "y" | sudo trimforce enable

sudo pmset -a hibernatemode 0
if [ -f /var/vm/sleepimage ]; then
    sudo rm /var/vm/sleepimage
fi
check_status "SSD optimized"

echo "Enabling HiDPI display modes..."
sudo defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true
check_status "HiDPI display modes enabled"

echo "Restarting Dock..."
killall Dock
