#!/bin/bash
#
# Script: 056_configure_system_apps.sh
# Description: Configure System Apps
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Configuring System Applications..."

# Prevent Photos from opening automatically when devices are plugged in
echo "Preventing Photos from opening automatically..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Time Machine Settings
echo "Configuring Time Machine..."
# Prevent Time Machine from prompting to use new hard drives as backup volume
set_default com.apple.TimeMachine DoNotOfferNewDisksForBackup bool true
# Disable local Time Machine backups
if hash tmutil &>/dev/null; then
    sudo tmutil disablelocal 2>/dev/null || echo "Note: 'tmutil disablelocal' might not be supported on this macOS version."
fi

# Activity Monitor Settings
echo "Configuring Activity Monitor..."
# Show the main window when launching Activity Monitor
set_default com.apple.ActivityMonitor OpenMainWindow bool true
# Show all processes in Activity Monitor
set_default com.apple.ActivityMonitor ShowCategory int 0

# TextEdit Settings
echo "Configuring TextEdit..."
# Open and save files as UTF-8 in TextEdit
set_default com.apple.TextEdit PlainTextEncoding int 4
# Enable the debug menu in Disk Utility
set_default com.apple.DiskUtility DUDebugMenuEnabled bool true
set_default com.apple.DiskUtility advanced-image-options bool true

# App Store and Software Update Settings
echo "Configuring App Store and Software Update..."
# Turn on app auto-update
set_default com.apple.commerce AutoUpdate bool true
# Allow the App Store to reboot machine on macOS updates
set_default com.apple.commerce AutoUpdateRestartRequired bool true
# Install System data files & security updates
set_default com.apple.SoftwareUpdate CriticalUpdateInstall bool true
# Download newly available updates in background
set_default com.apple.SoftwareUpdate AutomaticDownload bool false
# Enable the automatic update check
set_default com.apple.SoftwareUpdate AutomaticCheckEnabled bool false

echo "System Applications configuration complete."
