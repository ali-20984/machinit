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

for ext in "${extensions[@]}"; do
    echo "Installing $ext..."
    code --install-extension "$ext" --force
done

echo "VS Code extensions installation complete."
