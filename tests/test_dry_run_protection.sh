#!/usr/bin/env bash
set -euo pipefail

# This test scans the scripts/ directory for common state-changing
# commands and ensures they are guarded by a DRY-RUN-safe wrapper
# (execute, execute_sudo, execute_as_user, set_default, set_user_default)

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

patterns=(
  "defaults write"
  "\brm -rf\b"
  "\brm -f\b"
  "\bcp \b"
  "\bmv \b"
  "\bln -s\b"
  "\bmkdir -p\b"
  "\bkillall\b"
  "\breboot\b"
  "\bshutdown\b"
  "\bsystemsetup\b"
  "\bpmset\b"
  "\bnvram\b"
)

fail=0

for pat in "${patterns[@]}"; do
  # Search within scripts/ for matching pattern, exclude utils.sh and docs
  while IFS= read -r match; do
    # match format: path:line_number:content
    file=$(echo "$match" | cut -d: -f1)
    line_num=$(echo "$match" | cut -d: -f2)
    content=$(echo "$match" | cut -d: -f3-)

    # Ignore helpers file (helpers implement the actual wrappers)
    if [[ "$file" =~ scripts/utils.sh ]]; then
      continue
    fi

    # Skip commented lines
    if [[ "$content" =~ ^[[:space:]]*# ]]; then
      continue
    fi

    # Allow the use of helpers/wrappers on the same line.
    # Accept both `execute` and the specialized wrappers.
    if echo "$content" | grep -E "(\bexecute\b|execute_|execute_sudo|execute_as_user|print_dry_run|set_default|set_user_default)" >/dev/null; then
      continue
    fi

    # If the line is an explicit DRY RUN echo (e.g. echo "[DRY RUN] ...") ignore it
    if echo "$content" | grep -q "\[DRY RUN\]"; then
      continue
    fi

    printf "UNGUARDED PATTERN: %s:%s -> %s\n" "$file" "$line_num" "$content"
    fail=1
  done < <(grep -nR --exclude-dir=.git -- "${pat}" scripts || true)
done

if [ $fail -eq 1 ]; then
  echo "One or more unguarded destructive commands were found in scripts/."
  echo "Make sure these are wrapped with execute/execute_sudo/execute_as_user or print_dry_run and re-run tests."
  exit 1
fi

echo "No unguarded destructive commands detected in scripts/."
