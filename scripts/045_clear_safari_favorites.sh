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
        print("Favorites Bar not found in plist.")

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
