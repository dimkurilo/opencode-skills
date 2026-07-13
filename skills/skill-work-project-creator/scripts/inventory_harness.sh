#!/usr/bin/env bash
# inventory_harness.sh — CLIs, skill packs, MCP markers (best-effort)
# Usage: bash inventory_harness.sh [project_dir]
# Exit 0 on success.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
inventory_harness.sh — best-effort harness inventory

Usage: bash inventory_harness.sh [project_dir]

Scans PATH and common skill/MCP locations. Does not require network.
Output: JSON with clis, skills_roots, mcp_hints, project_markers.
EOF
  exit 0
fi

PROJECT_DIR="${1:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# --- CLI presence ---
cli_check() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    echo "true"
  else
    echo "false"
  fi
}

HAS_GROK=$(cli_check grok)
HAS_OPENCODE=$(cli_check opencode)
HAS_CLAUDE=$(cli_check claude)
HAS_ZCODE=$(cli_check zcode)
HAS_ORCA=$(cli_check orca)
HAS_CODEX=$(cli_check codex)

# --- Skill roots ---
SKILL_ROOTS=()
for d in \
  "$HOME/.grok/skills" \
  "$HOME/.config/opencode/skills" \
  "$HOME/.claude/skills" \
  "$HOME/.zcode/skills" \
  "$PROJECT_DIR/.grok/skills" \
  "$PROJECT_DIR/.claude/skills" \
  "$PROJECT_DIR/.agents/skills"; do
  [[ -d "$d" ]] && SKILL_ROOTS+=("$d")
done

# --- Skill pack markers (names only, capped) ---
SKILL_NAMES=""
for root in "${SKILL_ROOTS[@]+"${SKILL_ROOTS[@]}"}"; do
  while IFS= read -r skill_md; do
    dir=$(dirname "$skill_md")
    base=$(basename "$dir")
    SKILL_NAMES="${SKILL_NAMES}${base},"
  done < <(find "$root" -maxdepth 2 -name 'SKILL.md' 2>/dev/null | head -80)
done
SKILL_NAMES="${SKILL_NAMES%,}"

# --- MCP config hints ---
MCP_HINTS=""
for f in \
  "$HOME/.grok/config.toml" \
  "$HOME/.config/opencode/opencode.json" \
  "$HOME/.claude/settings.json" \
  "$PROJECT_DIR/.claude/settings.json" \
  "$PROJECT_DIR/.mcp.json"; do
  if [[ -f "$f" ]]; then
    MCP_HINTS="${MCP_HINTS}$(json_escape "$f"),"
  fi
done
MCP_HINTS="${MCP_HINTS%,}"

# --- Project markers ---
HAS_AGENTS=false; [[ -f "$PROJECT_DIR/AGENTS.md" ]] && HAS_AGENTS=true
HAS_SPEC=false; [[ -f "$PROJECT_DIR/SPEC.md" ]] && HAS_SPEC=true
HAS_STATUS=false; [[ -f "$PROJECT_DIR/STATUS.md" ]] && HAS_STATUS=true
HAS_WAVES=false; [[ -d "$PROJECT_DIR/waves" ]] && HAS_WAVES=true
HAS_DISPATCH=false; [[ -d "$PROJECT_DIR/prompts/_dispatch" ]] && HAS_DISPATCH=true
HAS_MEMORY=false; [[ -f "$PROJECT_DIR/.agents/memory/MEMORY.md" ]] && HAS_MEMORY=true

# Build skills_roots JSON array
ROOTS_JSON="["
first=1
for r in "${SKILL_ROOTS[@]+"${SKILL_ROOTS[@]}"}"; do
  if [[ $first -eq 1 ]]; then first=0; else ROOTS_JSON+=","; fi
  ROOTS_JSON+="\"$(json_escape "$r")\""
done
ROOTS_JSON+="]"

# Skills names array
NAMES_JSON="["
first=1
IFS=',' read -ra _names <<< "${SKILL_NAMES}"
for n in "${_names[@]}"; do
  [[ -z "$n" ]] && continue
  if [[ $first -eq 1 ]]; then first=0; else NAMES_JSON+=","; fi
  NAMES_JSON+="\"$(json_escape "$n")\""
done
NAMES_JSON+="]"

# MCP files array
MCP_JSON="["
first=1
IFS=',' read -ra _mcps <<< "${MCP_HINTS}"
for m in "${_mcps[@]}"; do
  [[ -z "$m" ]] && continue
  if [[ $first -eq 1 ]]; then first=0; else MCP_JSON+=","; fi
  MCP_JSON+="\"$m\""
done
MCP_JSON+="]"

cat <<EOF
{
  "project_dir": "$(json_escape "$PROJECT_DIR")",
  "clis": {
    "grok": $HAS_GROK,
    "opencode": $HAS_OPENCODE,
    "claude": $HAS_CLAUDE,
    "zcode": $HAS_ZCODE,
    "orca": $HAS_ORCA,
    "codex": $HAS_CODEX
  },
  "skills_roots": $ROOTS_JSON,
  "skill_names_sample": $NAMES_JSON,
  "mcp_config_paths": $MCP_JSON,
  "project_markers": {
    "AGENTS.md": $HAS_AGENTS,
    "SPEC.md": $HAS_SPEC,
    "STATUS.md": $HAS_STATUS,
    "waves/": $HAS_WAVES,
    "prompts/_dispatch/": $HAS_DISPATCH,
    ".agents/memory/MEMORY.md": $HAS_MEMORY
  }
}
EOF
