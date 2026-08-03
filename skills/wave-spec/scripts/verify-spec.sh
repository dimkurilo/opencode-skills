#!/usr/bin/env bash
# verify-spec.sh — portable wave-spec SPEC/PLAN required-sections validator.
#
# Usage:
#   bash skills/wave-spec/scripts/verify-spec.sh <wave-dir>
#   bash skills/wave-spec/scripts/verify-spec.sh <spec-or-plan-file>
#
# What it checks (required-sections contract, 2026-08 format triage):
#   SPEC (.md or .xml): required sections Goal, Done_when, Verifier, Scope, Risks.
#   PLAN (.md or .xml): file exists + at least one task element + a done_when.
#
# Format detection:
#   .xml extension  → XML mode  (tags <goal>, <done_when>, …; case-insensitive).
#   .md  extension  → MD mode   (## Goal, ## Done_when, …; case-insensitive; colon-tolerant: "## Goal: …").
#   other extension → content sniff (first non-empty line starting with '<' → XML; else MD).
#
# Dir mode:
#   Requires ≥1 SPEC file (case-insensitive prefix match: SPEC*.md / SPEC*.xml / spec*.md / spec*.xml,
#   including suffixed names like spec-md-sample.md, SPEC-v2.xml). PLAN files are validated if present.
#   No SPEC found in dir → exit 1 ("SPEC not found in <dir>"). Single-file mode is unchanged.
#
# Exit codes:
#   0 — PASS (all required sections present in every SPEC/PLAN found).
#   1 — FAIL (one or more required sections missing; OR dir-mode directory has no SPEC file).
#   2 — usage / IO error (target not found, no SPEC/PLAN in single-file sniff, unknown format).
#
# Dependencies: bash 3.x+ and grep + find. Portable across macOS (BSD grep/find) and Linux.
# No awk/sed/perl/python required. No vv-opencode runtime.
#
# Known limitations (grep-heuristic trade-offs; do not block closeout on real waves):
#   - Table-only MD plans (rows like "| T01 | ... |") are not detected as tasks — use checkboxes or <task>.
#   - XML tags inside comments <!-- <goal>… --> are still counted (acceptable for the heuristic).
#   - <tasks> wrapper with <step> children but no <task> element → FAIL (use explicit <task>).

set -uo pipefail

# Required SPEC sections (lowercase; matched case-insensitively).
SPEC_REQUIRED="goal done_when verifier scope risks"

# ---------------------------------------------------------------------------
# Format detection
# ---------------------------------------------------------------------------
detect_format() {
  local f="$1"
  local ext
  ext="${f##*.}"
  case "$ext" in
    xml) echo "xml" ;;
    md)  echo "md"  ;;
    *)
      local first
      first=$(grep -m1 -vE '^[[:space:]]*$' "$f" 2>/dev/null || true)
      case "$first" in
        '<'*) echo "xml" ;;
        *)    echo "md"  ;;
      esac
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Section checkers — print missing names, one per line (empty output = all OK)
# ---------------------------------------------------------------------------
check_md_sections() {
  local f="$1"; shift
  local sec
  for sec in "$@"; do
    # Heading ## through ######, case-insensitive.
    # After the section name accept whitespace, colon ("## Goal: ship MVP"), or EOL — but NOT a
    # letter (so "## Goals" plural still correctly fails).
    # Note: explicit alternation `([[:space:]]|:|$)` instead of `[[:space]:]` — BSD grep on macOS
    # mis-parses the bracket form as a malformed POSIX class ("invalid character class").
    if ! grep -qiE "^#{2,6}[[:space:]]+${sec}([[:space:]]|:|\$)" "$f"; then
      echo "$sec"
    fi
  done
}

check_xml_sections() {
  local f="$1"; shift
  local sec
  for sec in "$@"; do
    # Opening tag <sec>, <sec attr="...">, <sec/> or <sec> — case-insensitive.
    if ! grep -qiE "<${sec}([[:space:]>/])" "$f"; then
      echo "$sec"
    fi
  done
}

# ---------------------------------------------------------------------------
# Task presence heuristics (used by PLAN validation)
# ---------------------------------------------------------------------------
has_md_task() {
  local f="$1"
  # Checkbox task list ("- [ ]", "- [x]") OR heading like "## T01", "### Task …".
  grep -qiE '^[[:space:]]*[-*][[:space:]]+\[[:x: ]?\]' "$f" && return 0
  grep -qiE '^#{2,6}[[:space:]]+(task[[:space:]]|t[0-9])' "$f" && return 0
  return 1
}

has_xml_task() {
  local f="$1"
  grep -qiE "<task([[:space:]>/])" "$f"
}

# ---------------------------------------------------------------------------
# Validators — echo PASS/FAIL, return 0 on PASS / 1 on FAIL
# ---------------------------------------------------------------------------
validate_spec() {
  local f="$1"
  local fmt
  fmt=$(detect_format "$f")
  local missing=""
  case "$fmt" in
    xml) missing=$(check_xml_sections "$f" $SPEC_REQUIRED) ;;
    md)  missing=$(check_md_sections  "$f" $SPEC_REQUIRED) ;;
    *)
    echo "FAIL: SPEC $f — unknown format ('$fmt')" >&2
    return 1
    ;;
  esac
  if [[ -z "$missing" ]]; then
    echo "PASS: SPEC $f ($fmt) — all required sections present"
    return 0
  fi
  echo "FAIL: SPEC $f ($fmt) — missing sections: $(echo "$missing" | tr '\n' ' ')" >&2
  return 1
}

validate_plan() {
  local f="$1"
  local fmt
  fmt=$(detect_format "$f")
  local errs=""
  local task_present=""
  case "$fmt" in
    xml)
      if has_xml_task "$f"; then task_present="1"; fi
      if [[ -n "$(check_xml_sections "$f" done_when)" ]]; then
        errs="${errs}missing <done_when>; "
      fi
      ;;
    md)
      if has_md_task "$f"; then task_present="1"; fi
      if [[ -n "$(check_md_sections "$f" done_when)" ]]; then
        errs="${errs}missing ## Done_when; "
      fi
      ;;
    *)
      echo "FAIL: PLAN $f — unknown format ('$fmt')" >&2
      return 1
      ;;
  esac
  if [[ -z "$task_present" ]]; then
    errs="${errs}no task element found; "
  fi
  if [[ -z "$errs" ]]; then
    echo "PASS: PLAN $f ($fmt) — has task + done_when"
    return 0
  fi
  echo "FAIL: PLAN $f ($fmt) — ${errs}" >&2
  return 1
}

# ---------------------------------------------------------------------------
# Collect candidates from a directory (case-insensitive prefix match).
#   Echoes one path per line, sorted+de-duped. Empty output = no matches.
#   Uses `find -iname` for bash 3.2/macOS portability and case-insensitive
#   prefix matching (SPEC.md / spec*.md / SPEC-v2.xml / PLAN-[TICKET].md …).
# ---------------------------------------------------------------------------
collect_by_prefix() {
  local target="$1" prefix="$2"
  find "$target" -maxdepth 1 -type f -iname "${prefix}*" \( -name '*.md' -o -name '*.xml' \) 2>/dev/null | sort -u
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <wave-dir|spec-file|plan-file>" >&2
    exit 2
  fi

  local target="$1"
  local rc=0

  if [[ -d "$target" ]]; then
    # Directory mode: discover SPEC + PLAN candidates via case-insensitive prefix match.
    # SPEC*.md / SPEC*.xml / spec*.md / spec*.xml (and suffixed names like spec-md-sample.md,
    # SPEC-v2.xml) are all matched. Same for PLAN*.
    local specs=() plans=() line
    while IFS= read -r line; do
      [[ -n "$line" ]] && specs+=("$line")
    done < <(collect_by_prefix "$target" spec)
    while IFS= read -r line; do
      [[ -n "$line" ]] && plans+=("$line")
    done < <(collect_by_prefix "$target" plan)

    # Dir mode requires ≥1 SPEC file. Missing SPEC = FAIL even if PLAN exists
    # (closeout semantics: SPEC/PLAN are the contract; PLAN-only wave is incomplete).
    if [[ ${#specs[@]} -eq 0 ]]; then
      echo "FAIL: SPEC not found in $target (dir-mode requires ≥1 SPEC.{md,xml})" >&2
      exit 1
    fi
    for f in "${specs[@]}"; do validate_spec "$f" || rc=1; done
    if [[ ${#plans[@]} -gt 0 ]]; then
      for f in "${plans[@]}"; do validate_plan "$f" || rc=1; done
    fi
  elif [[ -f "$target" ]]; then
    # Single-file mode: infer SPEC vs PLAN by filename, then by content.
    local base
    base=$(basename "$target" | tr '[:upper:]' '[:lower:]')
    case "$base" in
      spec*)  validate_spec  "$target" || rc=1 ;;
      plan*)  validate_plan  "$target" || rc=1 ;;
      *)
        # Content sniff: SPEC has goal/scope; PLAN has task. Same colon-tolerance as check_md_sections.
        if grep -qiE "(<goal|<scope)|^#{2,6}[[:space:]]+(goal|scope)([[:space:]]|:|\$)" "$target"; then
          validate_spec "$target" || rc=1
        elif grep -qiE "(<task|^#{2,6}[[:space:]]+(task[[:space:]]|t[0-9]))" "$target"; then
          validate_plan "$target" || rc=1
        else
          echo "ERROR: cannot determine SPEC vs PLAN for $target" >&2
          exit 2
        fi
        ;;
    esac
  else
    echo "ERROR: target not found: $target" >&2
    exit 2
  fi

  exit $rc
}

main "$@"
