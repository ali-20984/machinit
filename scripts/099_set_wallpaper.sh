#!/bin/bash

# Get absolute path to the assets directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_ROOT/assets"

echo "Looking for wallpaper in $ASSETS_DIR..."

# Find the first file matching wallpaper.* (jpg, png, etc.)
WALLPAPER_FILE=$(find "$ASSETS_DIR" -maxdepth 1 -name "wallpaper.*" -print -quit)

if [ -z "$WALLPAPER_FILE" ]; then
    echo "Warning: No file named 'wallpaper.*' found in assets directory. Skipping wallpaper setup."
    exit 0
fi

echo "Found wallpaper: $WALLPAPER_FILE"

# Create destination directory
DEST_DIR="$HOME/Documents/Wallpapers"
mkdir -p "$DEST_DIR"

# Copy wallpaper
FILENAME=$(basename "$WALLPAPER_FILE")
DEST_FILE="$DEST_DIR/$FILENAME"
echo "Copying wallpaper to $DEST_FILE..."
cp "$WALLPAPER_FILE" "$DEST_FILE"

# Symlink Wallpapers folder to Pictures
if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
    echo "Symlinking Wallpapers to ~/Pictures/Wallpapers..."
    ln -s "$DEST_DIR" "$HOME/Pictures/Wallpapers"
fi

echo "Setting desktop wallpaper..."

# Create a temporary Swift script to set wallpaper with options (Centered, Black background)
SWIFT_SCRIPT=$(mktemp /tmp/set_wallpaper.XXXXXX.swift)

cat <<EOF > "$SWIFT_SCRIPT"
import Cocoa

let args = CommandLine.arguments
guard args.count > 1 else {
    print("Usage: set_wallpaper <image_path>")
    exit(1)
}

let imagePath = args[1]
let imageUrl = URL(fileURLWithPath: imagePath)
let workspace = NSWorkspace.shared

// Options: Center (scaleNone) and Black Background
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

# Run the Swift script
/usr/bin/swift "$SWIFT_SCRIPT" "$DEST_FILE"
SWIFT_EXIT_CODE=$?

rm "$SWIFT_SCRIPT"

if [ $SWIFT_EXIT_CODE -eq 0 ]; then
    echo "Wallpaper set successfully."
else
    echo "Error setting wallpaper."
    exit 1
fi
