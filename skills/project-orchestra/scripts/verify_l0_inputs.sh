#!/usr/bin/env bash
# verify_l0_inputs.sh — list canon files for L0 consistency pass
# Usage: bash verify_l0_inputs.sh [project_dir]
# Exit 0 if enough inputs exist to run L0; 1 if critical missing.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
verify_l0_inputs.sh — list L0 canon inputs

Usage: bash verify_l0_inputs.sh [project_dir]

Checks presence of AGENTS.md, SPEC.md, STATUS.md, plan.md, MEMORY,
and CLI entry files. Prints paths and MISSING lines. Exit 1 if AGENTS or SPEC missing.
EOF
  exit 0
fi

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

PASS=0
FAIL=0

check_file() {
  local label="$1"
  local path="$2"
  local required="${3:-0}"
  if [[ -f "$path" ]]; then
    echo "PRESENT: $label → $path"
    PASS=$((PASS + 1))
  else
    if [[ "$required" == "1" ]]; then
      echo "MISSING (required): $label → $path"
      FAIL=$((FAIL + 1))
    else
      echo "MISSING (optional): $label → $path"
    fi
  fi
}

echo "=== L0 input inventory: $PROJECT_DIR ==="
check_file "AGENTS.md" "$PROJECT_DIR/AGENTS.md" 1
check_file "SPEC.md" "$PROJECT_DIR/SPEC.md" 1
check_file "STATUS.md" "$PROJECT_DIR/STATUS.md" 0
check_file "plan.md" "$PROJECT_DIR/plan.md" 0
check_file "INTENT.md" "$PROJECT_DIR/INTENT.md" 0
check_file "MEMORY.md" "$PROJECT_DIR/.agents/memory/MEMORY.md" 0
check_file "SESSION_HANDOFF.md" "$PROJECT_DIR/SESSION_HANDOFF.md" 0
check_file "CLAUDE.md" "$PROJECT_DIR/CLAUDE.md" 0
check_file "Grok entry (.grok/)" "$PROJECT_DIR/.grok" 0

# Directory markers
if [[ -d "$PROJECT_DIR/.claude" ]]; then
  echo "PRESENT: .claude/ → $PROJECT_DIR/.claude"
  PASS=$((PASS + 1))
else
  echo "MISSING (optional): .claude/"
fi

echo ""
echo "=== L0 inputs: present=$PASS missing_required=$FAIL ==="
echo "Next: write audits/<date>-L0-consistency.md with verdict CLEAN|CONTRADICTIONS"
echo "Checks: single orchestrator identity; write locks; role %; STATUS↔SPEC; one focus; gate names"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
