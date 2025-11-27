#!/bin/bash
echo "Hiding iCloud Drive from Finder sidebar..."

# Remove iCloud Drive from the sidebar using sfltool (for modern macOS versions)
# Note: This is a best-effort attempt as Apple changes these APIs frequently.
# Another approach is modifying com.apple.sidebarlists.plist but that is often cached.

# Attempt to remove using sfltool if available (macOS Sierra+)
if command -v sfltool &> /dev/null; then
    # This command might vary by macOS version. 
    # Trying to remove the item with the iCloud Drive URL.
    # The URL for iCloud Drive is usually file:///Users/username/Library/Mobile%20Documents/com~apple~CloudDocs/
    
    # This is a bit complex to do reliably via CLI without a dedicated tool like 'mysides'.
    # We will try to use 'defaults' to modify the sidebar preferences if possible, 
    # but modern macOS stores this in a binary plist or database managed by sfltool.
    
    echo "Note: Hiding iCloud Drive via script is experimental on recent macOS versions."
    
    # Try to remove from com.apple.finder.plist
    defaults write com.apple.finder SidebarICloudDrive -bool false
else
    echo "sfltool not found, trying defaults write..."
    defaults write com.apple.finder SidebarICloudDrive -bool false
fi

# Restart Finder to apply changes
killall Finder
echo "Finder restarted."
