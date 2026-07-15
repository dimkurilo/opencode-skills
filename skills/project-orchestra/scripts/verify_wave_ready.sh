#!/usr/bin/env bash
# verify_wave_ready.sh — live wave has SPEC+PLAN+stamp (not waves/_template)
# Usage: bash verify_wave_ready.sh <wave_dir>

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 1 ]]; then
  cat <<'EOF'
verify_wave_ready.sh — live wave readiness (SPEC + PLAN + REVIEW-STAMP)

Usage: bash verify_wave_ready.sh <wave_dir>

Requires in the given wave directory (not waves/_template):
  - SPEC.md or SPEC.xml
  - PLAN.md or PLAN.xml
  - REVIEW-STAMP.md

Use this before raeh-review/hash, not verify_raeh_ready (that only checks install skeleton).
EOF
  [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && exit 0
  exit 1
fi

WAVE_DIR="$1"
if [[ ! -d "$WAVE_DIR" ]]; then
  echo "FAIL: not a directory: $WAVE_DIR" >&2
  exit 1
fi
WAVE_DIR="$(cd "$WAVE_DIR" && pwd)"

if [[ "$WAVE_DIR" == *"/waves/_template" ]] || [[ "$(basename "$WAVE_DIR")" == "_template" ]]; then
  echo "FAIL: $WAVE_DIR is the install skeleton, not a live wave" >&2
  exit 1
fi

PASS=0
FAIL=0

check_one_of() {
  local label="$1"
  shift
  local f
  for f in "$@"; do
    if [[ -f "$WAVE_DIR/$f" ]]; then
      echo "PASS: $label → $f"
      PASS=$((PASS + 1))
      return 0
    fi
  done
  echo "FAIL: missing $label (tried: $*)"
  FAIL=$((FAIL + 1))
}

echo "=== Wave ready: $WAVE_DIR ==="
check_one_of "SPEC" SPEC.md SPEC.xml
check_one_of "PLAN" PLAN.md PLAN.xml
if [[ -f "$WAVE_DIR/REVIEW-STAMP.md" ]]; then
  echo "PASS: REVIEW-STAMP.md"
  PASS=$((PASS + 1))
else
  echo "FAIL: missing REVIEW-STAMP.md"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== Wave ready: $PASS pass, $FAIL fail ==="
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
