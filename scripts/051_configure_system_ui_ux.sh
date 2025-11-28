#!/bin/bash
echo "Configuring UI/UX and System Preferences..."

# Fully set dark mode
echo "Setting Dark Mode..."
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Disable transparency in the menu bar and elsewhere on Yosemite (and later)
echo "Disabling transparency..."
defaults write com.apple.universalaccess reduceTransparency -bool true

# Reduce motion and differentiate without color (Accessibility)
echo "Reducing motion and enabling differentiate without color..."
defaults write com.apple.Accessibility DifferentiateWithoutColor -int 1
defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
defaults write com.apple.universalaccess reduceMotion -int 1

# Disable the sound effects on boot
echo "Disabling boot sound effects..."
sudo nvram SystemAudioVolume=" "

# Disable animated focus ring
echo "Disabling animated focus ring..."
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Expand print panel by default
echo "Expanding print panel..."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Expand save panel by default
echo "Expanding save panel..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Save to disk (not to iCloud) by default
echo "Setting save to disk by default..."
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
echo "Auto-quit printer app..."
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable Crash Reporter
echo "Disabling Crash Reporter..."
defaults write com.apple.CrashReporter DialogType -string "none"

# Set HostName to AdminHostInfo (requires sudo)
echo "Setting HostName..."
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable automatic capitalization
echo "Disabling auto-capitalization..."
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
echo "Disabling smart dashes..."
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
echo "Disabling auto-period substitution..."
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
echo "Disabling smart quotes..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
echo "Disabling auto-correct..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Set measurement units
echo "Setting measurement units to Centimeters..."
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set Locale
echo "Setting Locale..."
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"

# Require password 10 seconds after sleep or screen saver begins
echo "Requiring password 10 seconds after sleep/screensaver..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 10

# Screen Capture Settings
echo "Configuring Screen Capture..."
# Save screenshots to the Downloads folder
defaults write com.apple.screencapture location -string "${HOME}/Downloads"
# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Time Machine Settings
echo "Configuring Time Machine..."
# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
# Disable local Time Machine backups
if hash tmutil &> /dev/null; then
    sudo tmutil disablelocal 2>/dev/null || echo "Note: 'tmutil disablelocal' might not be supported on this macOS version."
fi

# Activity Monitor Settings
echo "Configuring Activity Monitor..."
# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# TextEdit Settings
echo "Configuring TextEdit..."
# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Disk Utility Settings
echo "Configuring Disk Utility..."
# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

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
