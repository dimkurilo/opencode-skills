#!/usr/bin/env bash
# hash_acceptance.sh — sha256 of SPEC+PLAN → acceptance.hash
# Usage: bash hash_acceptance.sh <wave_dir>
# Writes acceptance.hash in wave_dir. Prints hash to stdout.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 1 ]]; then
  cat <<'EOF'
hash_acceptance.sh — compute acceptance.hash for a wave

Usage: bash hash_acceptance.sh <wave_dir>

Hashes (sha256) concatenated contents of SPEC.xml (or SPEC.md) and PLAN.xml (or PLAN.md).
Writes <wave_dir>/acceptance.hash
EOF
  [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && exit 0
  exit 1
fi

WAVE_DIR="$1"
if [[ ! -d "$WAVE_DIR" ]]; then
  echo "FAIL: not a directory: $WAVE_DIR" >&2
  exit 1
fi

SPEC=""
PLAN=""
for c in SPEC.xml SPEC.md; do
  [[ -f "$WAVE_DIR/$c" ]] && SPEC="$WAVE_DIR/$c" && break
done
for c in PLAN.xml PLAN.md; do
  [[ -f "$WAVE_DIR/$c" ]] && PLAN="$WAVE_DIR/$c" && break
done

if [[ -z "$SPEC" || -z "$PLAN" ]]; then
  echo "FAIL: need SPEC.xml|md and PLAN.xml|md in $WAVE_DIR" >&2
  exit 1
fi

if command -v shasum >/dev/null 2>&1; then
  HASH=$(cat "$SPEC" "$PLAN" | shasum -a 256 | awk '{print $1}')
elif command -v sha256sum >/dev/null 2>&1; then
  HASH=$(cat "$SPEC" "$PLAN" | sha256sum | awk '{print $1}')
else
  echo "FAIL: no shasum or sha256sum" >&2
  exit 1
fi

OUT="$WAVE_DIR/acceptance.hash"
{
  echo "spec=$(basename "$SPEC")"
  echo "plan=$(basename "$PLAN")"
  echo "sha256=$HASH"
  echo "created=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date)"
} > "$OUT"

echo "$HASH"
echo "Wrote $OUT" >&2
exit 0
