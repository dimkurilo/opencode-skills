#!/usr/bin/env bash
# verify_stamp_schema.sh — required REVIEW-STAMP fields present
# Usage: bash verify_stamp_schema.sh <stamp_file_or_wave_dir>

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 1 ]]; then
  cat <<'EOF'
verify_stamp_schema.sh — validate REVIEW-STAMP required fields

Usage: bash verify_stamp_schema.sh <stamp.md | wave_dir>

Required fields:
  AGREED: YES|NO
  SPEC_PATH, PLAN_PATH (or SPEC_HASH)
  ROUND, MAX (or MAX_ROUNDS)
Optional but recommended: SESSION_ID, OPEN_DELTAS section
EOF
  [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && exit 0
  exit 1
fi

TARGET="$1"
STAMP=""
if [[ -d "$TARGET" ]]; then
  if [[ -f "$TARGET/REVIEW-STAMP.md" ]]; then
    STAMP="$TARGET/REVIEW-STAMP.md"
  elif [[ -f "$TARGET/waves/_template/REVIEW-STAMP.md" ]]; then
    STAMP="$TARGET/waves/_template/REVIEW-STAMP.md"
  else
    echo "FAIL: no REVIEW-STAMP.md under $TARGET"
    exit 1
  fi
elif [[ -f "$TARGET" ]]; then
  STAMP="$TARGET"
else
  echo "FAIL: not a file or directory: $TARGET"
  exit 1
fi

PASS=0
FAIL=0

require_re() {
  local label="$1"
  local re="$2"
  if grep -Eqi "$re" "$STAMP"; then
    echo "PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "FAIL: missing $label"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Stamp schema: $STAMP ==="
require_re "AGREED YES|NO" '^AGREED:[[:space:]]*(YES|NO)\b'
require_re "SPEC_PATH or SPEC_HASH" '(SPEC_PATH|SPEC_HASH):'
require_re "PLAN_PATH or PLAN_HASH" '(PLAN_PATH|PLAN_HASH|SPEC_HASH):'
require_re "ROUND" 'ROUND:'
require_re "MAX / MAX_ROUNDS" '(MAX_ROUNDS|MAX):'

# If AGREED=YES, hash should be present
if grep -Eqi '^AGREED:[[:space:]]*YES\b' "$STAMP"; then
  if grep -Eqi '(SPEC_HASH|acceptance\.hash|CHECKLIST_VERSION)' "$STAMP"; then
    echo "PASS: YES stamp has hash/version marker"
    PASS=$((PASS + 1))
  else
    echo "FAIL: AGREED=YES without SPEC_HASH/checklist version"
    FAIL=$((FAIL + 1))
  fi
fi

echo ""
echo "=== Stamp schema: $PASS pass, $FAIL fail ==="
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
