#!/bin/bash
#
# Script: 044_configure_dock_apps.sh
# Description: Configure Dock Apps
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_config "Dock Apps"

echo "Ensuring dockutil is installed..."
install_brew_package dockutil

if ! command -v dockutil &>/dev/null; then
	print_error "dockutil not found even after attempted installation. Skipping Dock configuration."
	exit 0
fi

# Function: find_app
# Description: Find an app by name pattern in common locations
find_app() {
    local pattern="$1"
    local app_path=""
    
    # Search in /Applications and /System/Applications
    app_path=$(find /Applications /System/Applications /System/Applications/Utilities \
        -maxdepth 2 -name "*.app" 2>/dev/null | grep -i "$pattern" | head -1)
    
    echo "$app_path"
}

echo "Clearing existing Dock items..."
execute dockutil --remove all --no-restart

echo "Adding apps to Dock..."

# Define apps to add: "search pattern|display name"
declare -a DOCK_APPS=(
    "Visual Studio Code|Visual Studio Code"
    "Firefox|Firefox"
    "Terminal.app|Terminal"
    "Beeper|Beeper"
    "Bitwarden|Bitwarden"
    "GitHub Desktop|GitHub Desktop"
    "Microsoft Word|Microsoft Word"
    "Microsoft Excel|Microsoft Excel"
)

for entry in "${DOCK_APPS[@]}"; do
    IFS='|' read -r pattern label <<< "$entry"
    
    app_path=$(find_app "$pattern")
    
    if [ -z "$app_path" ] || [ ! -e "$app_path" ]; then
        print_skip "Skipping $label (not found)"
        continue
    fi

    if execute dockutil --add "$app_path" --no-restart; then
        print_success "Pinned $label to the Dock."
    else
        print_error "Failed to pin $label."
    fi
done

# Restart Dock to apply changes
execute killall Dock

echo "Dock apps configured."
