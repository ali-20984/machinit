#!/bin/bash
source "$(dirname "$0")/utils.sh"

echo "Configuring UI/UX and System Preferences..."

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

# Disable animated focus ring
echo "Disabling animated focus ring..."
set_default NSGlobalDomain NSUseAnimatedFocusRing bool false

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

# Set HostName to AdminHostInfo (requires sudo)
echo "Setting HostName..."
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
set_default com.apple.TextEdit PlainTextEncodingForWrite int 4

# Disk Utility Settings
echo "Configuring Disk Utility..."
# Enable the debug menu in Disk Utility
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
