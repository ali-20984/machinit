#!/bin/bash
#
# Script: 047_configure_login_screen.sh
# Description: Configure Login Screen
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_info "Configuring Login Screen..."

# Note: Modern macOS (Big Sur+) has very restricted login screen customization.
# Changing the actual font family or color of the clock is not natively supported
# without modifying system files (which breaks system integrity).

# However, we can make the login experience more "console-like":

# 1. Show "Name and Password" input fields instead of the user list/avatars.
# This looks more like a traditional login prompt.
execute_sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# 2. Set a custom login banner text that looks like a system prompt.
execute_sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "SYSTEM_READY > Awaiting Authentication..."

# 3. Enable AdminHostInfo.
# This allows you to click the clock on the login screen to toggle through
# system info (IP Address, Hostname, OS Version), which is very "console-like".
execute_sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

print_success "Login screen configured."
print_info "Note: The font color cannot be changed to red via standard configuration."
