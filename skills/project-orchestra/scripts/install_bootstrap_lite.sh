#!/usr/bin/env bash
# install_bootstrap_lite.sh — exactly 4 agent-home files (no waves/SPEC/prompts)
# Usage: bash install_bootstrap_lite.sh <project_dir> [project_name]

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 1 ]]; then
  cat <<'EOF'
install_bootstrap_lite.sh — minimal agent home (exactly 4 files)

Usage: bash install_bootstrap_lite.sh <project_dir> [project_name]

Creates ONLY:
  AGENTS.md
  SESSION_HANDOFF.md
  .agents/memory/MEMORY.md
  .gitignore

Does NOT create SPEC, waves/, prompts/, audits/, STATUS.
Upgrade later with install_project_os.sh (full) or skill modes full/extend.

Environment:
  FORCE=1     overwrite existing files
  SKILL_DIR   override skill root
EOF
  [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && exit 0
  exit 1
fi

mkdir -p "$1"
PROJECT_DIR="$(cd "$1" && pwd)"
PROJECT_NAME="${2:-$(basename "$PROJECT_DIR")}"
DATE="$(date +%Y-%m-%d 2>/dev/null || echo unknown)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="${SKILL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
T="$SKILL_DIR/assets/templates"
FORCE="${FORCE:-0}"

sed_escape() { printf '%s' "$1" | sed 's/[&/\]/\\&/g'; }
PN_ESC="$(sed_escape "$PROJECT_NAME")"
DATE_ESC="$(sed_escape "$DATE")"

copy_file() {
  local src="$1"
  local dest="$2"
  if [[ -f "$dest" && "$FORCE" != "1" ]]; then
    echo "SKIP exists: $dest"
    return 0
  fi
  if [[ ! -f "$src" ]]; then
    echo "FAIL: missing template: $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dest")"
  sed -e "s/\${PROJECT_NAME}/${PN_ESC}/g" \
      -e "s/\${DATE}/${DATE_ESC}/g" \
      -e "s/\${PROJECT_DIR}/${PN_ESC}/g" \
      -e "s/\${PROJECT_DESCRIPTION}/Minimal agent home (bootstrap-lite)/g" \
      -e "s/\${CURRENT_FOCUS}/Bootstrap-lite installed — define first task/g" \
      -e "s/\${NEXT_ACTION}/Set CURRENT_FOCUS and first work item/g" \
      -e "s/\${ENV_NOTES}/bootstrap-lite via project-orchestra/g" \
      "$src" > "$dest"
  echo "WRITE: $dest"
}

echo "=== install_bootstrap_lite → $PROJECT_DIR (name=$PROJECT_NAME) ==="
mkdir -p "$PROJECT_DIR/.agents/memory"

copy_file "$T/AGENTS.md.tmpl" "$PROJECT_DIR/AGENTS.md"
copy_file "$T/SESSION_HANDOFF.md.tmpl" "$PROJECT_DIR/SESSION_HANDOFF.md"
copy_file "$T/MEMORY.md.tmpl" "$PROJECT_DIR/.agents/memory/MEMORY.md"
copy_file "$T/gitignore.tmpl" "$PROJECT_DIR/.gitignore"

echo ""
echo "OK bootstrap-lite: exactly 4 files in $PROJECT_DIR"
echo "  AGENTS.md, SESSION_HANDOFF.md, .agents/memory/MEMORY.md, .gitignore"
echo "Do NOT add SPEC/waves/prompts unless user upgrades (full / install_project_os.sh)."
exit 0
