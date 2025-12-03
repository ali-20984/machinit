#!/bin/bash
#
# Script: 052_configure_finder_and_sidebar.sh
# Description: Configure Finder And Sidebar
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_config "Finder"

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
# Ensure we operate on the original user's home when the installer is run under sudo
execute_as_user chflags nohidden "${ORIGINAL_HOME}/Library" &>/dev/null || true
execute_as_user xattr -d com.apple.FinderInfo "${ORIGINAL_HOME}/Library" 2>/dev/null || true

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
execute_sudo chflags nohidden /Volumes

# Sidebar Configurations
print_config "Finder Sidebar"

# Set sidebar icon size to Medium
echo "Setting sidebar icon size to Medium..."
# Write per-user preference using helper
set_user_default NSGlobalDomain NSTableViewDefaultSizeMode int 2 || true

# Ensure new Finder windows open at the user's Desktop
echo "Setting Finder default new-window location to Desktop..."
# Ensure Desktop exists in the original user's home
execute_as_user mkdir -p "${ORIGINAL_HOME}/Desktop" || true
# Set Finder to open new windows to Desktop (PfDe) and point the path to the user's Desktop
set_user_default com.apple.finder NewWindowTarget string PfDe || true
set_user_default com.apple.finder NewWindowTargetPath string "file://${ORIGINAL_HOME}/Desktop/" || true

# Hide iCloud Drive
set_user_default com.apple.finder SidebarICloudDrive bool false || true

# Hide Shared Section (Bonjour)
set_user_default com.apple.finder SidebarBonjourBrowser bool false || true

# Hide Tags
set_user_default com.apple.finder ShowRecentTags bool false || true

# Create Projects folder and symlink
echo "Setting up Projects folder in user home..."
execute_as_user mkdir -p "${ORIGINAL_HOME}/Documents/Projects"
if [ ! -d "${ORIGINAL_HOME}/Projects" ]; then
    execute_as_user ln -s "${ORIGINAL_HOME}/Documents/Projects" "${ORIGINAL_HOME}/Projects" || true
    echo "Symlinked ${ORIGINAL_HOME}/Documents/Projects to ${ORIGINAL_HOME}/Projects"
fi

# Note: Adding Finder sidebar favorites programmatically is not reliably supported
# Attempt automated sidebar additions. Prefer `mysides` if available, fall back
# to an AppleScript UI automation (requires Accessibility permissions).

add_sidebar_item() {
    local name="$1"
    local target="$2"

    # Resolve to absolute path
    target="$(cd "$(dirname "$target")" 2>/dev/null && pwd)/$(basename "$target")"

    # Prefer Homebrew-installed mysides (may be in /usr/local or /opt/homebrew)
    local mysides_bin=""
    for p in "/usr/local/bin/mysides" "/opt/homebrew/bin/mysides" "/usr/bin/mysides"; do
        if [ -x "$p" ]; then
            mysides_bin="$p"
            break
        fi
    done

    if [ -n "$mysides_bin" ]; then
        print_action "Adding '$name' to Finder sidebar using mysides..."
        # Construct file:// URL (escape spaces/unsafe chars)
        if command -v python3 >/dev/null 2>&1; then
            fileurl="file://$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$target")"
        else
            # Fallback: naive space-escape
            fileurl="file://$(echo "$target" | sed 's/ /%20/g')"
        fi

        # Try with file:// URL first, then raw path
        # Run mysides as the original user so changes land in the right account
        if execute_as_user "$mysides_bin" add "$name" "$fileurl" >/dev/null 2>&1; then
            print_success "Added '$name' (via mysides URL)."
            return 0
        elif execute_as_user "$mysides_bin" add "$name" "$target" >/dev/null 2>&1; then
            print_success "Added '$name' (via mysides path)."
            return 0
        else
            print_warning "mysides failed to add '$name' — falling back to AppleScript UI method."
        fi
    else
        print_notice "mysides not found; will try AppleScript UI fallback."
    fi

    # AppleScript fallback: select the folder in Finder and use the File > Add to Sidebar menu
    print_action "Adding '$name' to Finder sidebar using AppleScript (requires Accessibility permission)..."
    # Run AppleScript as the original user so the script interacts with the user's Finder session
    execute_as_user /usr/bin/osascript <<EOF
tell application "Finder"
    try
        set targetFolder to (POSIX file "$target") as alias
        -- Open the folder so Finder has a selection
        open targetFolder
        delay 0.2
        set selection to targetFolder
    on error errMsg
        -- If folder not reachable, attempt to create or report
    end try
end tell
tell application "System Events"
    tell process "Finder"
        try
            click menu item "Add to Sidebar" of menu "File" of menu bar 1
        on error
            -- Some localizations or OS versions may not have this menu item
        end try
    end tell
end tell
EOF

    # No reliable way to detect success programmatically from AppleScript here — assume best-effort
    print_notice "AppleScript attempt complete. If nothing changed, grant Accessibility permission to Terminal/Installer and try again."
}

# Add the Projects folder created above to the sidebar (friendly name: Projects)

print_action "Configuring Finder sidebar favorites..."
# Use the original home path when adding the item
add_sidebar_item "Projects" "${ORIGINAL_HOME}/Documents/Projects"

# Flush cfprefsd cache for the original user so Finder will pick up the new settings
print_info "Flushing preference cache for user ${ORIGINAL_USER}..."
execute_as_user killall cfprefsd &>/dev/null || true

print_notice "Finder restarts are deferred until the final restart step. Run scripts/999_restart_apps.sh when the full run is complete to restart Finder and apply changes."

echo "Finder configuration complete."

## Verification: ensure per-user settings were written
print_config "Verify Finder settings"
verify_ok=true

# Verify NewWindowTarget
nw_target=$(execute_as_user defaults read com.apple.finder NewWindowTarget 2>/dev/null || true)
if [ "$nw_target" = "PfDe" ]; then
    print_success "NewWindowTarget correctly set to PfDe"
else
    print_error "NewWindowTarget not set (observed: ${nw_target:-<empty>})"
    verify_ok=false
fi

# Verify NewWindowTargetPath
nw_path=$(execute_as_user defaults read com.apple.finder NewWindowTargetPath 2>/dev/null || true)
expected_path="file://${ORIGINAL_HOME}/Desktop/"
if [ "$nw_path" = "$expected_path" ]; then
    print_success "NewWindowTargetPath correctly points to Desktop"
else
    print_error "NewWindowTargetPath not set as expected (observed: ${nw_path:-<empty>})"
    verify_ok=false
fi

# Verify sidebar short settings
for key in SidebarICloudDrive SidebarBonjourBrowser ShowRecentTags; do
    val=$(execute_as_user defaults read com.apple.finder "$key" 2>/dev/null || true)
    if [ "$val" = "0" ] || [ "$val" = "false" ]; then
        print_success "$key = false"
    else
        print_error "$key not false (observed: ${val:-<empty>})"
        verify_ok=false
    fi
done

if [ "$verify_ok" = true ]; then
    print_success "Finder sidebar configuration verified (user: ${ORIGINAL_USER})."
else
    print_warning "Finder sidebar verification failed in some checks. You may need to run scripts/999_restart_apps.sh to pick up changes, or check TCC/MDM policies."
fi
