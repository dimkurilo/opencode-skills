#!/usr/bin/env bash
# verify_raeh_ready.sh — waves/_template + README exist
# Usage: bash verify_raeh_ready.sh [project_dir]

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
verify_raeh_ready.sh — R.A.E.H. install readiness

Usage: bash verify_raeh_ready.sh [project_dir]

Requires waves/README.md and waves/_template/{REVIEW-STAMP,EXEC-REPORT,STATUS}.md
EOF
  exit 0
fi

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

PASS=0
FAIL=0

check() {
  local rel="$1"
  if [[ -f "$PROJECT_DIR/$rel" ]]; then
    echo "PASS: $rel"
    PASS=$((PASS + 1))
  else
    echo "FAIL: missing $rel"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== R.A.E.H. ready: $PROJECT_DIR ==="
check "waves/README.md"
check "waves/_template/REVIEW-STAMP.md"
check "waves/_template/EXEC-REPORT.md"
check "waves/_template/STATUS.md"

echo ""
echo "=== R.A.E.H. ready: $PASS pass, $FAIL fail ==="
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
