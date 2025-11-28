#!/bin/bash
source "$(dirname "$0")/utils.sh"

echo "Installing dotfiles..."

# Get the absolute path to the assets directory
ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../assets" && pwd)"
FUNCTIONS_FILE="$ASSETS_DIR/.functions"
TARGET_FILE="$HOME/.functions"

if [ -f "$FUNCTIONS_FILE" ]; then
    echo "Installing .functions..."
    # Create a symbolic link
    ln -sf "$FUNCTIONS_FILE" "$TARGET_FILE"
    print_success "Linked $FUNCTIONS_FILE to $TARGET_FILE"

    # Add source command to .zshrc if not present
    ZSHRC="$HOME/.zshrc"
    if [ ! -f "$ZSHRC" ]; then
        touch "$ZSHRC"
    fi

    if ! grep -q "source ~/.functions" "$ZSHRC"; then
        echo "" >> "$ZSHRC"
        echo "# Load custom functions" >> "$ZSHRC"
        echo "[ -f ~/.functions ] && source ~/.functions" >> "$ZSHRC"
        print_success "Added source command to $ZSHRC"
    else
        print_info ".functions already sourced in $ZSHRC"
    fi
    
    # Check for dependencies used in .functions
    echo "Checking dependencies for .functions..."
    check_command "python3"
    check_command "git"
    check_command "tree"
    check_command "pigz" || print_info "pigz is optional but recommended for 'targz'"
    check_command "zopfli" || print_info "zopfli is optional but recommended for 'targz'"
    
else
    print_error "Error: .functions file not found at $FUNCTIONS_FILE"
fi

echo "Dotfiles installation complete."
