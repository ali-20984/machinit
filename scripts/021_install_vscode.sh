#!/bin/bash
#
# Script: 021_install_vscode.sh
# Description: Install Vscode
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "Visual Studio Code"
install_brew_package visual-studio-code

print_config "VS Code"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
execute mkdir -p "$VSCODE_USER_DIR"
SETTINGS_FILE="$VSCODE_USER_DIR/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "create $SETTINGS_FILE with empty JSON"
    else
        echo "{}" >"$SETTINGS_FILE"
    fi
fi

# Use python to update json safely
if [ "$DRY_RUN" = true ]; then
    print_dry_run "update VS Code settings in $SETTINGS_FILE"
else
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

fi
