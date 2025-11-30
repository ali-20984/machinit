#!/bin/bash
#
# Script: 057_organize_applications.sh
# Description: Group installed applications into Utilities/Entertainment folders.
# Author: supermarsx
#

source "$(dirname "$0")/utils.sh"

set -e

echo "Organizing Applications folders..."

UTILITIES_DIR="/Applications/Utilities"
ENTERTAINMENT_DIR="/Applications/Entertainment"

# Function: ensure_directory
# Description: Create destination folders with sudo when they do not exist.
function ensure_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        print_dry_run "sudo mkdir -p \"$dir\""
    else
        execute_sudo mkdir -p "$dir"
    fi
    print_success "Ensured directory $dir exists."
}

# Function: move_app_to_directory
# Description: Relocate third-party apps into the requested folder when found.
function move_app_to_directory() {
    local source_path="$1"
    local destination_dir="$2"
    local app_name
    app_name=$(basename "$source_path")
    local target_path="$destination_dir/$app_name"

    if [ ! -d "$source_path" ]; then
        print_info "$app_name not found at $source_path, skipping move."
        return
    fi

    if [ -d "$target_path" ]; then
        print_info "$app_name already located in $destination_dir."
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        print_dry_run "sudo mv \"$source_path\" \"$destination_dir/\""
    else
        execute_sudo mv "$source_path" "$destination_dir/"
    fi

    print_success "Moved $app_name to $destination_dir."
}

# Function: link_system_app_to_directory
# Description: Drop a symlink for SIP-protected apps so they show up in the
#              custom folder without relocating the source bundle.
function link_system_app_to_directory() {
    local source_path="$1"
    local destination_dir="$2"
    local app_name
    app_name=$(basename "$source_path")
    local link_path="$destination_dir/$app_name"

    if [ ! -d "$source_path" ]; then
        print_info "$app_name not found at $source_path, skipping link."
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        print_dry_run "sudo ln -sf \"$source_path\" \"$link_path\""
    else
        execute_sudo rm -rf "$link_path"
        execute_sudo ln -sf "$source_path" "$link_path"
    fi

    print_success "Linked $app_name into $destination_dir."
}

ensure_directory "$UTILITIES_DIR"
ensure_directory "$ENTERTAINMENT_DIR"

utilities_apps=(
    "/Applications/iTerm.app"
    "/Applications/iTerm2.app"
    "/Applications/PowerShell.app"
    "/Applications/Mark Text.app"
    "/Applications/Adobe Acrobat.app"
    "/Applications/Adobe Acrobat Reader.app"
    "/Applications/Adobe Acrobat Reader DC.app"
)

for app in "${utilities_apps[@]}"; do
    move_app_to_directory "$app" "$UTILITIES_DIR"
done

entertainment_system_apps=(
    "/System/Applications/QuickTime Player.app"
    "/System/Applications/Podcasts.app"
    "/System/Applications/TV.app"
)

for app in "${entertainment_system_apps[@]}"; do
    link_system_app_to_directory "$app" "$ENTERTAINMENT_DIR"
done

print_success "Application organization complete."
