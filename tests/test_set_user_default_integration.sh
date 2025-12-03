#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(dirname "$0")/.."
UTILS="$PROJECT_ROOT/scripts/utils.sh"
DOMAIN="com.example.machinit_integration_test"

echo "Running integration tests for set_user_default (will write to current user defaults)"
export ORIGINAL_USER="$USER"
# shellcheck disable=SC2034
export ORIGINAL_HOME=$(eval echo "~$ORIGINAL_USER")
export CONFIG_FILE="$PROJECT_ROOT/config.toml"
export DRY_RUN=false
# shellcheck disable=SC1090
source "$UTILS"

# Clean up at exit
# shellcheck disable=SC2329
cleanup() {
    # shellcheck disable=SC2317
    defaults delete "$DOMAIN" 2>/dev/null || true
}
trap cleanup EXIT

# Test string write
set_user_default "$DOMAIN" KeyString string "hello"
read_val=$(defaults read "$DOMAIN" KeyString)
if [ "$read_val" = "hello" ]; then
    echo "PASS: string write/read"
else
    echo "FAIL: string write/read (got: $read_val)"
    exit 1
fi

# Test int write
set_user_default "$DOMAIN" KeyInt int 42
read_int=$(defaults read "$DOMAIN" KeyInt)
if [ "$read_int" = 42 ]; then
    echo "PASS: int write/read"
else
    echo "FAIL: int write/read (got: $read_int)"
    exit 1
fi

# Test bool write
set_user_default "$DOMAIN" KeyBool bool true
read_bool=$(defaults read "$DOMAIN" KeyBool)
if [ "$read_bool" = 1 ]; then
    echo "PASS: bool write/read"
else
    echo "FAIL: bool write/read (got: $read_bool)"
    exit 1
fi

# Test array write
set_user_default "$DOMAIN" KeyArray array "one" "two" "three"
# defaults read returns a plist; using `defaults read` we should see strings on separate lines
arr=$(defaults read "$DOMAIN" KeyArray 2>/dev/null || true)
if echo "$arr" | grep -q "one" && echo "$arr" | grep -q "three"; then
    echo "PASS: array write/read"
else
    echo "FAIL: array write/read (got: $arr)"
    exit 1
fi

# Test delete
set_user_default "$DOMAIN" KeyToDelete string "bye"
set_user_default "$DOMAIN" KeyToDelete delete
if defaults read "$DOMAIN" KeyToDelete >/dev/null 2>&1; then
    echo "FAIL: delete did not remove key"
    exit 1
else
    echo "PASS: delete removed key"
fi

# Cleanup done by trap
exit 0
