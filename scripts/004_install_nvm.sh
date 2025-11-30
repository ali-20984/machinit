#!/bin/bash
#
# Script: 004_install_nvm.sh
# Description: Install Nvm
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

USER_GROUP=$(id -gn "$USER")

ensure_profile_ready() {
    local profile_path="$1"

    if [ ! -e "$profile_path" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "touch \"$profile_path\""
        else
            if ! touch "$profile_path" 2>/dev/null; then
                execute_sudo install -m 644 /dev/null "$profile_path"
                execute_sudo chown "$USER":"$USER_GROUP" "$profile_path"
            fi
        fi
    fi

    if [ -e "$profile_path" ] && [ ! -w "$profile_path" ]; then
        execute_sudo chown "$USER":"$USER_GROUP" "$profile_path"
        execute_sudo chmod u+rw "$profile_path"
    fi
}

echo "Installing nvm..."
install_brew_package nvm

NVM_DIR="$HOME/.nvm"
execute mkdir -p "$NVM_DIR"
if [ ! -w "$NVM_DIR" ]; then
    execute_sudo chown -R "$USER":"$USER_GROUP" "$NVM_DIR"
fi
execute chmod -R u+rwX "$NVM_DIR"

# Get nvm prefix
NVM_PREFIX=$(brew --prefix nvm)

# Add nvm configuration to shell profile (zshrc and bash_profile)
for profile in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc"; do
    ensure_profile_ready "$profile"
    if ! grep -q "nvm.sh" "$profile"; then
        echo "Adding nvm to $profile..."
        # shellcheck disable=SC2016
        {
            echo ""
            echo '# NVM configuration'
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo "[ -s \"$NVM_PREFIX/nvm.sh\" ] && \\. \"$NVM_PREFIX/nvm.sh\"  # This loads nvm"
            echo "[ -s \"$NVM_PREFIX/etc/bash_completion.d/nvm\" ] && \\. \"$NVM_PREFIX/etc/bash_completion.d/nvm\"  # This loads nvm bash_completion"
        } >>"$profile"
    else
        echo "nvm already configured in $profile"
    fi
done

echo "nvm installed and configured."
