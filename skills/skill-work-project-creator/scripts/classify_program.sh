#!/usr/bin/env bash
# classify_program.sh — multi-agent vs single-home; domain_novelty hint
# Usage: bash classify_program.sh [project_dir]
# Exit 0 always on successful classification (JSON stdout).

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
classify_program.sh — classify project for multi-agent kit routing

Usage: bash classify_program.sh [project_dir]

Output JSON fields:
  program_class: multi_agent | single_home | undetermined
  domain_novelty_hint: FIRST_IN_PORTFOLIO | REPEAT_DOMAIN | TRANSFER | UNKNOWN
  recommendation: skill-work-project-creator | project-bootstrap | wave-spec | inspect
  signals: multi_cli, waves, roles, agents_md, handoff, bootstrap_like
EOF
  exit 0
fi

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

MULTI_CLI=0
WAVES=0
ROLES=0
AGENTS_MD=0
HANDOFF=0
BOOTSTRAP_LIKE=0
MEMORY_DOMAIN=0

[[ -f "$PROJECT_DIR/AGENTS.md" ]] && AGENTS_MD=1
[[ -f "$PROJECT_DIR/SESSION_HANDOFF.md" ]] && HANDOFF=1
[[ -d "$PROJECT_DIR/waves" ]] && WAVES=1
[[ -f "$PROJECT_DIR/.agents/memory/MEMORY.md" || -f "$PROJECT_DIR/MEMORY.md" ]] && MEMORY_DOMAIN=1

# Multi-CLI / multi-role signals
if grep -rqE '(Claude Code|OpenCode|Grok|ZCode|DeepSeek|orchestrator|Wave Executor|cross-auditor)' \
  "$PROJECT_DIR" --include='*.md' 2>/dev/null; then
  MULTI_CLI=1
fi

if [[ -f "$PROJECT_DIR/CLAUDE.md" ]] && [[ -d "$PROJECT_DIR/.agents" || -d "$PROJECT_DIR/.grok" ]]; then
  MULTI_CLI=1
fi

if grep -rqE '(role matrix|write locks|R\.A\.E\.H\.|REVIEW-STAMP|F-04)' \
  "$PROJECT_DIR" --include='*.md' 2>/dev/null; then
  ROLES=1
fi

# Single-home bootstrap-like: agents/memory but no multi-role
if [[ $AGENTS_MD -eq 1 && $MULTI_CLI -eq 0 && $ROLES -eq 0 ]]; then
  BOOTSTRAP_LIKE=1
fi

# domain_novelty hint from MEMORY / prior programs
NOVELTY="UNKNOWN"
if [[ -f "$PROJECT_DIR/.agents/memory/MEMORY.md" ]]; then
  if grep -qiE 'domain_novelty|REPEAT_DOMAIN|FIRST_IN_PORTFOLIO' \
    "$PROJECT_DIR/.agents/memory/MEMORY.md" 2>/dev/null; then
    if grep -qi 'REPEAT_DOMAIN' "$PROJECT_DIR/.agents/memory/MEMORY.md" 2>/dev/null; then
      NOVELTY="REPEAT_DOMAIN"
    elif grep -qi 'FIRST_IN_PORTFOLIO' "$PROJECT_DIR/.agents/memory/MEMORY.md" 2>/dev/null; then
      NOVELTY="FIRST_IN_PORTFOLIO"
    elif grep -qi 'TRANSFER' "$PROJECT_DIR/.agents/memory/MEMORY.md" 2>/dev/null; then
      NOVELTY="TRANSFER"
    fi
  elif grep -qiE 'CONFIRMED_FACTS|LEARNED_RULES' "$PROJECT_DIR/.agents/memory/MEMORY.md" 2>/dev/null; then
    # Has operational memory → likely REPEAT or TRANSFER; agent must decide
    NOVELTY="TRANSFER"
  fi
fi

if [[ $MULTI_CLI -eq 1 || $ROLES -eq 1 || ( $WAVES -eq 1 && $AGENTS_MD -eq 1 ) ]]; then
  CLASS="multi_agent"
  REC="skill-work-project-creator"
elif [[ $BOOTSTRAP_LIKE -eq 1 || ( $AGENTS_MD -eq 1 && $MULTI_CLI -eq 0 ) ]]; then
  CLASS="single_home"
  REC="project-bootstrap"
elif [[ $WAVES -eq 1 && $AGENTS_MD -eq 0 ]]; then
  CLASS="undetermined"
  REC="wave-spec"
else
  CLASS="undetermined"
  REC="inspect"
fi

# If multi_agent already has complete OS markers, wave work may be next
if [[ $CLASS == "multi_agent" && $WAVES -eq 1 && -f "$PROJECT_DIR/SPEC.md" && -f "$PROJECT_DIR/STATUS.md" ]]; then
  if [[ -d "$PROJECT_DIR/waves/_template" ]]; then
    REC="wave-spec"
  fi
fi

cat <<EOF
{
  "project_dir": "$PROJECT_DIR",
  "program_class": "$CLASS",
  "domain_novelty_hint": "$NOVELTY",
  "recommendation": "$REC",
  "signals": {
    "multi_cli": $MULTI_CLI,
    "waves": $WAVES,
    "roles": $ROLES,
    "agents_md": $AGENTS_MD,
    "handoff": $HANDOFF,
    "memory": $MEMORY_DOMAIN,
    "bootstrap_like": $BOOTSTRAP_LIKE
  }
}
EOF
