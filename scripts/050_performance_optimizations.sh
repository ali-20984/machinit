#!/bin/bash
#
# Script: 050_performance_optimizations.sh
# Description: Performance Optimizations
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Running performance optimizations..."

# Function: check_status
# Description: Surface a concise success/failure message after each
#              optimization block for easier troubleshooting.
function check_status() {
    if [ $? -eq 0 ]; then
        echo "✓ $1"
    else
        echo "✗ Failed to: $1"
    fi
}

echo "Disabling global animations..."
set_default NSGlobalDomain NSAutomaticWindowAnimationsEnabled bool false
set_default NSGlobalDomain NSWindowResizeTime float 0.001
check_status "Global animations disabled"

echo "Optimizing SSD settings..."
# SSD optimizations
# Note: 'trimforce enable' requires a reboot and user confirmation.
# It is commented out to prevent interrupting the script flow.
# echo "y" | sudo trimforce enable

execute_sudo pmset -a hibernatemode 0
if [ -f /var/vm/sleepimage ]; then
    execute_sudo rm /var/vm/sleepimage
fi
check_status "SSD optimized"

echo "Enabling HiDPI display modes..."
execute_sudo defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true
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

# Restarting UI components is deferred until the end of the full installer
# to avoid mid-run restarts which can interfere with later settings.
# Use scripts/999_restart_apps.sh to restart apps when you finish the whole run.
