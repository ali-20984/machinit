#!/bin/bash
source "$(dirname "$0")/utils.sh"

echo "Configuring UI/UX and System Preferences..."

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
sudo nvram SystemAudioVolume=" "
sudo nvram StartupMute=%01

# Menu bar: show battery percentage
echo "Showing battery percentage..."
set_default com.apple.menuextra.battery ShowPercent string "YES"

# Disable animated focus ring
echo "Disabling animated focus ring..."
set_default NSGlobalDomain NSUseAnimatedFocusRing bool false

# Disable opening and closing window animations
echo "Disabling window animations..."
set_default NSGlobalDomain NSAutomaticWindowAnimationsEnabled bool false

# Disable multitouch swipes (Navigate with scrolls)
echo "Disabling multitouch swipes..."
set_default NSGlobalDomain AppleEnableSwipeNavigateWithScrolls int 0

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

# Disable Crash Reporter
echo "Disabling Crash Reporter..."
set_default com.apple.CrashReporter DialogType string "none"

# Disable Dashboard
echo "Disabling Dashboard..."
set_default com.apple.dashboard mcx-disabled bool true

# Prevent Photos from opening automatically when devices are plugged in
echo "Preventing Photos from opening automatically..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Disable Sudden Motion Sensor
echo "Disabling Sudden Motion Sensor..."
sudo pmset -a sms 0

# Enable Firewall, Stealth Mode, and Block All Incoming Connections
echo "Configuring Firewall..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on

# Disallow AirDrop (set to no one)
echo "Disabling AirDrop..."
defaults write com.apple.NetworkBrowser DisableAirDrop -bool true

# Disable AirPlay Receiver
echo "Disabling AirPlay Receiver..."
defaults write com.apple.airplay receiverEnabled -bool false

# Allow wallpaper tinting in windows
echo "Allowing wallpaper tinting in windows..."
set_default NSGlobalDomain AppleReduceDesktopTinting bool false

# Disable VoiceOver at login window
echo "Disabling VoiceOver at login window..."
sudo defaults write /Library/Preferences/com.apple.loginwindow VoiceOver -bool false

# Turn off keyboard illumination when computer is not used for 10 minutes
echo "Setting keyboard illumination timeout..."
set_default com.apple.BezelServices kDimTime int 600

# Set keyboard brightness to minimum but still lit (requires 'brightness' tool or similar, best effort via defaults)
# Note: There is no direct 'defaults' key for brightness level that persists reliably.
# We ensure the feature is enabled.
echo "Enabling keyboard brightness control..."
set_default com.apple.BezelServices kDim bool true

# Show Emoji and Symbols when pressing Fn key
echo "Setting Fn key to show Emoji & Symbols..."
set_default com.apple.HIToolbox AppleFnUsageType int 2

# Set HostName to AdminHostInfo (requires sudo)
# Note: This might conflict with the manual HostName setting above if run repeatedly, 
# but ensures login window shows the correct name.
echo "Setting HostName for Login Window..."
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

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

# Set measurement units
echo "Setting measurement units to Centimeters..."
set_default NSGlobalDomain AppleMeasurementUnits string "Centimeters"
set_default NSGlobalDomain AppleMetricUnits bool true

# Set Locale
echo "Setting Locale..."
set_default NSGlobalDomain AppleLocale string "en_US@currency=EUR"

# Set the time zone
echo "Setting time zone to automatic..."
sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
sudo systemsetup -setusingnetworktime on

# Require password 10 seconds after sleep or screen saver begins
echo "Requiring password 10 seconds after sleep/screensaver..."
set_default com.apple.screensaver askForPassword int 1
set_default com.apple.screensaver askForPasswordDelay int 10

# Screen Capture Settings
echo "Configuring Screen Capture..."
# Save screenshots to the Downloads folder
set_default com.apple.screencapture location string "${HOME}/Downloads"
# Save screenshots in PNG format
set_default com.apple.screencapture type string "png"
# Disable shadow in screenshots
set_default com.apple.screencapture disable-shadow bool true

# Time Machine Settings
echo "Configuring Time Machine..."
# Prevent Time Machine from prompting to use new hard drives as backup volume
set_default com.apple.TimeMachine DoNotOfferNewDisksForBackup bool true
# Disable local Time Machine backups
if hash tmutil &> /dev/null; then
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

# Disable hot corners
echo "Disabling hot corners..."
set_default com.apple.dock wvous-tl-corner int 0
set_default com.apple.dock wvous-tr-corner int 0
set_default com.apple.dock wvous-bl-corner int 0
set_default com.apple.dock wvous-br-corner int 0

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

echo "Restarting affected applications..."
set_default com.apple.DiskUtility DUDebugMenuEnabled bool true
set_default com.apple.DiskUtility advanced-image-options bool true

echo "Restarting affected applications..."
for app in "Activity Monitor" \
    "Address Book" \
    "Calendar" \
    "cfprefsd" \
    "Contacts" \
    "Dock" \
    "Finder" \
    "Google Chrome Canary" \
    "Google Chrome" \
    "Mail" \
    "Messages" \
    "Opera" \
    "Photos" \
    "Safari" \
    "SizeUp" \
    "Spectacle" \
    "SystemUIServer" \
    "Terminal" \
    "Transmission" \
    "Tweetbot" \
    "Twitter" \
    "iCal"; do
    killall "${app}" &> /dev/null
done

echo "UI/UX configuration complete. Note: Some changes may require a logout/restart to take effect."
