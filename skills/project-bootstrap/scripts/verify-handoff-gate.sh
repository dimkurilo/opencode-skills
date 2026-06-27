#!/usr/bin/env bash
# verify-handoff-gate.sh — Phase 4c Handoff-Destination Verification Gate
# Проверяет, что handoff-данные и факты не попали в AGENTS.md,
# и что SESSION_HANDOFF.md/MEMORY.md соблюдают append-only контракт.
#
# Использование: bash verify-handoff-gate.sh [project_dir]
#   project_dir — корень проекта (по умолчанию: текущая директория)

set -euo pipefail
PROJECT_DIR="${1:-.}"

PASS=0
FAIL=0
ERRORS=""

# === Check 1: No handoff DATA blocks in AGENTS.md ===
# PASS: 0 matches — no date-stamped handoff blocks
# FAIL: ≥1 — handoff data leaked into AGENTS.md
# Note: grep for `## Session Handoff — 20` avoids false-positive on
#       protocol descriptions like `Формат блока: ## Session Handoff — [Date]`
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  if grep -Eq '^## Session Handoff — (19|20)[0-9]{2}' "$PROJECT_DIR/AGENTS.md"; then
    ERRORS+="FAIL: AGENTS.md contains handoff data blocks (## Session Handoff — YYYY-MM-DD)\n"
    ((FAIL++))
  else
    echo "PASS: No handoff data blocks in AGENTS.md"
    ((PASS++))
  fi
else
  ERRORS+="SKIP: AGENTS.md not found\n"
fi

# === Check 2: No CONFIRMED_FACTS section header in AGENTS.md ===
# PASS: 0 — facts go to MEMORY.md
# FAIL: ≥1 — memory content section leaked into AGENTS.md
# Note: grep for `^### CONFIRMED_FACTS` (H3 section header) not inline mentions
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  if grep -Eq '^#{2,3} CONFIRMED_FACTS' "$PROJECT_DIR/AGENTS.md"; then
    ERRORS+="FAIL: AGENTS.md contains CONFIRMED_FACTS section header\n"
    ((FAIL++))
  else
    echo "PASS: AGENTS.md has no CONFIRMED_FACTS section"
    ((PASS++))
  fi
else
  ERRORS+="SKIP: AGENTS.md not found\n"
fi

# === Check 3: SESSION_HANDOFF.md header declares append-only ===
# PASS: ≥1 — append-only contract visible in file header (first 10 lines)
# FAIL: 0 — missing append-only declaration
if [ -f "$PROJECT_DIR/SESSION_HANDOFF.md" ]; then
  if head -10 "$PROJECT_DIR/SESSION_HANDOFF.md" | grep -qi 'append-only'; then
    echo "PASS: SESSION_HANDOFF.md declares append-only"
    ((PASS++))
  else
    ERRORS+="FAIL: SESSION_HANDOFF.md missing append-only header (first 10 lines)\n"
    ((FAIL++))
  fi
else
  ERRORS+="FAIL: SESSION_HANDOFF.md not found\n"
  ((FAIL++))
fi

# === Check 4: MEMORY.md references SESSION_HANDOFF.md as append-only ===
# PASS: both patterns found
# FAIL: either missing
if [ -f "$PROJECT_DIR/.agents/memory/MEMORY.md" ]; then
  SH_IN_MEM=$(grep -c 'SESSION_HANDOFF' "$PROJECT_DIR/.agents/memory/MEMORY.md" 2>/dev/null || echo 0)
  APPEND_IN_MEM=$(grep -ci 'append-only' "$PROJECT_DIR/.agents/memory/MEMORY.md" 2>/dev/null || echo 0)
  if [ "$SH_IN_MEM" -gt 0 ] && [ "$APPEND_IN_MEM" -gt 0 ]; then
    echo "PASS: MEMORY.md references SESSION_HANDOFF.md as append-only"
    ((PASS++))
  else
    ERRORS+="FAIL: MEMORY.md missing SESSION_HANDOFF reference or append-only label\n"
    ((FAIL++))
  fi
elif [ -f "$PROJECT_DIR/MEMORY.md" ]; then
  # Fallback: MEMORY.md in project root (non-standard layout)
  SH_IN_MEM=$(grep -c 'SESSION_HANDOFF' "$PROJECT_DIR/MEMORY.md" 2>/dev/null || echo 0)
  APPEND_IN_MEM=$(grep -ci 'append-only' "$PROJECT_DIR/MEMORY.md" 2>/dev/null || echo 0)
  if [ "$SH_IN_MEM" -gt 0 ] && [ "$APPEND_IN_MEM" -gt 0 ]; then
    echo "PASS: MEMORY.md references SESSION_HANDOFF.md as append-only"
    ((PASS++))
  else
    ERRORS+="FAIL: MEMORY.md missing SESSION_HANDOFF reference or append-only label\n"
    ((FAIL++))
  fi
else
  ERRORS+="SKIP: MEMORY.md not found\n"
fi

# === Report ===
echo ""
echo "=== Handoff-Destination Gate: ${PASS}/$((PASS + FAIL)) PASS ==="
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo -e "$ERRORS"
  echo "Gate FAILED. Fix contradictions before proceeding to Phase 5 audit."
  exit 1
else
  echo "Gate PASSED. Handoff-destination rules consistent."
  exit 0
fi
