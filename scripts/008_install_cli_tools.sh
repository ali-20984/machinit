#!/bin/bash
#
# Script: 008_install_cli_tools.sh
# Description: Install Cli Tools
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_header "Development Tools"

# General Utilities
print_install "Coreutils"
install_brew_package coreutils

print_install "Moreutils"
install_brew_package moreutils

print_install "Findutils"
install_brew_package findutils

print_install "GNU Sed"
install_brew_package gnu-sed
if command -v brew &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "brew link gnu-sed --overwrite --force"
    else
        if brew list gnu-sed &>/dev/null; then
            if brew link gnu-sed --overwrite --force; then
                print_success "gnu-sed linked with default names."
            else
                print_error "Failed to force-link gnu-sed."
            fi
        fi
    fi
fi

print_install "Bash and Completion"
install_brew_package bash
install_brew_package bash-completion2

print_install "Tree"
install_brew_package tree

print_install "p7zip"
install_brew_package p7zip

print_install "Pigz (Parallel Gzip)"
install_brew_package pigz

print_install "Zopfli"
install_brew_package zopfli

print_install "Lua"
install_brew_package lua

print_install "GitHub CLI"
install_brew_package gh

print_install "Search Tools"
install_brew_package psgrep
install_brew_package ripgrep
install_brew_package fd
install_brew_package fzf

print_install "Git Delta"
install_brew_package git-delta

print_install "ShellCheck"
install_brew_package shellcheck

print_install "Languages and Managers"
install_brew_package node
install_brew_package pipx
install_brew_package rbenv
install_brew_package python
install_brew_package ruby
install_brew_package rustup
install_brew_package wget

# Network Tools
print_install "Network Tools"
install_brew_package iproute2mac
install_brew_package bind
install_brew_package mtr
install_brew_package httpie
install_brew_package nmap

# Database Tools
print_install "Database Tools"
install_brew_package pgcli

# System Monitoring
print_install "System Monitoring"
install_brew_package glances

# JSON Tools
print_install "JSON Tools"
install_brew_package jq

# Version Control
print_install "Git"
install_brew_package git

# C++ Development Tools
print_install "C++ Development Tools"
install_brew_package cmake
install_brew_package ninja
install_brew_package llvm
install_brew_package gcc
install_brew_package pkg-config
install_brew_package autoconf
install_brew_package automake
install_brew_package libtool

# Python Development Tools
print_install "Python Development Tools"
install_brew_package pyenv
install_brew_package pyenv-virtualenv
install_brew_package poetry

# JavaScript/Node Development Tools
print_install "JavaScript/Node Tools"
install_brew_package npm
install_brew_package yarn
install_brew_package pnpm

print_install "@github/copilot"
if command -v npm &>/dev/null; then
    npm install -g @github/copilot
else
    print_skip "npm not found, skipping @github/copilot"
fi

print_info "Cleaning up Brew..."
execute brew cleanup

echo "Development tools installation complete."
