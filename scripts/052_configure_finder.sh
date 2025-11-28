#!/bin/bash
echo "Configuring Finder..."

# Allow quitting via ⌘ + Q; doing so will also hide desktop icons
echo "Allowing Quit in Finder..."
defaults write com.apple.finder QuitMenuItem -bool true

# Disable window animations and Get Info animations
echo "Disabling Finder animations..."
defaults write com.apple.finder DisableAllAnimations -bool true

# Show all filename extensions
echo "Showing all filename extensions..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
echo "Showing status bar..."
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
echo "Showing path bar..."
defaults write com.apple.finder ShowPathbar -bool true

# When performing a search, search the current folder by default
echo "Setting default search scope to current folder..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network or USB volumes
echo "Preventing .DS_Store creation on network/USB volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
echo "Setting default view style to List View..."
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
echo "Unhiding ~/Library..."
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null

# Show the /Volumes folder
echo "Unhiding /Volumes..."
sudo chflags nohidden /Volumes

# Sidebar Configurations
echo "Configuring Finder Sidebar..."

# Hide iCloud Drive
defaults write com.apple.finder SidebarICloudDrive -bool false

# Hide Shared Section (Bonjour)
defaults write com.apple.finder SidebarBonjourBrowser -bool false

# Hide Tags
defaults write com.apple.finder ShowRecentTags -bool false

# Add items to Sidebar Favorites (Best effort using sfltool)
# Note: This is experimental and might not work on all macOS versions without 'mysides'
if command -v sfltool &> /dev/null; then
    echo "Attempting to add items to sidebar using sfltool..."
    # Add Home
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://${HOME}"
    # Add Computer
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///"
    # Add Photos (if exists)
    if [ -d "${HOME}/Pictures/Photos Library.photoslibrary" ]; then
         sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://${HOME}/Pictures/Photos Library.photoslibrary"
    elif [ -d "/System/Applications/Photos.app" ]; then
         sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///System/Applications/Photos.app"
    fi
    # Trash is not typically added to Sidebar Favorites, usually in Dock.
fi

echo "Restarting Finder..."
killall Finder

echo "Finder configuration complete."
