#!/bin/bash
#
# Script: 054_configure_input_devices.sh
# Description: Configure Input Devices
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Configuring Input Devices (Keyboard, Mouse, Trackpad)..."

# Disable multitouch swipes (Navigate with scrolls)
echo "Disabling multitouch swipes..."
set_default NSGlobalDomain AppleEnableSwipeNavigateWithScrolls int 0

# Turn off keyboard illumination when computer is not used for 10 minutes
echo "Setting keyboard illumination timeout..."
set_default com.apple.BezelServices kDimTime int 600

# Set keyboard brightness to minimum but still lit
echo "Enabling keyboard brightness control..."
set_default com.apple.BezelServices kDim bool true

# Show Emoji and Symbols when pressing Fn key
echo "Setting Fn key to show Emoji & Symbols..."
set_default com.apple.HIToolbox AppleFnUsageType int 2

# Disable automatic capitalization
echo "Disabling auto-capitalization..."
set_default NSGlobalDomain NSAutomaticCapitalizationEnabled bool false

# Disable smart dashes
echo "Disabling smart dashes..."
set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled bool false

# Disable automatic period substitution
echo "Disabling auto-period substitution..."
set_default NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled bool false

# Disable smart quotes
echo "Disabling smart quotes..."
set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled bool false

# Disable auto-correct
echo "Disabling auto-correct..."
set_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled bool false

# Disable VoiceOver at login window
echo "Disabling VoiceOver at login window..."
execute_sudo defaults write /Library/Preferences/com.apple.loginwindow VoiceOver -bool false

echo "Input devices configuration complete."
