#!/usr/bin/env bash
# verify_handoff_gate.sh — handoff/MEMORY/AGENTS separation (adapted from project-bootstrap)
# Usage: bash verify_handoff_gate.sh [project_dir]

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
verify_handoff_gate.sh — Handoff-destination verification gate

Usage: bash verify_handoff_gate.sh [project_dir]

Rules:
1. No dated Session Handoff blocks in AGENTS.md
2. No CONFIRMED_FACTS section header in AGENTS.md
3. SESSION_HANDOFF.md declares append-only (first 15 lines)
4. MEMORY.md references SESSION_HANDOFF + append-only
EOF
  exit 0
fi

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

PASS=0
FAIL=0
ERRORS=""

if [[ -f "$PROJECT_DIR/AGENTS.md" ]]; then
  if grep -Eq '^## Session Handoff — (19|20)[0-9]{2}' "$PROJECT_DIR/AGENTS.md"; then
    ERRORS+="FAIL: AGENTS.md contains handoff data blocks\n"
    FAIL=$((FAIL + 1))
  else
    echo "PASS: No handoff data blocks in AGENTS.md"
    PASS=$((PASS + 1))
  fi
  if grep -Eq '^#{2,3} CONFIRMED_FACTS' "$PROJECT_DIR/AGENTS.md"; then
    ERRORS+="FAIL: AGENTS.md contains CONFIRMED_FACTS section\n"
    FAIL=$((FAIL + 1))
  else
    echo "PASS: AGENTS.md has no CONFIRMED_FACTS section"
    PASS=$((PASS + 1))
  fi
else
  ERRORS+="FAIL: AGENTS.md not found\n"
  FAIL=$((FAIL + 1))
fi

if [[ -f "$PROJECT_DIR/SESSION_HANDOFF.md" ]]; then
  if head -15 "$PROJECT_DIR/SESSION_HANDOFF.md" | grep -qi 'append-only'; then
    echo "PASS: SESSION_HANDOFF.md declares append-only"
    PASS=$((PASS + 1))
  else
    ERRORS+="FAIL: SESSION_HANDOFF.md missing append-only in header\n"
    FAIL=$((FAIL + 1))
  fi
else
  ERRORS+="FAIL: SESSION_HANDOFF.md not found\n"
  FAIL=$((FAIL + 1))
fi

MEM=""
if [[ -f "$PROJECT_DIR/.agents/memory/MEMORY.md" ]]; then
  MEM="$PROJECT_DIR/.agents/memory/MEMORY.md"
elif [[ -f "$PROJECT_DIR/MEMORY.md" ]]; then
  MEM="$PROJECT_DIR/MEMORY.md"
fi

if [[ -n "$MEM" ]]; then
  SH_IN_MEM=$(grep -c 'SESSION_HANDOFF' "$MEM" 2>/dev/null || echo 0)
  APPEND_IN_MEM=$(grep -ci 'append-only' "$MEM" 2>/dev/null || echo 0)
  # normalize possible newline from grep -c quirks
  SH_IN_MEM=$(echo "$SH_IN_MEM" | tr -d ' \n')
  APPEND_IN_MEM=$(echo "$APPEND_IN_MEM" | tr -d ' \n')
  if [[ "${SH_IN_MEM:-0}" -gt 0 && "${APPEND_IN_MEM:-0}" -gt 0 ]]; then
    echo "PASS: MEMORY.md references SESSION_HANDOFF as append-only"
    PASS=$((PASS + 1))
  else
    ERRORS+="FAIL: MEMORY.md missing SESSION_HANDOFF or append-only\n"
    FAIL=$((FAIL + 1))
  fi
else
  ERRORS+="FAIL: MEMORY.md not found\n"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== Handoff gate: ${PASS}/$((PASS + FAIL)) PASS ==="
if [[ $FAIL -gt 0 ]]; then
  echo -e "$ERRORS"
  exit 1
fi
echo "Gate PASSED."
exit 0
