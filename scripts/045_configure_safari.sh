#!/bin/bash
echo "Clearing Safari Favorites..."

# Close Safari to ensure we can write to the file
killall Safari 2>/dev/null

BOOKMARKS_FILE="$HOME/Library/Safari/Bookmarks.plist"
BACKUP_FILE="$BOOKMARKS_FILE.bak"

if [ -f "$BOOKMARKS_FILE" ]; then
    echo "Backing up Bookmarks.plist..."
    cp "$BOOKMARKS_FILE" "$BACKUP_FILE"

    # Python script to parse and modify plist
    # We use system python3 which should be available on macOS
    python3 - <<EOF
import plistlib
import os
import sys

file_path = os.path.expanduser('~/Library/Safari/Bookmarks.plist')

try:
    with open(file_path, 'rb') as f:
        plist = plistlib.load(f)

    # Function to find and clear FavoritesBar
    def clear_favorites(node):
        if isinstance(node, dict):
            # Check if this node is the Favorites Bar
            # It is usually identified by WebBookmarkUUID 'FavoritesBar'
            if node.get('WebBookmarkUUID') == 'FavoritesBar':
                if 'Children' in node:
                    print(f"Clearing {len(node['Children'])} items from Favorites Bar...")
                    node['Children'] = []
                return True
            
            # Recursively check children
            if 'Children' in node:
                for child in node['Children']:
                    if clear_favorites(child):
                        return True
        return False

    # Traverse the plist
    if clear_favorites(plist):
        with open(file_path, 'wb') as f:
            plistlib.dump(plist, f)
        print("Successfully cleared Safari Favorites.")
    else:
        print("Favorites Bar not found or empty.")

except Exception as e:
    print(f"Error processing plist: {e}")
    sys.exit(1)
EOF

    if [ $? -eq 0 ]; then
        echo "Safari favorites cleared successfully."
    else
        echo "Failed to clear Safari favorites."
        # Restore backup if failed
        cp "$BACKUP_FILE" "$BOOKMARKS_FILE"
    fi

else
    echo "Bookmarks file not found at $BOOKMARKS_FILE. Safari might not have been run yet."
fi

echo "Disabling Safari 'launched' notifications..."
defaults write com.apple.coreservices.uiagent CSUIHasSafariBeenLaunched -bool YES
defaults write com.apple.coreservices.uiagent CSUIRecommendSafariNextNotificationDate -date 2099-01-01T00:00:00Z

echo "Configuring Safari Privacy and Security..."

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Disable AutoFill
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Disable Java
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

# Disable plug-ins
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

echo "Restarting Safari..."
killall Safari &> /dev/null

echo "Safari configuration complete."
