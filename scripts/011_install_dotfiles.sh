#!/bin/bash
echo "Installing dotfiles..."

# Get the absolute path to the assets directory
ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../assets" && pwd)"
FUNCTIONS_FILE="$ASSETS_DIR/.functions"
TARGET_FILE="$HOME/.functions"

if [ -f "$FUNCTIONS_FILE" ]; then
    echo "Installing .functions..."
    # Create a symbolic link
    ln -sf "$FUNCTIONS_FILE" "$TARGET_FILE"
    echo "Linked $FUNCTIONS_FILE to $TARGET_FILE"

    # Add source command to .zshrc if not present
    ZSHRC="$HOME/.zshrc"
    if [ ! -f "$ZSHRC" ]; then
        touch "$ZSHRC"
    fi

    if ! grep -q "source ~/.functions" "$ZSHRC"; then
        echo "" >> "$ZSHRC"
        echo "# Load custom functions" >> "$ZSHRC"
        echo "[ -f ~/.functions ] && source ~/.functions" >> "$ZSHRC"
        echo "Added source command to $ZSHRC"
    else
        echo ".functions already sourced in $ZSHRC"
    fi
else
    echo "Error: .functions file not found at $FUNCTIONS_FILE"
fi

echo "Dotfiles installation complete."
