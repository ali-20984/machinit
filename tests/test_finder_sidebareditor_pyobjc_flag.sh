#!/bin/bash
# Verify FinderSidebar respects the MACHINIT_USE_PYOBJC env var and constructor flag
set -euo pipefail

echo "Testing FinderSidebar pyobjc opt-in behavior..."

# Default: should be disabled
OUT=$(PYTHONPATH=scripts/lib python3 -c 'from finder_sidebar_editor import FinderSidebar; print("DEFAULT", getattr(FinderSidebar(), "_allow_pyobjc", False))' 2>&1 || true)
if echo "$OUT" | grep -q "DEFAULT False"; then
    echo "PASS: default _allow_pyobjc is False"
else
    echo "FAIL: default _allow_pyobjc not False -> $OUT" >&2
    exit 1
fi

OUT=$(PYTHONPATH=scripts/lib MACHINIT_USE_PYOBJC=1 python3 -c 'from finder_sidebar_editor import FinderSidebar; print("ENV", getattr(FinderSidebar(), "_allow_pyobjc", False))' 2>&1 || true)
if echo "$OUT" | grep -q "ENV True"; then
    echo "PASS: MACHINIT_USE_PYOBJC env results in _allow_pyobjc True"
else
    echo "FAIL: MACHINIT_USE_PYOBJC env did not enable _allow_pyobjc -> $OUT" >&2
    exit 1
fi

OUT=$(PYTHONPATH=scripts/lib python3 -c 'from finder_sidebar_editor import FinderSidebar; print("CTOR", FinderSidebar(allow_pyobjc=True)._allow_pyobjc)' 2>&1 || true)
if echo "$OUT" | grep -q "CTOR True"; then
    echo "PASS: constructor allow_pyobjc=True enables _allow_pyobjc"
else
    echo "FAIL: constructor flag did not set _allow_pyobjc -> $OUT" >&2
    exit 1
fi
