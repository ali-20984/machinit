#!/bin/bash
#
# Script: 050_performance_optimizations.sh
# Description: Performance Optimizations
# Author: supermarsx
#
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

echo "Disabling background items (Best Effort)..."
# Attempt to disable known background agents
# Note: On macOS Ventura+, this is managed by TCC and backgroundtaskmanagementd.
# We can try to unload them if they are running or disable their plist if accessible.

agents_to_disable=(
    "com.adobe.AdobeCreativeCloud"
    "com.adobe.CCXProcess"
    "com.microsoft.office.licensingV2.helper"
    "net.openvpn.client.app"
)

for agent in "${agents_to_disable[@]}"; do
    if launchctl list | grep -q "$agent"; then
        echo "Unloading $agent..."
        launchctl unload -w ~/Library/LaunchAgents/"$agent".plist 2>/dev/null || true
        launchctl disable user/"$(id -u)"/"$agent" 2>/dev/null || true
    fi
done

echo "Restarting Dock..."
killall Dock
