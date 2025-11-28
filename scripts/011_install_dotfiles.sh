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

# Install .aliases
ALIASES_FILE="$ASSETS_DIR/.aliases"
TARGET_ALIASES="$HOME/.aliases"

if [ -f "$ALIASES_FILE" ]; then
    echo "Installing .aliases..."
    ln -sf "$ALIASES_FILE" "$TARGET_ALIASES"
    print_success "Linked $ALIASES_FILE to $TARGET_ALIASES"

    if ! grep -q "source ~/.aliases" "$ZSHRC"; then
        echo "[ -f ~/.aliases ] && source ~/.aliases" >> "$ZSHRC"
        print_success "Added source command for .aliases to $ZSHRC"
    else
        print_info ".aliases already sourced in $ZSHRC"
    fi
else
    print_error "Error: .aliases file not found at $ALIASES_FILE"
fi

# Install .gitignore_global
GITIGNORE_FILE="$ASSETS_DIR/.gitignore_global"
TARGET_GITIGNORE="$HOME/.gitignore_global"

if [ -f "$GITIGNORE_FILE" ]; then
    echo "Installing .gitignore_global..."
    ln -sf "$GITIGNORE_FILE" "$TARGET_GITIGNORE"
    print_success "Linked $GITIGNORE_FILE to $TARGET_GITIGNORE"
    
    echo "Configuring git to use global ignore file..."
    git config --global core.excludesfile "$TARGET_GITIGNORE"
    print_success "Git configured to use $TARGET_GITIGNORE"
else
    print_error "Error: .gitignore_global file not found at $GITIGNORE_FILE"
fi

# Install .nanorc
NANORC_FILE="$ASSETS_DIR/.nanorc"
TARGET_NANORC="$HOME/.nanorc"

if [ -f "$NANORC_FILE" ]; then
    echo "Installing .nanorc..."
    ln -sf "$NANORC_FILE" "$TARGET_NANORC"
    print_success "Linked $NANORC_FILE to $TARGET_NANORC"
    
    # Create nano backup directory
    if [ ! -d "$HOME/.nano-backups" ]; then
        mkdir -p "$HOME/.nano-backups"
        print_success "Created nano backup directory at $HOME/.nano-backups"
    fi
else
    print_error "Error: .nanorc file not found at $NANORC_FILE"
fi

echo "Dotfiles installation complete."
