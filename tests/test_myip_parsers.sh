#!/usr/bin/env bash
set -euo pipefail
FAILED=0

# Test JSON ip extraction
sample_json='{"ip":"203.0.113.45"}'
extracted=$(printf "%s" "$sample_json" | grep -Eo '"ip"[[:space:]]*:[[:space:]]*"[^"]+"' | sed -E 's/.*"ip"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)
if [ "$extracted" = "203.0.113.45" ]; then
    echo "PASS: JSON extraction"
else
    echo "FAIL: JSON extraction got '$extracted'"
    FAILED=1
fi

# Test strict IPv4 extraction
sample_text='Your IP: 198.51.100.123 some extra'
extracted=$(printf "%s" "$sample_text" | grep -Eo '((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])' || true)
if [ "$extracted" = "198.51.100.123" ]; then
    echo "PASS: IPv4 extraction"
else
    echo "FAIL: IPv4 extraction got '$extracted'"
    FAILED=1
fi

# Test IPv6-ish extraction
sample_ipv6='Some text with IPv6: 2001:0db8:85a3::8a2e:0370:7334 end'
extracted=$(printf "%s" "$sample_ipv6" | grep -Eo '([0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}|::|([0-9a-fA-F:]+::[0-9a-fA-F:]*)' | head -n1 || true)
if [ -n "$extracted" ]; then
    echo "PASS: IPv6 extraction (got '$extracted')"
else
    echo "FAIL: IPv6 extraction"
    FAILED=1
fi

if [ $FAILED -eq 0 ]; then
    echo "All myip parser tests passed."
    exit 0
else
    echo "Some myip parser tests failed."
    exit 1
fi
