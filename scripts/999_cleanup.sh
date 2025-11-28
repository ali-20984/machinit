#!/bin/bash
#
# Script: 999_cleanup.sh
# Description: Cleanup
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

function global_cleanup() {
    print_info "Starting global cleanup..."

    # Homebrew Cleanup
    if command -v brew &> /dev/null; then
        print_info "Cleaning up Homebrew..."
        execute brew cleanup -s
        
        local brew_cache
        brew_cache=$(brew --cache)
        execute rm -rf "$brew_cache"
        
        print_success "Homebrew cleaned."
    fi

    # NPM Cleanup
    if command -v npm &> /dev/null; then
        print_info "Cleaning up npm cache..."
        execute npm cache clean --force
        print_success "npm cache cleaned."
    fi

    # Gem Cleanup
    if command -v gem &> /dev/null; then
        print_info "Cleaning up Ruby gems..."
        execute gem cleanup
        print_success "Ruby gems cleaned."
    fi

    # Pip Cleanup (if pip is available)
    if command -v pip3 &> /dev/null; then
        print_info "Cleaning up pip cache..."
        execute pip3 cache purge
        print_success "pip cache cleaned."
    fi

    # System Caches (User level)
    print_info "Cleaning up user caches..."
    # Be careful not to delete everything, just common temporary caches
    execute rm -rf ~/Library/Caches/Homebrew
    execute rm -rf ~/Library/Caches/pip
    execute rm -rf ~/.npm/_cacache

    # Clear DNS Cache
    print_info "Flushing DNS cache..."
    execute_sudo dscacheutil -flushcache
    execute_sudo killall -HUP mDNSResponder

    # Clear inactive memory (optional, requires sudo)
    print_info "Purging inactive memory..."
    execute_sudo purge

    print_success "Global cleanup complete."
}

global_cleanup
