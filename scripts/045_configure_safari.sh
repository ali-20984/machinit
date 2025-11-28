#!/bin/bash
source "$(dirname "$0")/utils.sh"

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
set_default com.apple.coreservices.uiagent CSUIHasSafariBeenLaunched bool YES
# Date handling in set_default is tricky, using raw defaults write for date
defaults write com.apple.coreservices.uiagent CSUIRecommendSafariNextNotificationDate -date 2099-01-01T00:00:00Z

echo "Configuring Safari Privacy and Security..."

# Privacy: don’t send search queries to Apple
set_default com.apple.Safari UniversalSearchEnabled bool false
set_default com.apple.Safari SuppressSearchSuggestions bool true

# Show the full URL in the address bar (note: this still hides the scheme)
set_default com.apple.Safari ShowFullURLInSmartSearchField bool true

# Allow hitting the Backspace key to go to the previous page in history
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled bool true

# Hide Safari’s bookmarks bar by default
set_default com.apple.Safari ShowFavoritesBar bool false

# Hide Safari’s sidebar in Top Sites
set_default com.apple.Safari ShowSidebarInTopSites bool false

# Disable Safari’s thumbnail cache for History and Top Sites
set_default com.apple.Safari DebugSnapshotsUpdatePolicy int 2

# Enable the Develop menu and the Web Inspector in Safari
set_default com.apple.Safari IncludeDevelopMenu bool true
set_default com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey bool true
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled bool true

# Disable AutoFill
set_default com.apple.Safari AutoFillFromAddressBook bool false
set_default com.apple.Safari AutoFillPasswords bool false
set_default com.apple.Safari AutoFillCreditCardData bool false
set_default com.apple.Safari AutoFillMiscellaneousForms bool false

# Warn about fraudulent websites
set_default com.apple.Safari WarnAboutFraudulentWebsites bool true

# Disable Java
set_default com.apple.Safari WebKitJavaEnabled bool false
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled bool false
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles bool false

# Improve Safari security (Explicitly disable Java again)
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled bool false
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles bool false

# Disable plug-ins
set_default com.apple.Safari WebKitPluginsEnabled bool false
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled bool false

# Block pop-up windows
set_default com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically bool false
set_default com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically bool false

# Clear Safari History
echo "Clearing Safari History..."
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would clear Safari History files."
else
    rm -rf ~/Library/Safari/History.db
    rm -rf ~/Library/Safari/History.db-lock
    rm -rf ~/Library/Safari/History.db-shm
    rm -rf ~/Library/Safari/History.db-wal
    rm -rf ~/Library/Safari/LastSession.plist
    rm -rf ~/Library/Safari/RecentlyClosedTabs.plist
    print_success "Safari History cleared."
fi

echo "Restarting Safari..."
killall Safari &> /dev/null

echo "Safari configuration complete."
