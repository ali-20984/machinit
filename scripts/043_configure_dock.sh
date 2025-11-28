#!/bin/bash
echo "Configuring Dock size..."

# Set the icon size of Dock items to 36 pixels (default is usually around 64)
defaults write com.apple.dock tilesize -int 36

# Change minimize/maximize window effect
echo "Setting minimize effect to scale..."
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
echo "Minimizing windows into application icon..."
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
echo "Enabling spring loading..."
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
echo "Showing indicator lights for open apps..."
defaults write com.apple.dock show-process-indicators -bool true

# Speed up Mission Control animations
echo "Speeding up Mission Control animations..."
defaults write com.apple.dock expose-animation-duration -float 0.1

# Disable Dashboard
echo "Disabling Dashboard..."
defaults write com.apple.dashboard mcx-disabled -bool true

# Remove the auto-hiding Dock delay
echo "Removing auto-hide delay..."
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Automatically hide and show the Dock
echo "Enabling auto-hide..."
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
echo "Making hidden apps translucent..."
defaults write com.apple.dock showhidden -bool true

# Restart Dock to apply changes
killall Dock

echo "Dock size updated."
