#!/bin/bash
#
# Script: 047_configure_login_screen.sh
# Description: Configure Login Screen
# Author: supermarsx
#
echo "Configuring Login Screen..."

# Note: Modern macOS (Big Sur+) has very restricted login screen customization.
# Changing the actual font family or color of the clock is not natively supported 
# without modifying system files (which breaks system integrity).

# However, we can make the login experience more "console-like":

# 1. Show "Name and Password" input fields instead of the user list/avatars.
# This looks more like a traditional login prompt.
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# 2. Set a custom login banner text that looks like a system prompt.
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "SYSTEM_READY > Awaiting Authentication..."

# 3. Enable AdminHostInfo.
# This allows you to click the clock on the login screen to toggle through 
# system info (IP Address, Hostname, OS Version), which is very "console-like".
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo "Login screen configured."
echo "Note: The font color cannot be changed to red via standard configuration."
