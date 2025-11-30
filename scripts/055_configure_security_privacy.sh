#!/bin/bash
#
# Script: 055_configure_security_privacy.sh
# Description: Configure Security Privacy
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_config "Security and Privacy"

# Disable Crash Reporter
echo "Disabling Crash Reporter..."
set_default com.apple.CrashReporter DialogType string "none"

# Enable Firewall, Stealth Mode, and Block All Incoming Connections
print_config "Firewall"
execute_sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
execute_sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
execute_sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on

# Disallow AirDrop (set to no one)
echo "Disabling AirDrop..."
defaults write com.apple.NetworkBrowser DisableAirDrop -bool true

# Disable AirPlay Receiver
echo "Disabling AirPlay Receiver..."
defaults write com.apple.airplay receiverEnabled -bool false

# Bypass confirmation to open apps installed by Brew (Disable Quarantine)
echo "Disabling Quarantine for downloaded apps..."
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Security and Privacy configuration complete."
