#!/bin/bash
#
# Script: 031_install_vscode_extensions.sh
# Description: Install Vscode Extensions
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_info "Installing VS Code extensions..."

if ! command -v code &>/dev/null; then
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    fi
fi

if ! command -v code &>/dev/null; then
    print_info "Visual Studio Code command line not found. Skipping extensions."
    exit 0
fi

extensions=(
    "openai.chatgpt"
    "dbaeumer.vscode-eslint"
    "github.vscode-github-actions"
    "github.copilot-chat"
    "davidanson.vscode-markdownlint"
    "christian-kohler.npm-intellisense"
    "timonwong.shellcheck"
    "rooveterinaryinc.roo-cline"
    "chadbaileyvh.oled-pure-black---vscode"
    "streetsidesoftware.code-spell-checker"
)

if [ "$DRY_RUN" = true ]; then
    installed_extensions=""
else
    installed_extensions=$(code --list-extensions 2>/dev/null)
fi

for ext in "${extensions[@]}"; do
    if printf '%s\n' "$installed_extensions" | grep -Fixq "$ext"; then
        print_info "Extension $ext is already installed."
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "code --install-extension $ext --force"
        else
            execute code --install-extension "$ext" --force
        fi
    fi
done

print_info "Configuring VS Code settings..."
SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"
execute mkdir -p "$(dirname "$SETTINGS_FILE")"

if [ ! -f "$SETTINGS_FILE" ]; then
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Create $SETTINGS_FILE with {}"
    else
        echo "{}" >"$SETTINGS_FILE"
    fi
fi

if [ "$DRY_RUN" = true ]; then
    print_dry_run "Update $SETTINGS_FILE key workbench.colorTheme"
else
    python3 -c "
import json
import os

settings_path = os.path.expanduser('$SETTINGS_FILE')
try:
    with open(settings_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}

data['workbench.colorTheme'] = 'OLED Pure Black'

with open(settings_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)
"
fi

print_success "VS Code extensions installation and configuration complete."
