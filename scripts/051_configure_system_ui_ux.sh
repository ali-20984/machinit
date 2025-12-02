#!/bin/bash
#
# Script: 051_configure_system_ui_ux.sh
# Description: Configure System Ui Ux
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_config "UI/UX and System Preferences"

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Fully set dark mode
echo "Setting Dark Mode..."
set_default NSGlobalDomain AppleInterfaceStyle string "Dark"

# Disable transparency in the menu bar and elsewhere on Yosemite (and later)
echo "Disabling transparency..."
set_default com.apple.universalaccess reduceTransparency bool true

# Reduce motion and differentiate without color (Accessibility)
echo "Reducing motion and enabling differentiate without color..."
set_default com.apple.Accessibility DifferentiateWithoutColor int 1
set_default com.apple.Accessibility ReduceMotionEnabled int 1
set_default com.apple.universalaccess reduceMotion int 1

# Disable the sound effects on boot
echo "Disabling boot sound effects..."
execute_sudo nvram SystemAudioVolume=" "
execute_sudo nvram StartupMute=%01

# Menu bar: show battery percentage
echo "Showing battery percentage..."
set_default com.apple.menuextra.battery ShowPercent string "YES"

# Disable animated focus ring
echo "Disabling animated focus ring..."
set_default NSGlobalDomain NSUseAnimatedFocusRing bool false

# Disable opening and closing window animations
echo "Disabling window animations..."
set_default NSGlobalDomain NSAutomaticWindowAnimationsEnabled bool false

# Expand print panel by default
echo "Expanding print panel..."
set_default NSGlobalDomain PMPrintingExpandedStateForPrint bool true
set_default NSGlobalDomain PMPrintingExpandedStateForPrint2 bool true

# Expand save panel by default
echo "Expanding save panel..."
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode bool true
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 bool true

# Save to disk (not to iCloud) by default
echo "Setting save to disk by default..."
set_default NSGlobalDomain NSDocumentSaveNewDocumentsToCloud bool false

# Automatically quit printer app once the print jobs complete
echo "Auto-quit printer app..."
set_default com.apple.print.PrintingPrefs "Quit When Finished" bool true

# Disable Dashboard
echo "Disabling Dashboard..."
set_default com.apple.dashboard mcx-disabled bool true

# Disable Sudden Motion Sensor
echo "Disabling Sudden Motion Sensor..."
execute_sudo pmset -a sms 0

# Allow wallpaper tinting in windows
echo "Allowing wallpaper tinting in windows..."
set_default NSGlobalDomain AppleReduceDesktopTinting bool false

# Set HostName to AdminHostInfo (requires sudo)
# Note: This might conflict with the manual HostName setting above if run repeatedly,
# but ensures login window shows the correct name.
echo "Setting HostName for Login Window..."
execute_sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set measurement units
echo "Setting measurement units to Centimeters..."
set_default NSGlobalDomain AppleMeasurementUnits string "Centimeters"
set_default NSGlobalDomain AppleMetricUnits bool true

# Set Locale
echo "Setting Locale..."
set_default NSGlobalDomain AppleLocale string "en_US@currency=EUR"

# Set the time zone
echo "Setting time zone to automatic..."
execute_sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
execute_sudo systemsetup -setusingnetworktime on

# Require password 10 seconds after sleep or screen saver begins
echo "Requiring password 10 seconds after sleep/screensaver..."
set_default com.apple.screensaver askForPassword int 1
set_default com.apple.screensaver askForPasswordDelay int 10

# Screen Capture Settings
print_config "Screen Capture"
# Save screenshots to the Downloads folder
set_default com.apple.screencapture location string "${HOME}/Downloads"
# Save screenshots in PNG format
set_default com.apple.screencapture type string "png"
# Disable shadow in screenshots
set_default com.apple.screencapture disable-shadow bool true

# Enable debug menu in Disk Utility
set_default com.apple.DiskUtility DUDebugMenuEnabled bool true
set_default com.apple.DiskUtility advanced-image-options bool true

# NOTE: restarting applications is intentionally deferred.
# Previously we restarted several processes here which caused mid-run
# restarts and could interfere with other scripts (e.g. Dock changes).
# To avoid clobbering UI settings and pinned Dock entries, we now defer
# all app restarts until the end of the full install. Run
# scripts/999_restart_apps.sh once the installer is finished (or run it
# manually) to restart affected applications.

echo "UI/UX configuration complete. Note: Some changes may require a logout/restart to take effect."
