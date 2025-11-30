#!/bin/bash
#
# Script: 005_install_rust.sh
# Description: Install Rust
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing Rust via rustup..."

RUSTUP_DIR="$ORIGINAL_HOME/.rustup"
CARGO_DIR="$ORIGINAL_HOME/.cargo"
GROUP_NAME=$(id -gn "$ORIGINAL_USER")
export RUSTUP_HOME="$RUSTUP_DIR"
export CARGO_HOME="$CARGO_DIR"

# Function: ensure_dir_permissions
# Description: Make sure target directories exist and are writable by the
#              invoking user before rustup manipulates them.
function ensure_dir_permissions() {
    local dir="$1"
    if ! execute mkdir -p "$dir"; then
        print_info "Retrying mkdir for $dir with sudo..."
        execute_sudo mkdir -p "$dir"
    fi

    if [ "$DRY_RUN" = true ]; then
        return
    fi

    local ownership_issues=false
    if find "$dir" \( ! -user "$ORIGINAL_USER" -o ! -group "$GROUP_NAME" \) -print -quit | grep -q . 2>/dev/null; then
        ownership_issues=true
    fi

    if [ "$ownership_issues" = true ]; then
        print_info "Resetting ownership for $dir and its contents"
        execute_sudo chown -R "$ORIGINAL_USER":"$GROUP_NAME" "$dir"
    fi

    if ! chmod -R u+rwX "$dir" 2>/dev/null; then
        print_info "Retrying chmod for $dir with elevated privileges..."
        execute_sudo chmod -R u+rwX "$dir"
    fi
}

ensure_dir_permissions "$RUSTUP_DIR"
ensure_dir_permissions "$CARGO_DIR"

if command -v rustup &>/dev/null; then
    print_info "Rustup is already installed. Updating toolchains..."
    if ! execute rustup update; then
        print_error "rustup update failed. Ensure $RUSTUP_DIR is writable and rerun the script."
        exit 1
    fi
else
    print_info "Installing rustup..."
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
fi

if [ -f "$ORIGINAL_HOME/.cargo/env" ]; then
    # shellcheck disable=SC1090
    source "$ORIGINAL_HOME/.cargo/env"
fi

print_info "Ensuring stable toolchain is set as default..."
if ! execute rustup default stable; then
    print_error "Failed to set the stable toolchain as default. Run 'rustup default stable' manually after resolving any rustup errors."
    exit 1
fi

if command -v cargo &>/dev/null; then
    print_success "Rust installation complete."
    cargo_version=$(cargo --version)
    print_info "Cargo version: $cargo_version"
else
    print_error "Cargo not found after installation. Please check rustup output."
fi
