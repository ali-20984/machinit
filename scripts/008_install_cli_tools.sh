#!/bin/bash
source "$(dirname "$0")/utils.sh"

echo "Installing comprehensive development tools..."

# General Utilities
echo "Installing Coreutils..."
install_brew_package coreutils

echo "Installing Moreutils..."
install_brew_package moreutils

echo "Installing Findutils..."
install_brew_package findutils

echo "Installing GNU Sed..."
install_brew_package gnu-sed "--with-default-names"

echo "Installing Bash and Completion..."
install_brew_package bash
install_brew_package bash-completion2

echo "Installing Tree..."
install_brew_package tree

echo "Installing p7zip..."
install_brew_package p7zip

echo "Installing Pigz (Parallel Gzip)..."
install_brew_package pigz

echo "Installing Zopfli..."
install_brew_package zopfli

echo "Installing Lua..."
install_brew_package lua

echo "Installing GitHub CLI..."
install_brew_package gh

echo "Installing Search Tools..."
install_brew_package psgrep
install_brew_package ripgrep
install_brew_package fd
install_brew_package fzf

echo "Installing Git Delta..."
install_brew_package git-delta

echo "Installing ShellCheck..."
install_brew_package shellcheck

echo "Installing Languages and Managers..."
install_brew_package node
install_brew_package pipx
install_brew_package rbenv
install_brew_package python
install_brew_package ruby
install_brew_package rustup
install_brew_package wget

# Network Tools
echo "Installing Network Tools..."
install_brew_package iproute2mac
install_brew_package bind
install_brew_package mtr
install_brew_package httpie
install_brew_package nmap

# Database Tools
echo "Installing Database Tools..."
install_brew_package pgcli

# System Monitoring
echo "Installing System Monitoring..."
install_brew_package glances

# JSON Tools
echo "Installing JSON Tools..."
install_brew_package jq

# Version Control
echo "Installing/Updating Git..."
install_brew_package git

# C++ Development Tools
echo "Installing C++ tools..."
install_brew_package cmake
install_brew_package ninja
install_brew_package llvm
install_brew_package gcc
install_brew_package pkg-config
install_brew_package autoconf
install_brew_package automake
install_brew_package libtool

# Python Development Tools
echo "Installing Python tools..."
install_brew_package pyenv
install_brew_package pyenv-virtualenv
install_brew_package poetry

# JavaScript/Node Development Tools
echo "Installing JavaScript/Node tools..."
install_brew_package npm
install_brew_package yarn
install_brew_package pnpm

echo "Installing @github/copilot globally..."
if command -v npm &> /dev/null; then
    npm install -g @github/copilot
else
    echo "npm not found. Skipping @github/copilot installation."
fi

echo "Cleaning up Brew..."
brew cleanup

echo "Development tools installation complete."
