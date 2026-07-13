#!/usr/bin/env bash
# install_project_os.sh — materialize multi-agent OS templates into a project
# Usage: bash install_project_os.sh <project_dir> [project_name]
# Does not overwrite existing files unless FORCE=1.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 1 ]]; then
  cat <<'EOF'
install_project_os.sh — copy kit templates into target project

Usage: bash install_project_os.sh <project_dir> [project_name]

Environment:
  FORCE=1     overwrite existing files
  SKILL_DIR   override skill root (default: parent of scripts/)

Creates AGENTS/SPEC/STATUS/MEMORY/waves/_template/prompts/_dispatch/docs/audits.
Does not invent domain content — placeholders remain for agent fill-in where needed.
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

# Escape sed replacement specials in project name
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
  mkdir -p "$(dirname "$dest")"
  sed -e "s/\${PROJECT_NAME}/${PN_ESC}/g" \
      -e "s/\${DATE}/${DATE_ESC}/g" \
      -e "s/\${PROJECT_DIR}/${PN_ESC}/g" \
      -e "s/\${PROJECT_DESCRIPTION}/Multi-agent program OS/g" \
      "$src" > "$dest"
  echo "WRITE: $dest"
}

echo "=== install_project_os → $PROJECT_DIR (name=$PROJECT_NAME) ==="
mkdir -p "$PROJECT_DIR"/{.agents/memory,waves/_template,prompts/_dispatch,audits,docs,research}

copy_file "$T/AGENTS.md.tmpl" "$PROJECT_DIR/AGENTS.md"
copy_file "$T/SPEC.md.tmpl" "$PROJECT_DIR/SPEC.md"
copy_file "$T/INTENT.md.tmpl" "$PROJECT_DIR/INTENT.md"
copy_file "$T/STATUS.md.tmpl" "$PROJECT_DIR/STATUS.md"
copy_file "$T/plan.md.tmpl" "$PROJECT_DIR/plan.md"
copy_file "$T/SESSION_HANDOFF.md.tmpl" "$PROJECT_DIR/SESSION_HANDOFF.md"
copy_file "$T/MEMORY.md.tmpl" "$PROJECT_DIR/.agents/memory/MEMORY.md"
copy_file "$T/gitignore.tmpl" "$PROJECT_DIR/.gitignore"
copy_file "$T/CLAUDE.md.tmpl" "$PROJECT_DIR/CLAUDE.md"
copy_file "$T/waves/README.md.tmpl" "$PROJECT_DIR/waves/README.md"
copy_file "$T/waves/_template/REVIEW-STAMP.md.tmpl" "$PROJECT_DIR/waves/_template/REVIEW-STAMP.md"
copy_file "$T/waves/_template/EXEC-REPORT.md.tmpl" "$PROJECT_DIR/waves/_template/EXEC-REPORT.md"
copy_file "$T/waves/_template/STATUS.md.tmpl" "$PROJECT_DIR/waves/_template/STATUS.md"
copy_file "$T/docs/access-map.md.tmpl" "$PROJECT_DIR/docs/access-map.md"
copy_file "$T/docs/cross-project-map.md.tmpl" "$PROJECT_DIR/docs/cross-project-map.md"
copy_file "$T/audits/README.md.tmpl" "$PROJECT_DIR/audits/README.md"

for c in README executor-cheatsheet orchestrator-cheatsheet auditor-cheatsheet flash-cheatsheet; do
  copy_file "$T/prompts/_dispatch/${c}.md.tmpl" "$PROJECT_DIR/prompts/_dispatch/${c}.md"
done

echo ""
echo "Next: fill role placeholders in AGENTS.md/SPEC.md, then run:"
echo "  bash $SKILL_DIR/scripts/verify_os_gate.sh $PROJECT_DIR"
echo "  bash $SKILL_DIR/scripts/verify_handoff_gate.sh $PROJECT_DIR"
exit 0
