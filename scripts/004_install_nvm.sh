#!/bin/bash
#
# Script: 004_install_nvm.sh
# Description: Install Nvm
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

USER_GROUP=$(id -gn "$ORIGINAL_USER")

ensure_profile_ready() {
    local profile_path="$1"

    if [ ! -e "$profile_path" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "touch \"$profile_path\""
        else
            if ! touch "$profile_path" 2>/dev/null; then
                execute_sudo install -m 644 /dev/null "$profile_path"
                execute_sudo chown "$ORIGINAL_USER":"$USER_GROUP" "$profile_path"
            fi
        fi
    fi

    if [ -e "$profile_path" ] && [ ! -w "$profile_path" ]; then
        execute_sudo chown "$ORIGINAL_USER":"$USER_GROUP" "$profile_path"
        execute_sudo chmod u+rw "$profile_path"
    fi
}

print_install "nvm (Node Version Manager)"
install_brew_package nvm

NVM_DIR="$ORIGINAL_HOME/.nvm"
execute mkdir -p "$NVM_DIR"
if [ ! -w "$NVM_DIR" ]; then
    execute_sudo chown -R "$ORIGINAL_USER":"$USER_GROUP" "$NVM_DIR"
fi
execute chmod -R u+rwX "$NVM_DIR"

# Get nvm prefix (guard brew call in dry-run to avoid touching brew/db or creating caches)
if [ "$DRY_RUN" = true ]; then
    print_dry_run "Determine Brew prefix for nvm (skipped in dry-run)"
    # safe placeholder so we can print sensible DRY_RUN messages later
    NVM_PREFIX="$ORIGINAL_HOME/.nvm"
else
    NVM_PREFIX=$(brew --prefix nvm 2>/dev/null || echo "$ORIGINAL_HOME/.nvm")
fi

# Add nvm configuration to shell profile (zshrc and bash_profile)
for profile in "$ORIGINAL_HOME/.zshrc" "$ORIGINAL_HOME/.bash_profile" "$ORIGINAL_HOME/.bashrc"; do
    ensure_profile_ready "$profile"
    if ! grep -q "nvm.sh" "$profile"; then
        echo "Adding nvm to $profile..."
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "Append nvm configuration to $profile"
        else
            # shellcheck disable=SC2016
            {
                echo ""
                echo '# NVM configuration'
                echo 'export NVM_DIR="$HOME/.nvm"'
                echo "[ -s \"$NVM_PREFIX/nvm.sh\" ] && \\\. \"$NVM_PREFIX/nvm.sh\"  # This loads nvm"
                echo "[ -s \"$NVM_PREFIX/etc/bash_completion.d/nvm\" ] && \\\. \"$NVM_PREFIX/etc/bash_completion.d/nvm\"  # This loads nvm bash_completion"
            } >>"$profile"
        fi
    else
        echo "nvm already configured in $profile"
    fi
done

echo "nvm installed and configured."
