#!/bin/bash
source "$(dirname "$0")/utils.sh"

echo "Installing Visual Studio Code..."
install_brew_package visual-studio-code

echo "Configuring VS Code..."
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER_DIR"
SETTINGS_FILE="$VSCODE_USER_DIR/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
fi

# Use python to update json safely
python3 - <<EOF
import json
import os

file_path = os.path.expanduser('$SETTINGS_FILE')
try:
    with open(file_path, 'r') as f:
        data = json.load(f)
except json.JSONDecodeError:
    data = {}

# Disable welcome page
data['workbench.startupEditor'] = 'none'

with open(file_path, 'w') as f:
    json.dump(data, f, indent=4)
EOF

echo "VS Code configured."
