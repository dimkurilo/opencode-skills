#!/usr/bin/env bash
# install_workstream.sh — create a monorepo workstream under a parent program root
# Usage: bash install_workstream.sh <parent_dir> <slug>
# Does not overwrite existing files unless FORCE=1.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -lt 2 ]]; then
  cat <<'EOF'
install_workstream.sh — scaffold a workstream under a parent project

Usage: bash install_workstream.sh <parent_dir> <slug>

Environment:
  FORCE=1              overwrite existing files
  SKILL_DIR            override skill root (default: parent of scripts/)
  ALLOW_NO_PARENT=1    allow workstream when parent has no AGENTS.md (default: refuse)

Creates:
  <parent>/<slug>/STATUS.md
  <parent>/<slug>/README.md
  <parent>/<slug>/INTENT.md
  <parent>/<slug>/waves/_template/  (REVIEW-STAMP, EXEC-REPORT, STATUS, PLAN.md.tmpl, SPEC.md.tmpl)

Does NOT create a second SESSION_HANDOFF or MEMORY (parent owns those).
Does NOT run full OS install — use install_project_os.sh (or bootstrap-lite) on parent first.
Live waves need SPEC+PLAN materialised under waves/<date-slug>/ then verify_wave_ready.sh.
EOF
  [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && exit 0
  exit 1
fi

PARENT_RAW="$1"
SLUG="$2"

# slug: kebab-case-ish
if [[ ! "$SLUG" =~ ^[a-zA-Z][a-zA-Z0-9._-]*$ ]]; then
  echo "FAIL: slug must start with a letter and contain only [A-Za-z0-9._-]: $SLUG" >&2
  exit 1
fi

mkdir -p "$PARENT_RAW"
PARENT_DIR="$(cd "$PARENT_RAW" && pwd)"
WS_DIR="$PARENT_DIR/$SLUG"
DATE="$(date +%Y-%m-%d 2>/dev/null || echo unknown)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="${SKILL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
T="$SKILL_DIR/assets/templates"
FORCE="${FORCE:-0}"
ALLOW_NO_PARENT="${ALLOW_NO_PARENT:-0}"

PROJECT_NAME="$(basename "$PARENT_DIR")"

# Parent should already be a program OS (or at least bootstrap-lite)
if [[ ! -f "$PARENT_DIR/AGENTS.md" ]]; then
  echo "WARN: parent has no AGENTS.md — $PARENT_DIR is not a program OS / bootstrap-lite home." >&2
  echo "WARN: workstream expects one parent HANDOFF/MEMORY; session diet will not work well." >&2
  echo "HINT: run install_bootstrap_lite.sh or install_project_os.sh on parent first." >&2
  if [[ "$ALLOW_NO_PARENT" != "1" ]]; then
    echo "FAIL: refuse workstream under non-OS parent (set ALLOW_NO_PARENT=1 to override)." >&2
    exit 2
  fi
  echo "WARN: ALLOW_NO_PARENT=1 — continuing without parent OS." >&2
fi

sed_escape() { printf '%s' "$1" | sed 's/[&/\]/\\&/g'; }

PN_ESC="$(sed_escape "$PROJECT_NAME")"
DATE_ESC="$(sed_escape "$DATE")"
SLUG_ESC="$(sed_escape "$SLUG")"

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
      -e "s/\${WORKSTREAM_SLUG}/${SLUG_ESC}/g" \
      -e "s/\${WAVE_ID}/${SLUG_ESC}/g" \
      -e "s/\${PARENT_OR_WS}/${SLUG_ESC}/g" \
      -e "s/\${CURRENT_FOCUS}/Workstream ${SLUG_ESC} boot/g" \
      -e "s/\${LAST_WAVE}/none/g" \
      -e "s/\${OPEN_1}/Define first wave INTENT/g" \
      -e "s/\${BLOCKERS}/none/g" \
      -e "s/\${WORKSTREAM_PURPOSE}/Theme workstream under parent program/g" \
      -e "s/\${OWNER}/orchestrator/g" \
      -e "s/\${THEME}/TODO: one-paragraph theme/g" \
      -e "s/\${SUCCESS}/TODO: success criteria/g" \
      -e "s/\${NON_GOALS}/TODO: non-goals/g" \
      -e "s/\${PARENT_SPEC_PATH}/..\/SPEC.md/g" \
      -e "s/\${GOAL}/TODO: wave goal/g" \
      -e "s/\${STEP_1}/Draft SPEC+PLAN/g" \
      -e "s/\${OWNER_1}/drafter/g" \
      -e "s/\${OUT_1}/SPEC.md PLAN.md/g" \
      -e "s/\${DONE_1}/human approved/g" \
      -e "s/\${STEP_2}/Stamp review/g" \
      -e "s/\${OWNER_2}/reviewer/g" \
      -e "s/\${OUT_2}/REVIEW-STAMP.md/g" \
      -e "s/\${DONE_2}/AGREED YES + hash/g" \
      -e "s/\${OUT_OF_SCOPE}/TBD/g" \
      -e "s/\${RISK}/scope creep/g" \
      -e "s/\${MITIGATION}/write locks + stamp/g" \
      -e "s/\${EXECUTOR}/executor/g" \
      "$src" > "$dest"
  echo "WRITE: $dest"
}

echo "=== install_workstream → $WS_DIR (parent=$PROJECT_NAME slug=$SLUG) ==="
mkdir -p "$WS_DIR/waves/_template"

copy_file "$T/workstream/STATUS.md.tmpl" "$WS_DIR/STATUS.md"
copy_file "$T/workstream/README.md.tmpl" "$WS_DIR/README.md"
copy_file "$T/workstream/INTENT.md.tmpl" "$WS_DIR/INTENT.md"

# Wave templates (shared with parent OS) — enough for verify_raeh_ready on the workstream root
copy_file "$T/waves/README.md.tmpl" "$WS_DIR/waves/README.md"
copy_file "$T/waves/_template/REVIEW-STAMP.md.tmpl" "$WS_DIR/waves/_template/REVIEW-STAMP.md"
copy_file "$T/waves/_template/EXEC-REPORT.md.tmpl" "$WS_DIR/waves/_template/EXEC-REPORT.md"
copy_file "$T/waves/_template/STATUS.md.tmpl" "$WS_DIR/waves/_template/STATUS.md"
# Keep SPEC/PLAN as *.tmpl under _template (sources). Materialise only into live wave dirs.
copy_file "$T/waves/_template/PLAN.md.tmpl" "$WS_DIR/waves/_template/PLAN.md.tmpl"
copy_file "$T/waves/SPEC.md.tmpl" "$WS_DIR/waves/_template/SPEC.md.tmpl"

echo ""
echo "OK workstream ready: $WS_DIR"
echo "Next:"
echo "  - Fill INTENT.md / STATUS.md"
echo "  - /project-orchestra mode wave  (peer wave-spec if installed, else templates)"
echo "  - Copy waves/_template/{SPEC,PLAN}.md.tmpl → waves/<date-slug>/{SPEC,PLAN}.md then:"
echo "      bash \$SKILL_DIR/scripts/verify_wave_ready.sh <wave_dir>"
echo "  - Parent keeps single SESSION_HANDOFF.md + MEMORY.md"
exit 0
