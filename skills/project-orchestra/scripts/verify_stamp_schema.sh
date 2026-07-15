#!/usr/bin/env bash
# verify_stamp_schema.sh — required REVIEW-STAMP fields present
# Usage: bash verify_stamp_schema.sh <stamp_file_or_wave_dir>
# Note: for AGREED=YES pre-execute equality, also run verify_stamp_hash.sh

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 1 ]]; then
  cat <<'EOF'
verify_stamp_schema.sh — validate REVIEW-STAMP required fields

Usage: bash verify_stamp_schema.sh <stamp.md | wave_dir>

Required fields:
  AGREED: YES|NO
  SPEC_PATH or SPEC_HASH
  PLAN_PATH or PLAN_HASH  (SPEC_HASH alone does NOT satisfy PLAN)
  ROUND, MAX (or MAX_ROUNDS)
If AGREED=YES: SPEC_HASH must be a real 64-hex digest OR wave dir
  must have acceptance.hash with sha256=<64-hex>.
  Placeholder text like "(run hash...)" does NOT pass.
  CHECKLIST_VERSION is NOT a substitute for content hash.
Before EXECUTE: bash verify_stamp_hash.sh <wave_dir>
EOF
  [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && exit 0
  exit 1
fi

TARGET="$1"
STAMP=""
WAVE_DIR=""
if [[ -d "$TARGET" ]]; then
  if [[ -f "$TARGET/REVIEW-STAMP.md" ]]; then
    STAMP="$TARGET/REVIEW-STAMP.md"
    WAVE_DIR="$(cd "$TARGET" && pwd)"
  elif [[ -f "$TARGET/waves/_template/REVIEW-STAMP.md" ]]; then
    # install skeleton only — never treat as live YES stamp
    STAMP="$TARGET/waves/_template/REVIEW-STAMP.md"
    WAVE_DIR=""
  else
    echo "FAIL: no REVIEW-STAMP.md under $TARGET"
    exit 1
  fi
elif [[ -f "$TARGET" ]]; then
  STAMP="$TARGET"
  WAVE_DIR="$(cd "$(dirname "$TARGET")" && pwd)"
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
require_re "PLAN_PATH or PLAN_HASH" '(PLAN_PATH|PLAN_HASH):'
require_re "ROUND" 'ROUND:'
require_re "MAX / MAX_ROUNDS" '(MAX_ROUNDS|MAX):'

# If AGREED=YES, require a real hash value (not a marker string)
if grep -Eqi '^AGREED:[[:space:]]*YES\b' "$STAMP"; then
  # Refuse YES on install template
  if [[ -n "$WAVE_DIR" && "$WAVE_DIR" == *"/waves/_template" ]] || \
     [[ "$STAMP" == *"/waves/_template/"* ]]; then
    echo "FAIL: AGREED=YES is invalid on waves/_template stamp (not a live wave)"
    FAIL=$((FAIL + 1))
  else
    HASH_OK=0
    # SPEC_HASH: <64 hex>
    if grep -Eqi '^SPEC_HASH:[[:space:]]*[a-f0-9]{64}\b' "$STAMP"; then
      HASH_OK=1
      echo "PASS: YES stamp has real SPEC_HASH (64 hex)"
      PASS=$((PASS + 1))
    fi
    # or acceptance.hash beside stamp
    if [[ $HASH_OK -eq 0 && -n "$WAVE_DIR" && -f "$WAVE_DIR/acceptance.hash" ]]; then
      if grep -Eq '^sha256=[a-fA-F0-9]{64}$' "$WAVE_DIR/acceptance.hash"; then
        HASH_OK=1
        echo "PASS: YES stamp backed by acceptance.hash sha256="
        PASS=$((PASS + 1))
      fi
    fi
    if [[ $HASH_OK -eq 0 ]]; then
      echo "FAIL: AGREED=YES without real 64-hex SPEC_HASH or acceptance.hash (placeholder/marker not enough)"
      FAIL=$((FAIL + 1))
    fi
  fi
fi

echo ""
echo "=== Stamp schema: $PASS pass, $FAIL fail ==="
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
