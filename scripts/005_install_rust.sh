#!/bin/bash
echo "Installing Rust via rustup..."

if command -v rustup &> /dev/null; then
    echo "Rustup is already installed. Updating..."
    rustup update
else
    echo "Installing Rustup..."
    # Install rustup with -y to disable confirmation prompts (hands-off)
    # User requested sudo injection
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh -s -- -y
    
    # Source the environment to make it available immediately
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
fi

echo "Rust installation complete."
echo "Cargo version: $(cargo --version)"
