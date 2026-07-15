#!/usr/bin/env bash
# verify_os_gate.sh — Phase 3 done checks for multi-agent program OS
# Usage: bash verify_os_gate.sh [project_dir]
# Exit 0 if all required OS files present.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
verify_os_gate.sh — Phase 3 OS readiness gate

Usage: bash verify_os_gate.sh [project_dir]

Required: AGENTS.md, SPEC.md, STATUS.md, SESSION_HANDOFF.md,
          .agents/memory/MEMORY.md, plan.md, .gitignore,
          waves/README.md, waves/_template/REVIEW-STAMP.md,
          prompts/_dispatch/dispatch-algorithm.md,
          prompts/_dispatch/model-shapes.md,
          prompts/_dispatch/ (>=3 cheatsheets)
EOF
  exit 0
fi

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

PASS=0
FAIL=0
ERRORS=""

req_file() {
  local path="$1"
  local label="${2:-$1}"
  if [[ -f "$PROJECT_DIR/$path" ]]; then
    echo "PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "FAIL: missing $label ($path)"
    ERRORS+="FAIL: $path\n"
    FAIL=$((FAIL + 1))
  fi
}

req_dir() {
  local path="$1"
  local label="${2:-$1}"
  if [[ -d "$PROJECT_DIR/$path" ]]; then
    echo "PASS: $label/"
    PASS=$((PASS + 1))
  else
    echo "FAIL: missing $label/ ($path)"
    ERRORS+="FAIL: $path/\n"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== OS gate: $PROJECT_DIR ==="
req_file "AGENTS.md"
req_file "SPEC.md"
req_file "STATUS.md"
req_file "plan.md"
req_file "SESSION_HANDOFF.md"
req_file ".agents/memory/MEMORY.md"
req_file ".gitignore"
req_file "waves/README.md"
req_file "waves/_template/REVIEW-STAMP.md"
req_file "waves/_template/EXEC-REPORT.md"
req_dir "prompts/_dispatch"
req_dir "audits"
req_dir "docs"

# Mandatory dispatch pack (algorithm + shapes)
req_dispatch_file() {
  local path="$1"
  local min_bytes="${2:-80}"
  if [[ -f "$PROJECT_DIR/$path" ]]; then
    local sz
    sz=$(wc -c < "$PROJECT_DIR/$path" | tr -d ' ')
    if [[ "$sz" -ge "$min_bytes" ]]; then
      echo "PASS: $path ($sz bytes)"
      PASS=$((PASS + 1))
    else
      echo "FAIL: $path too small ($sz < $min_bytes bytes)"
      ERRORS+="FAIL: $path size\n"
      FAIL=$((FAIL + 1))
    fi
  else
    echo "FAIL: missing $path"
    ERRORS+="FAIL: $path\n"
    FAIL=$((FAIL + 1))
  fi
}
req_dispatch_file "prompts/_dispatch/dispatch-algorithm.md" 200
req_dispatch_file "prompts/_dispatch/model-shapes.md" 200

# At least 3 cheatsheets in _dispatch
CHEAT_COUNT=0
if [[ -d "$PROJECT_DIR/prompts/_dispatch" ]]; then
  CHEAT_COUNT=$(find "$PROJECT_DIR/prompts/_dispatch" -maxdepth 1 -name '*cheatsheet*.md' 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$CHEAT_COUNT" -ge 3 ]]; then
  echo "PASS: prompts/_dispatch cheatsheets >= 3 ($CHEAT_COUNT)"
  PASS=$((PASS + 1))
else
  echo "FAIL: prompts/_dispatch needs >=3 cheatsheets (found $CHEAT_COUNT)"
  ERRORS+="FAIL: cheatsheets\n"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== OS gate: $PASS pass, $FAIL fail ==="
if [[ $FAIL -gt 0 ]]; then
  echo -e "$ERRORS"
  exit 1
fi
echo "Gate PASSED. Project OS skeleton present (fill role placeholders next)."
exit 0
