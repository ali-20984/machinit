#!/bin/bash
#
# Script: 020_configure_firefox_policies.sh
# Description: Configure Firefox Policies
# Author: supermarsx
#
echo "Configuring Firefox extensions..."

FIREFOX_APP="/Applications/Firefox.app"
DIST_DIR="$FIREFOX_APP/Contents/Resources/distribution"
POLICIES_FILE="$DIST_DIR/policies.json"

if [ ! -d "$FIREFOX_APP" ]; then
    echo "Firefox is not installed at $FIREFOX_APP. Skipping extension configuration."
    exit 1
fi

echo "Creating distribution directory..."
# Try to create directory, use sudo if permission denied
if ! mkdir -p "$DIST_DIR" 2>/dev/null; then
    echo "Requesting sudo permissions to create Firefox distribution directory..."
    sudo mkdir -p "$DIST_DIR"
fi

echo "Writing policies.json..."

# Define policies content
cat <<EOF > /tmp/firefox_policies.json
{
  "policies": {
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/colorzilla/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/clear-cache/latest.xpi"
      ]
    }
  }
}
EOF

# Move file to destination, use sudo if needed
if ! mv /tmp/firefox_policies.json "$POLICIES_FILE" 2>/dev/null; then
    echo "Requesting sudo permissions to write policies.json..."
    sudo mv /tmp/firefox_policies.json "$POLICIES_FILE"
fi

# Set permissions
if ! chmod 644 "$POLICIES_FILE" 2>/dev/null; then
    sudo chmod 644 "$POLICIES_FILE"
fi

echo "Firefox extensions configured via policies.json."
