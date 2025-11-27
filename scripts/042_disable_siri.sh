#!/bin/bash
echo "Fully disabling Siri..."

# Disable Siri
defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# Remove Siri from Menu Bar
defaults write com.apple.Siri StatusMenuVisible -bool false

# Disable "Ask Siri"
defaults write com.apple.Siri UserHasDeclinedEnable -bool true

# Kill SystemUIServer to refresh menu bar
killall SystemUIServer 2>/dev/null

# Kill Siri processes if running
killall Siri 2>/dev/null

echo "Siri has been disabled."
