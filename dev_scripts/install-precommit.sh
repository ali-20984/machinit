#!/usr/bin/env bash
set -euo pipefail

echo "Installing pre-commit and enabling git hooks..."

if ! command -v python3 &>/dev/null; then
    echo "python3 is required. Please install Python 3." >&2
    exit 1
fi

# Respect dry-run mode exported from install.sh
if [ "${DRY_RUN:-false}" = true ]; then
    printf "%s\n" "[DRY RUN] Would install pre-commit (skipped)." >&2
    exit 0
fi

# Try preferred installers in order: pipx, brew, then pip --user.
install_precommit_with_pipx() {
    if command -v pipx &>/dev/null; then
        echo "Installing pre-commit via pipx..."
        pipx install pre-commit && return 0 || return 1
    fi
    return 1
}

install_precommit_with_brew() {
    if command -v brew &>/dev/null; then
        echo "Installing pre-commit via Homebrew..."
        brew install pre-commit && return 0 || return 1
    fi
    return 1
}

install_precommit_with_pip_user() {
    echo "Installing pre-commit via pip (user)..."
    # Capture stderr to inspect for PEP 668 messages
    err=$(python3 -m pip install --user --upgrade pre-commit 2>&1 >/dev/null) || rc=$?
    if [ -n "${rc:-}" ] && [ "${rc}" -ne 0 ]; then
        printf "%s\n" "$err" >&2
        return 1
    fi
    return 0
}

echo "Attempting to install pre-commit..."

if install_precommit_with_pipx; then
    echo "pre-commit installed via pipx."
elif install_precommit_with_brew; then
    echo "pre-commit installed via Homebrew."
elif install_precommit_with_pip_user; then
    echo "pre-commit installed via pip --user."
else
    # If pip failed due to PEP 668, try to detect that and recommend alternatives
    if python3 -m pip install --user --upgrade pre-commit 2>&1 | grep -q "externally-managed-environment"; then
        echo "Detected an externally-managed Python environment (PEP 668)." >&2
        if command -v pipx &>/dev/null; then
            echo "Falling back to 'pipx install pre-commit'..."
            pipx install pre-commit || true
        elif command -v brew &>/dev/null; then
            echo "Falling back to 'brew install pre-commit'..."
            brew install pre-commit || true
        else
            echo "Cannot install pre-commit automatically in this environment." >&2
            echo "Please install pre-commit using one of the following options:" >&2
            echo "  - Install pipx and run: pipx install pre-commit" >&2
            echo "  - Install pre-commit via Homebrew: brew install pre-commit" >&2
            echo "  - Create a venv and pip install pre-commit inside it:" >&2
            exit 1
        fi
    else
        echo "Failed to install pre-commit by any supported method." >&2
        echo "Please install pre-commit manually (pipx, brew, or venv + pip)." >&2
        exit 1
    fi
fi

echo "Running pre-commit install..."
if command -v pre-commit &>/dev/null; then
    pre-commit install
    echo "pre-commit installed. You can run 'pre-commit run --all-files' to format existing files."
else
    echo "pre-commit not found on PATH after installation. You may need to add ~/.local/bin to your PATH." >&2
    exit 1
fi
