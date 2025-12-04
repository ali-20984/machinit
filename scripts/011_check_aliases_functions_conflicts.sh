#!/usr/bin/env bash
set -u

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
  alias_map["$name"]=$(( ${alias_map["$name"]:-0} + 1 ))
}

add_func() {
  local name="$1"
  func_map["$name"]=$(( ${func_map["$name"]:-0} + 1 ))
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
      name="${name#\"}"; name="${name%\"}"
      name="${name#\'}"; name="${name%\'}"
      add_alias "$name"
    fi
  done < "$alias_file"
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
  done < "$file"
}

parse_functions() {
  [ -f "$functions_file" ] && parse_functions_in_file "$functions_file"
  # also scan scripts for additional functions
  for f in "$(cd "$(dirname "$0")" && pwd)"/*.sh; do
    # only if exists
    [ -f "$f" ] || continue
    parse_functions_in_file "$f"
  done
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
  # check type; some shells have type -t
  # Run `type -a` in a fresh shell to avoid detecting helper functions defined inside
  # *this* script (which would cause self-reported conflicts).
  if type_output=$(bash -lc "type -a -- '$name' 2>/dev/null"); then
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
  if [ ${func_map[$f]:-0} -gt 1 ]; then
    dups+=("- FUNC duplicate: $f (${func_map[$f]})")
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
report_lines+=("### Function names (scan: $functions_file and scripts/*.sh)")
for name in "${func_names[@]}"; do report_lines+=("- $name"); done


# Write the report file
mkdir -p "$(dirname "$REPORT")"
printf "%s
" "${report_lines[@]}" > "$REPORT"
# Footer about generator
printf "%s
" "" "Generated by scripts/011_check_aliases_functions_conflicts.sh" >> "$REPORT"

echo "Conflicts report generated at: $REPORT"

if [ "$issues_found" -ne 0 ]; then
  echo "One or more conflicts or duplicate definitions were found. See $REPORT for details." >&2
  exit 1
else
  echo "No conflicts detected." >&2
  exit 0
fi
