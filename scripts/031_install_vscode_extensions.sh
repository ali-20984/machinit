#!/bin/bash
echo "Installing VS Code extensions..."

# Ensure 'code' command is available
if ! command -v code &> /dev/null; then
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    else
        echo "Visual Studio Code not found. Skipping extension installation."
        exit 1
    fi
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

# Get list of installed extensions
installed_extensions=$(code --list-extensions)

for ext in "${extensions[@]}"; do
    if echo "$installed_extensions" | grep -qi "^$ext$"; then
        echo "Extension $ext is already installed. Skipping."
    else
        echo "Installing $ext..."
        code --install-extension "$ext" --force
    fi
done

echo "Configuring VS Code Settings (Dark Mode)..."
SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"
mkdir -p "$(dirname "$SETTINGS_FILE")"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
fi

# Use Python to update settings.json safely
python3 -c "
import json
import os

settings_path = os.path.expanduser('$SETTINGS_FILE')
try:
    with open(settings_path, 'r') as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}

data['workbench.colorTheme'] = 'OLED Pure Black'

with open(settings_path, 'w') as f:
    json.dump(data, f, indent=4)
"

echo "VS Code extensions installation and configuration complete."
