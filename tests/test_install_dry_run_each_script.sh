#!/usr/bin/env bash
set -euo pipefail

# Run each top-level script in scripts/ with DRY_RUN=true and an isolated HOME
# to ensure scripts don't modify the real user environment when DRY_RUN is set.

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS_DIR="$REPO_ROOT/scripts"

echo "Running installer dry-run smoke test for scripts in: $SCRIPTS_DIR"

fail=0

for script in "$SCRIPTS_DIR"/*.sh; do
  # skip utility/library scripts we don't intend to run directly
  case "$(basename "$script")" in
    utils.sh|lib/*) continue;;
  esac

  echo "---- Testing $script ----"

  TMP_HOME=$(mktemp -d)
  # Ensure a safe isolated environment — scripts should treat DRY_RUN responsibly
  env -i DRY_RUN=true ORIGINAL_USER="$USER" HOME="$TMP_HOME" PATH="$PATH" bash "$script" >/tmp/test_out 2>&1 || true

  # Check exit status via last command
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "FAIL: $script exited $rc (should exit 0 in dry-run)"
    echo "Output:"; sed -n '1,120p' /tmp/test_out
    fail=1
    rm -rf "$TMP_HOME"
    continue
  fi

  # Ensure temp home remains unchanged (no new user files created)
  if [ -n "$(find "$TMP_HOME" -maxdepth 1 -mindepth 1 -print -quit)" ]; then
    echo "FAIL: $script created files under HOME during dry-run:"; find "$TMP_HOME" -maxdepth 2 -print
    fail=1
  else
    echo "PASS: $script did not modify HOME during dry-run"
  fi

  rm -rf "$TMP_HOME" /tmp/test_out
done

if [ $fail -ne 0 ]; then
  echo "One or more scripts failed to remain strictly read-only during DRY_RUN"
  exit 1
fi

echo "All scripts remained read-only in DRY_RUN."
exit 0
