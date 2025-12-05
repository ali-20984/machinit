#!/usr/bin/env bash
set -u

# CLI flags
abort_on_conflict=false
# check_only is intentionally available as a flag for callers — when used the
# script will write the report and exit immediately (check-only mode).
check_only=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --abort-on-conflict)
            abort_on_conflict=true
            shift
            ;;
        --check-only | --check-and-exit)
            check_only=true
            shift
            ;;
        --help | -h)
            echo "Usage: $0 [--abort-on-conflict] [--check-only] [assets_dir]"
            echo "  --abort-on-conflict   Exit non-zero when conflicts are found (installer should use this)."
            echo "  --check-only          Run checks, write report, and exit (default behavior is warning-only)."
            exit 0
            ;;
        *)
            # treat as assets_dir override
            ASSETS_DIR="$1"
            shift
            ;;
    esac
done

# 011_check_aliases_functions_conflicts.sh
# Scan assets/.aliases and assets/.functions (plus scripts/*.sh) and detect:
#  - duplicate names in repo
#  - alias vs function name collisions
#  - names that would shadow existing commands / builtins / functions / aliases
# Exits with 0 when no findings, 1 when any issues are detected.

ASSETS_DIR="${1:-$(cd "$(dirname "$0")/../assets" && pwd)}"
REPORT="$(cd "$(dirname "$0")/.." && pwd)/docs/ALIASES_FUNCTIONS_CONFLICTS_REPORT.md"

alias_file="$ASSETS_DIR/.aliases"
functions_file="$ASSETS_DIR/.functions"

declare -A alias_map
declare -A func_map

add_alias() {
    local name="$1"
    alias_map["$name"]=$((${alias_map["$name"]:-0} + 1))
}

add_func() {
    local name="$1"
    func_map["$name"]=$((${func_map["$name"]:-0} + 1))
}

parse_aliases() {
    [ -f "$alias_file" ] || return 0
    # Extract alias name from lines like: alias name='value' or alias -- -='value'
    while IFS= read -r line; do
        # skip comments and blank lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        if [[ "$line" =~ ^[[:space:]]*alias[[:space:]]+(--[[:space:]]+)?([^=[:space:]]+) ]]; then
            name="${BASH_REMATCH[2]}"
            # strip potential quotes around name
            name="${name#\"}"
            name="${name%\"}"
            name="${name#\'}"
            name="${name%\'}"
            add_alias "$name"
        fi
    done <"$alias_file"
}

parse_functions_in_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    # Capture both "function name()" and "name() {" forms
    while IFS= read -r line; do
        # skip comments
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        if [[ "$line" =~ ^[[:space:]]*function[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]*\( ]]; then
            add_func "${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*\(\)[[:space:]]*\{ ]]; then
            add_func "${BASH_REMATCH[1]}"
        fi
    done <"$file"
}

parse_functions() {
    # Only consider functions defined in the dotfile asset (assets/.functions).
    # This repository keeps interactive/helper functions in the dotfiles and
    # keeps script-local helpers inside scripts — making the dotfiles the
    # authoritative source of user-facing functions avoids confusion.
    [ -f "$functions_file" ] && parse_functions_in_file "$functions_file"
}

# Parse inputs
parse_aliases
parse_functions

# Gather results
alias_names=()
for k in "${!alias_map[@]}"; do alias_names+=("$k"); done
func_names=()
for k in "${!func_map[@]}"; do func_names+=("$k"); done

# Report variables
issues_found=0
report_lines=()
report_lines+=("# Aliases & Functions Conflicts Report")
report_lines+=("Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)")
report_lines+=("")
report_lines+=("## Summary")
report_lines+=("- Aliases analyzed: ${#alias_names[@]}")
report_lines+=("- Functions analyzed: ${#func_names[@]}")
report_lines+=("")

conflict_messages=()

# Find alias vs function collisions
for a in "${alias_names[@]}"; do
    if [[ -n "${func_map[$a]:-}" ]]; then
        conflict_messages+=("ALIAS-FUNC NAME COLLISION: $a (alias in $alias_file and function defined in repo)")
    fi
done

# Duplicates in functions (count > 1)
for f in "${func_names[@]}"; do
    count=${func_map[$f]:-0}
    if [ "$count" -gt 1 ]; then
        conflict_messages+=("FUNC duplicate: $f ($count)")
    fi
done

# Check conflicts against system (type -a)
report_lines+=("")
report_lines+=("### Conflicts with existing environment (alias/function/command/builtin)")
env_conflicts=()
for name in "${alias_names[@]}" "${func_names[@]}"; do
    # skip empty
    [ -z "$name" ] && continue
    # Use a clean non-exported shell environment to avoid detecting functions
    # that are defined inside this running script (avoid false positives).
    if type_output=$(env -i PATH="$PATH" bash -lc "type -a $name" 2>/dev/null); then
        # If type -a returns anything, note it
        env_conflicts+=("$name: $(echo "$type_output" | tr '\n' ' | ')")
    fi
done

if [ ${#env_conflicts[@]} -eq 0 ]; then
    report_lines+=("- No name collisions with existing commands/builtins detected.")
else
    issues_found=1
    for c in "${env_conflicts[@]}"; do
        report_lines+=("- $c")
    done
fi

if [ ${#conflict_messages[@]} -ne 0 ]; then
    issues_found=1
    report_lines+=("")
    report_lines+=("### Alias vs function shadowing:")
    for m in "${conflict_messages[@]}"; do
        report_lines+=("- $m")
    done
fi

# List duplicates details
dups=()
for f in "${func_names[@]}"; do
    count=${func_map[$f]:-0}
    if [ "$count" -gt 1 ]; then
        dups+=("- FUNC duplicate: $f ($count)")
    fi
done
if [ ${#dups[@]} -ne 0 ]; then
    issues_found=1
    report_lines+=("")
    report_lines+=("### Duplicate definitions found:")
    for d in "${dups[@]}"; do report_lines+=("$d"); done
fi

# Write details section
report_lines+=("")
report_lines+=("## Details")
report_lines+=("### Alias names ($alias_file)")
for name in "${alias_names[@]}"; do report_lines+=("- $name"); done

report_lines+=("")
report_lines+=("### Function names (scan: $functions_file)")
for name in "${func_names[@]}"; do report_lines+=("- $name"); done

# If check-only mode was requested we still write the report and exit (behavior below)

# Write the report file (respect dry-run)
if [ "${DRY_RUN:-false}" = true ]; then
    print_dry_run "Write conflict report to $REPORT"
else
    execute mkdir -p "$(dirname "$REPORT")"
    printf "%s
" "${report_lines[@]}" >"$REPORT"
    # Footer about generator
    printf "%s
" "" "Generated by scripts/011_check_aliases_functions_conflicts.sh" >>"$REPORT"
fi

echo "Conflicts report generated at: $REPORT"

# If check-only mode requested, stop here and return non-zero when issues were
# found (useful for CI checks that want to stop on failures without applying
# any installs).
if [ "$check_only" = true ]; then
    if [ "$issues_found" -ne 0 ]; then
        echo "Issues detected (check-only): see $REPORT" >&2
    else
        echo "No issues detected (check-only)" >&2
    fi
    # check-only mode is intentionally warning-only by default — exit zero
    exit 0
fi

if [ "$issues_found" -ne 0 ]; then
    echo "One or more conflicts or duplicate definitions were found. See $REPORT for details." >&2
    if [ "$abort_on_conflict" = true ]; then
        exit 1
    else
        # warning-only mode -> do not treat as fatal
        echo "WARNING: conflicts detected, but running in warning-only mode (no abort)." >&2
        exit 0
    fi
else
    echo "No conflicts detected." >&2
    exit 0
fi
