#!/bin/bash
# Ensure Finder sidebar script constructs file:// URLs correctly (slashes preserved)
set -euo pipefail

SCRIPT=scripts/052_configure_finder_and_sidebar.sh

echo "Inspecting file:// generation in $SCRIPT..."

if grep -q "urllib.parse.quote(sys.argv\[1\], safe=\"/\")" "$SCRIPT"; then
    echo "PASS: script uses urllib.parse.quote(..., safe='/') to preserve slashes"
    exit 0
else
    echo "FAIL: script doesn't use safe='/' when quoting file paths for file:// URLs"
    exit 1
fi
