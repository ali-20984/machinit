#!/bin/bash
#
# Script: 020_configure_firefox_policies.sh
# Description: Configure Firefox Policies
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_info "Configuring Firefox extensions..."

FIREFOX_APP="/Applications/Firefox.app"
DIST_DIR="$FIREFOX_APP/Contents/Resources/distribution"
POLICIES_FILE="$DIST_DIR/policies.json"
FDA_HINT=$'Grant the terminal running MachInit "Full Disk Access" (System Settings → Privacy & Security → Full Disk Access) and rerun this script with `./install.sh --start-from 020_configure_firefox_policies.sh`.'

function ensure_distribution_dir() {
    if execute mkdir -p "$DIST_DIR"; then
        return 0
    fi

    print_info "Retrying directory creation with sudo..."
    if execute_sudo mkdir -p "$DIST_DIR"; then
        return 0
    fi

    print_error "Unable to create $DIST_DIR. $FDA_HINT"
    return 1
}

function move_policies() {
    local source_file="$1"
    if mv "$source_file" "$POLICIES_FILE" 2>/dev/null; then
        return 0
    fi

    print_info "Retrying policies copy with sudo..."
    if execute_sudo mv "$source_file" "$POLICIES_FILE"; then
        return 0
    fi

    print_error "Unable to write $POLICIES_FILE. $FDA_HINT"
    return 1
}

function secure_policies() {
    if chmod 644 "$POLICIES_FILE" 2>/dev/null; then
        return 0
    fi

    print_info "Retrying chmod with sudo..."
    if execute_sudo chmod 644 "$POLICIES_FILE"; then
        return 0
    fi

    print_error "Unable to set permissions on $POLICIES_FILE. $FDA_HINT"
    return 1
}

if [ ! -d "$FIREFOX_APP" ]; then
    print_info "Firefox is not installed at $FIREFOX_APP. Skipping configuration."
    exit 0
fi

print_info "Creating distribution directory..."
if ! ensure_distribution_dir; then
    exit 1
fi

if [ "$DRY_RUN" = true ]; then
    print_dry_run "Write policies.json to $POLICIES_FILE"
    print_dry_run "chmod 644 $POLICIES_FILE"
    exit 0
fi

print_info "Writing policies.json..."
TMP_POLICIES=$(mktemp)
cat <<'EOF' >"$TMP_POLICIES"
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

if ! move_policies "$TMP_POLICIES"; then
    rm -f "$TMP_POLICIES"
    exit 1
fi

if ! secure_policies; then
    exit 1
fi

print_success "Firefox extensions configured via policies.json."
