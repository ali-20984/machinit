#!/bin/bash
echo "Configuring Dock size..."

# Set the icon size of Dock items to 36 pixels (default is usually around 64)
defaults write com.apple.dock tilesize -int 36

# Restart Dock to apply changes
killall Dock

echo "Dock size updated."
