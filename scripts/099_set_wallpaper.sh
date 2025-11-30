#!/bin/bash
#
# Script: 099_set_wallpaper.sh
# Description: Set Wallpaper
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

# Get absolute path to the assets directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_ROOT/assets"

print_info "Looking for wallpaper in $ASSETS_DIR..."

# Find the first file matching wallpaper.* (jpg, png, etc.)
WALLPAPER_FILE=$(find "$ASSETS_DIR" -maxdepth 1 -name "wallpaper.*" -print -quit)

if [ -z "$WALLPAPER_FILE" ]; then
    print_info "No wallpaper.* file found in assets directory. Skipping."
    exit 0
fi

print_info "Found wallpaper: $WALLPAPER_FILE"

# Create destination directory
DEST_DIR="$HOME/Documents/Wallpapers"
execute mkdir -p "$DEST_DIR"

# Copy wallpaper
FILENAME=$(basename "$WALLPAPER_FILE")
DEST_FILE="$DEST_DIR/$FILENAME"
print_info "Copying wallpaper to $DEST_FILE..."
execute cp "$WALLPAPER_FILE" "$DEST_FILE"

# Symlink Wallpapers folder to Pictures
if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
    print_info "Symlinking Wallpapers to ~/Pictures/Wallpapers..."
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "ln -s $DEST_DIR $HOME/Pictures/Wallpapers"
    else
        ln -s "$DEST_DIR" "$HOME/Pictures/Wallpapers"
    fi
fi

print_info "Setting desktop wallpaper..."

if [ "$DRY_RUN" = true ]; then
    print_dry_run "/usr/bin/swift <set_wallpaper.swift> $DEST_FILE"
    print_success "Wallpaper set successfully."
    exit 0
fi

SWIFT_SCRIPT=$(mktemp /tmp/set_wallpaper.XXXXXX.swift)
cat <<'EOF' >"$SWIFT_SCRIPT"
import Cocoa

let args = CommandLine.arguments
guard args.count > 1 else {
    print("Usage: set_wallpaper <image_path>")
    exit(1)
}

let imagePath = args[1]
let imageUrl = URL(fileURLWithPath: imagePath)
let workspace = NSWorkspace.shared

let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
    .imageScaling: NSImageScaling.scaleNone.rawValue,
    .allowClipping: false,
    .fillColor: NSColor.black
]

for screen in NSScreen.screens {
    do {
        try workspace.setDesktopImageURL(imageUrl, for: screen, options: options)
        print("Set wallpaper for screen: \(screen.localizedName)")
    } catch {
        print("Failed to set wallpaper for screen: \(screen.localizedName). Error: \(error)")
        exit(1)
    }
}
EOF

/usr/bin/swift "$SWIFT_SCRIPT" "$DEST_FILE"
SWIFT_EXIT_CODE=$?
rm "$SWIFT_SCRIPT"

if [ $SWIFT_EXIT_CODE -eq 0 ]; then
    print_success "Wallpaper set successfully."
else
    print_error "Error setting wallpaper."
    exit 1
fi
