#!/usr/bin/env bash
# verify_stamp_hash.sh — pre-execute: re-hash files named in stamp; compare to SPEC_HASH
# Usage: bash verify_stamp_hash.sh <stamp.md | wave_dir>
# AUTHORITY: run before raeh-execute. Stamp is reviewer-only; do not re-stamp as executor.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 1 ]]; then
  cat <<'EOF'
verify_stamp_hash.sh — pre-execute hash equality gate

Usage: bash verify_stamp_hash.sh <stamp.md | wave_dir>

Requires AGREED: YES. Reads SPEC_PATH and PLAN_PATH from the stamp,
hashes those exact files (relative to wave dir), and compares to
SPEC_HASH (64 hex) or acceptance.hash sha256= line in the wave dir.

Placeholder text / mere presence of "SPEC_HASH" does NOT pass.
EOF
  [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && exit 0
  exit 1
fi

TARGET="$1"
STAMP=""
WAVE_DIR=""

if [[ -d "$TARGET" ]]; then
  WAVE_DIR="$(cd "$TARGET" && pwd)"
  if [[ -f "$WAVE_DIR/REVIEW-STAMP.md" ]]; then
    STAMP="$WAVE_DIR/REVIEW-STAMP.md"
  else
    echo "FAIL: no REVIEW-STAMP.md in $WAVE_DIR" >&2
    exit 1
  fi
elif [[ -f "$TARGET" ]]; then
  STAMP="$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")"
  WAVE_DIR="$(cd "$(dirname "$STAMP")" && pwd)"
else
  echo "FAIL: not a file or directory: $TARGET" >&2
  exit 1
fi

if ! grep -Eqi '^AGREED:[[:space:]]*YES\b' "$STAMP"; then
  echo "FAIL: stamp is not AGREED: YES — $STAMP" >&2
  exit 1
fi

# Refuse validating the stock template as a live wave
if [[ "$WAVE_DIR" == *"/waves/_template" ]]; then
  echo "FAIL: refuse pre-execute hash on waves/_template (not a live wave)" >&2
  exit 1
fi

field() {
  local key="$1"
  grep -E "^${key}:" "$STAMP" | head -1 | sed -E "s/^${key}:[[:space:]]*//" | tr -d '\r' | sed 's/[[:space:]]*$//'
}

SPEC_REL="$(field SPEC_PATH)"
PLAN_REL="$(field PLAN_PATH)"
STAMP_HASH="$(field SPEC_HASH)"

# Accept sha256 from acceptance.hash if SPEC_HASH missing/placeholder
if [[ -z "$STAMP_HASH" ]] || ! echo "$STAMP_HASH" | grep -Eq '^[a-fA-F0-9]{64}$'; then
  if [[ -f "$WAVE_DIR/acceptance.hash" ]]; then
    STAMP_HASH="$(grep -E '^sha256=' "$WAVE_DIR/acceptance.hash" | head -1 | cut -d= -f2 | tr -d '[:space:]')"
  fi
fi

if ! echo "${STAMP_HASH:-}" | grep -Eq '^[a-fA-F0-9]{64}$'; then
  echo "FAIL: no real 64-hex SPEC_HASH (or acceptance.hash sha256=) on YES stamp" >&2
  echo "  got: ${STAMP_HASH:-<empty>}" >&2
  exit 1
fi

resolve_file() {
  local rel="$1"
  local label="$2"
  if [[ -z "$rel" ]]; then
    echo "FAIL: missing $label in stamp" >&2
    exit 1
  fi
  # absolute
  if [[ -f "$rel" ]]; then
    echo "$rel"
    return
  fi
  # relative to wave dir
  if [[ -f "$WAVE_DIR/$rel" ]]; then
    echo "$WAVE_DIR/$rel"
    return
  fi
  # basename only in wave dir
  local base
  base="$(basename "$rel")"
  if [[ -f "$WAVE_DIR/$base" ]]; then
    echo "$WAVE_DIR/$base"
    return
  fi
  # relative to parent of waves/ (project root)
  if [[ -f "$WAVE_DIR/../$rel" ]]; then
    echo "$(cd "$WAVE_DIR/.." && pwd)/$rel"
    return
  fi
  if [[ -f "$WAVE_DIR/../../$rel" ]]; then
    echo "$(cd "$WAVE_DIR/../.." && pwd)/$rel"
    return
  fi
  echo "FAIL: cannot resolve $label path: $rel (wave=$WAVE_DIR)" >&2
  exit 1
}

SPEC_FILE="$(resolve_file "$SPEC_REL" SPEC_PATH)"
PLAN_FILE="$(resolve_file "$PLAN_REL" PLAN_PATH)"

if command -v shasum >/dev/null 2>&1; then
  LIVE_HASH=$(cat "$SPEC_FILE" "$PLAN_FILE" | shasum -a 256 | awk '{print $1}')
elif command -v sha256sum >/dev/null 2>&1; then
  LIVE_HASH=$(cat "$SPEC_FILE" "$PLAN_FILE" | sha256sum | awk '{print $1}')
else
  echo "FAIL: no shasum or sha256sum" >&2
  exit 1
fi

echo "=== Stamp hash gate: $STAMP ==="
echo "SPEC_PATH → $SPEC_FILE"
echo "PLAN_PATH → $PLAN_FILE"
echo "stamp: $STAMP_HASH"
echo "live:  $LIVE_HASH"

if [[ "$STAMP_HASH" != "$LIVE_HASH" ]]; then
  echo "FAIL: hash mismatch — re-run review or hash_acceptance after SPEC/PLAN change" >&2
  exit 1
fi

echo "PASS: live SPEC+PLAN match stamp hash"
exit 0
