#!/bin/bash
#
# Script: 052_configure_finder_and_sidebar.sh
# Description: Configure Finder And Sidebar
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Configuring Finder..."

# Allow quitting via ⌘ + Q; doing so will also hide desktop icons
echo "Allowing Quit in Finder..."
set_default com.apple.finder QuitMenuItem bool true

# Disable window animations and Get Info animations
echo "Disabling Finder animations..."
set_default com.apple.finder DisableAllAnimations bool true

# Show all filename extensions
echo "Showing all filename extensions..."
set_default NSGlobalDomain AppleShowAllExtensions bool true

# Show Library folder
echo "Unhiding ~/Library..."
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null

# Show status bar
echo "Showing status bar..."
set_default com.apple.finder ShowStatusBar bool true

# Show path bar
echo "Showing path bar..."
set_default com.apple.finder ShowPathbar bool true

# When performing a search, search the current folder by default
echo "Setting default search scope to current folder..."
set_default com.apple.finder FXDefaultSearchScope string "SCcf"

# Avoid creating .DS_Store files on network or USB volumes
echo "Preventing .DS_Store creation on network/USB volumes..."
set_default com.apple.desktopservices DSDontWriteNetworkStores bool true
set_default com.apple.desktopservices DSDontWriteUSBStores bool true

# Use list view in all Finder windows by default
echo "Setting default view style to List View..."
set_default com.apple.finder FXPreferredViewStyle string "Nlsv"

# Show the ~/Library folder
echo "Unhiding ~/Library..."
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null

# Show the /Volumes folder
echo "Unhiding /Volumes..."
sudo chflags nohidden /Volumes

# Sidebar Configurations
echo "Configuring Finder Sidebar..."

# Set sidebar icon size to Medium
echo "Setting sidebar icon size to Medium..."
set_default NSGlobalDomain NSTableViewDefaultSizeMode int 2

# Hide iCloud Drive
set_default com.apple.finder SidebarICloudDrive bool false

# Hide Shared Section (Bonjour)
set_default com.apple.finder SidebarBonjourBrowser bool false

# Hide Tags
set_default com.apple.finder ShowRecentTags bool false

# Create Projects folder and symlink
echo "Setting up Projects folder..."
mkdir -p "$HOME/Documents/Projects"
if [ ! -d "$HOME/Projects" ]; then
    ln -s "$HOME/Documents/Projects" "$HOME/Projects"
    echo "Symlinked ~/Documents/Projects to ~/Projects"
fi

# Add items to Sidebar Favorites (Best effort using sfltool)
# Note: This is experimental and might not work on all macOS versions without 'mysides'
if command -v sfltool &>/dev/null; then
    echo "Attempting to add items to sidebar using sfltool..."
    # Add Home
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://${HOME}"
    # Add Computer
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///"
    # Add Projects
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://${HOME}/Projects"
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
