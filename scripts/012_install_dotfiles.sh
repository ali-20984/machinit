#!/bin/bash
#
# Script: 012_install_dotfiles.sh
# Description: Install Dotfiles (moved to 012 to run after 011 checks)
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

# Allow restricted mode: only install aliases and functions then quit
ONLY_SHELL=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --only-shell)
            ONLY_SHELL=true
            shift
            ;;
        *)
            # Ignore unknown flags to keep behavior stable when called from install.sh
            shift
            ;;
    esac
done

print_header "Dotfiles"

# Get the absolute path to the assets directory
ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../assets" && pwd)"

# Run an alias/function conflict check before touching user dotfiles unless SKIP_ALIAS_CHECK=1
CONFLICT_CHECK_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/011_check_aliases_functions_conflicts.sh"
if [ -z "${SKIP_ALIAS_CHECK:-}" ] && [ -f "$CONFLICT_CHECK_SCRIPT" ]; then
    print_info "Checking for alias/function name conflicts before installing dotfiles..."
    if ! bash "$CONFLICT_CHECK_SCRIPT" "$ASSETS_DIR"; then
        print_error "Conflicts detected. Aborting dotfiles installation. Set SKIP_ALIAS_CHECK=1 to bypass this check if you are sure."
        exit 1
    fi
fi

# Function: backup_file
# Description: Preserve a non-symlink target by renaming it with a timestamp
#              before we replace it with the managed dotfile symlink.
function backup_file() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        local backup="${file}.bak.$(date +%s)"
        if execute mv "$file" "$backup" 2>/dev/null; then
            print_info "Backed up existing $file to $backup"
        else
            print_info "Retrying backup of $file with sudo..."
            if execute_sudo mv "$file" "$backup"; then
                print_info "Backed up existing $file to $backup"
            else
                print_error "Failed to back up $file. Skipping replacement."
                return 1
            fi
        fi
    fi
}

FUNCTIONS_FILE="$ASSETS_DIR/.functions"
TARGET_FILE="$HOME/.functions"

if [ -f "$FUNCTIONS_FILE" ]; then
    print_install ".functions"
    backup_file "$TARGET_FILE"
    if execute ln -sf "$FUNCTIONS_FILE" "$TARGET_FILE"; then
        print_success "Linked $FUNCTIONS_FILE to $TARGET_FILE"
    fi

    # Add source command to .zshrc if not present
    ZSHRC="$HOME/.zshrc"
    if [ ! -f "$ZSHRC" ]; then
        touch "$ZSHRC"
    fi

    if ! grep -q "source ~/.functions" "$ZSHRC"; then
        {
            echo ""
            echo "# Load custom functions"
            echo "[ -f ~/.functions ] && source ~/.functions"
        } >>"$ZSHRC"
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
    print_install ".aliases"
    backup_file "$TARGET_ALIASES"
    if execute ln -sf "$ALIASES_FILE" "$TARGET_ALIASES"; then
        print_success "Linked $ALIASES_FILE to $TARGET_ALIASES"
    fi

    if ! grep -q "source ~/.aliases" "$ZSHRC"; then
        echo "[ -f ~/.aliases ] && source ~/.aliases" >>"$ZSHRC"
        print_success "Added source command for .aliases to $ZSHRC"
    else
        print_info ".aliases already sourced in $ZSHRC"
    fi
else
    print_error "Error: .aliases file not found at $ALIASES_FILE"
fi

if [ "$ONLY_SHELL" = true ]; then
    print_info "--only-shell specified: finished updating aliases and functions."
    exit 0
fi

# Install .gitignore_global
GITIGNORE_FILE="$ASSETS_DIR/.gitignore_global"
TARGET_GITIGNORE="$HOME/.gitignore_global"
if [ -f "$GITIGNORE_FILE" ]; then
    print_install ".gitignore_global"
    backup_file "$TARGET_GITIGNORE"
    if execute ln -sf "$GITIGNORE_FILE" "$TARGET_GITIGNORE"; then
        print_success "Linked $GITIGNORE_FILE to $TARGET_GITIGNORE"
    fi

    print_config "Git global ignore"
    git config --global core.excludesfile "$TARGET_GITIGNORE"
    print_success "Git configured to use $TARGET_GITIGNORE"
else
    print_error "Error: .gitignore_global file not found at $GITIGNORE_FILE"
fi

# Install .nanorc
NANORC_FILE="$ASSETS_DIR/.nanorc"
TARGET_NANORC="$HOME/.nanorc"
if [ -f "$NANORC_FILE" ]; then
    print_install ".nanorc"
    backup_file "$TARGET_NANORC"
    if execute ln -sf "$NANORC_FILE" "$TARGET_NANORC"; then
        print_success "Linked $NANORC_FILE to $TARGET_NANORC"
    fi

    # Create nano backup directory
    if [ ! -d "$HOME/.nano-backups" ]; then
        execute mkdir -p "$HOME/.nano-backups"
        print_success "Created nano backup directory at $HOME/.nano-backups"
    fi
else
    print_error "Error: .nanorc file not found at $NANORC_FILE"
fi

echo "Dotfiles installation complete."
