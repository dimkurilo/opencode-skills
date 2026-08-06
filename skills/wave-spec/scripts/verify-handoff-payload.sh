#!/usr/bin/env bash
# verify-handoff-payload.sh — wave-spec Handoff-payload validator (CAS-169).
#
# Usage:
#   bash skills/wave-spec/scripts/verify-handoff-payload.sh --handoff <file>
#
# Extracts the FIRST `## Handoff` block in the file (from the `## Handoff` line
# to EOF or the next `## ` top-level heading, whichever comes first) and checks:
#   - 6 canonical headings present (### Changed files / ### Delivered behavior /
#     ### Validation / ### Task-owned failure state / ### Assumptions /
#     ### Residual risk)
#   - Required labels in Validation:     command: , observed:
#   - Task-owned failure state is MODE-AWARE (both formats valid) [CAS-169 F1]:
#       * scalar — 4 line-start labels (fingerprint: / hypothesis: / count: /
#         reset_reason:) under ### Task-owned failure state. Single-task worker
#         handoffs.
#       * table  — a Markdown table whose header row has columns
#         task | fingerprint | hypothesis | count | reset_reason, followed by a
#         separator row (---) and ≥1 data row. Multi-task iteration handoffs.
#   - Semantic value validation [CAS-169 M2]: count must be a non-negative
#     integer; reset_reason must be one of the 8 canonical transition values
#     (CAS-167/168), a non_counting:<category> where <category> is one of the
#     8 closed-list CAS-168 categories, or a sentinel (not_applicable / none /
#     —). Invalid values (incl. non_counting:<unknown>) → exit 4.
#   - Table-mode row contract [CAS-169 M1]: each data row must have exactly 5
#     content fields (task|fingerprint|hypothesis|count|reset_reason) and a
#     non-empty task id (first content field). Empty task id or wrong field
#     count → exit 4. Trailing `|` after reset_reason is OPTIONAL (both
#     `... | reset_reason |` and `... | reset_reason` are valid Markdown).
#   - Payload ≤ 1500 UTF-8 characters (counted via `wc -m` with explicit UTF-8
#     locale; Python len() fallback if no UTF-8 locale available).
#
# Exit codes:
#   0 — PASS (form + length + semantic values valid)
#   1 — usage / IO error (no --handoff flag, file missing/unreadable)
#   2 — locale unavailable (no UTF-8 locale for wc -m AND python3 missing)
#   3 — handoff too long (> 1500 payload chars)
#   4 — form issues (required headings/labels absent OR invalid semantic values)
#   5 — both (too long AND form issues)
#
# On exit 3/4/5 the script prints: path, measured N/1500, and the list of
# violations (missing section/label names and/or invalid values).
#
# Dependencies: bash 3.x+, grep, awk, sed, wc, python3 (fallback).
# Portable across macOS (BSD grep/awk/wc) and Linux. No vv-opencode runtime.
#
# Scope: this script ONLY validates the handoff payload. It does NOT replace
# verify-handoff-gate.sh (project-bootstrap destination gate, unchanged — still
# 4/4 PASS) and does NOT replace verify-spec.sh (SPEC/PLAN required-sections).
# Truthfulness of `command:`/`observed:` evidence is NOT checked here — that
# stays with the coordinator / lifecycle gates.

set -uo pipefail

LIMIT=1500

# 8 canonical reset_reason transition values (CAS-167/168) + sentinels.
# non_counting:<category> is restricted to the closed list of 8 CAS-168
# categories (user_cancellation | tool_interruption | timeout |
# service_unavailable | browser_transport | dependency_environment |
# pre_existing_unrelated | outside_package_ownership). Unknown categories
# (e.g. non_counting:made_up) are rejected here, not deferred canon-side.
# Sentinels: not_applicable / none (handoff) / — (ledger, matched separately
# in validate_reset since em-dash is a multi-byte literal).
RESET_RE='^(pass|fingerprint_changed|package/command_changed|implementation_changed|hypothesis_changed|scope_changed|same_fingerprint_retry|non_counting:(user_cancellation|tool_interruption|timeout|service_unavailable|browser_transport|dependency_environment|pre_existing_unrelated|outside_package_ownership)|not_applicable|none)$'

# ---------------------------------------------------------------------------
# arg parse
# ---------------------------------------------------------------------------
FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --handoff)
      shift
      if [[ $# -eq 0 ]]; then
        echo "Usage: $0 --handoff <file>" >&2
        exit 1
      fi
      FILE="$1"
      shift
      ;;
    -h|--help)
      sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: $0 --handoff <file>" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 --handoff <file>" >&2
  exit 1
fi

if [[ ! -r "$FILE" ]]; then
  echo "FAIL: cannot read file: $FILE" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# extract first ## Handoff block
#   from line "^## Handoff(<space>|EOL)" to next "^## " (exclusive) or EOF.
#   awk for portability across BSD awk / GNU gawk.
# ---------------------------------------------------------------------------
PAYLOAD=""
PAYLOAD=$(awk '
  /^## Handoff([[:space:]]|$)/ { in_block=1; print; next }
  in_block && /^## / { exit }
  in_block { print }
' "$FILE")

if [[ -z "$PAYLOAD" ]]; then
  echo "FAIL: $FILE — no '## Handoff' block found" >&2
  exit 4
fi

# ---------------------------------------------------------------------------
# UTF-8 locale preflight — pick the first available UTF-8 locale.
# M3 (CAS-169): portable fallback recognizes *.UTF-8, *.utf8, C.UTF-8, and the
# Darwin bare alias "UTF-8" (no dot — Darwin lists the encoding alone).
# ---------------------------------------------------------------------------
UTF8_LOCALE=""
if command -v locale >/dev/null 2>&1; then
  if locale -a 2>/dev/null | grep -qx "en_US.UTF-8"; then
    UTF8_LOCALE="en_US.UTF-8"
  elif locale -a 2>/dev/null | grep -qx "C.UTF-8"; then
    UTF8_LOCALE="C.UTF-8"
  else
    # Portable fallback: any locale whose encoding suffix is UTF-8 / utf8.
    # Matches en_US.UTF-8, en_US.utf8, C.UTF-8, and bare "UTF-8" (Darwin alias).
    UTF8_LOCALE=$(locale -a 2>/dev/null | grep -iE '(^|[._-])(UTF-8|utf8)$' | head -1)
  fi
fi

# ---------------------------------------------------------------------------
# character count (UTF-8 code points, NOT bytes)
# ---------------------------------------------------------------------------
CHAR_COUNT=""
if [[ -n "$UTF8_LOCALE" ]]; then
  CHAR_COUNT=$(printf '%s' "$PAYLOAD" | LC_ALL="$UTF8_LOCALE" wc -m | tr -d '[:space:]')
elif command -v python3 >/dev/null 2>&1; then
  CHAR_COUNT=$(printf '%s' "$PAYLOAD" | python3 -c 'import sys; print(len(sys.stdin.read()))')
else
  echo "FAIL: no UTF-8 locale available for wc -m and python3 not found" >&2
  exit 2
fi

# Defensive: if the count is empty or non-numeric, treat as locale failure.
if ! [[ "$CHAR_COUNT" =~ ^[0-9]+$ ]]; then
  echo "FAIL: character count not numeric ('$CHAR_COUNT') — locale/python issue" >&2
  exit 2
fi

TOO_LONG=0
if [[ "$CHAR_COUNT" -gt "$LIMIT" ]]; then
  TOO_LONG=1
fi

# ---------------------------------------------------------------------------
# section / label checks (mode-aware) + semantic value validation
#
# Headings: anchored to start of line (optional leading whitespace), followed
#   by whitespace or EOL — so "### Changed files backup" does NOT satisfy
#   "### Changed files".
# Validation labels (command:/observed:): line-start anchored against payload.
# Task-owned failure state: MODE-AWARE [F1] — scalar (4 line-start labels) OR
#   table (header + separator + ≥1 data row). Mode is detected only if the
#   ### Task-owned failure state heading is present.
# Semantic [M2]: count non-negative integer; reset_reason in canonical 8 /
#   non_counting:<cat> / sentinels. Checked per scalar value or per table row.
# ---------------------------------------------------------------------------
MISSING=""
INVALID_VALUES=""

check_heading() {
  local h="$1"
  # Escape nothing — headings contain only #, letters, spaces. # is literal in ERE.
  if ! grep -qE "^[[:space:]]*${h}([[:space:]]|\$)" <<<"$PAYLOAD"; then
    MISSING="${MISSING}${h}; "
  fi
}

check_label() {
  local l="$1"
  if ! grep -qE "^[[:space:]]*${l}" <<<"$PAYLOAD"; then
    MISSING="${MISSING}${l}; "
  fi
}

check_heading "### Changed files"
check_heading "### Delivered behavior"
check_heading "### Validation"
check_heading "### Task-owned failure state"
check_heading "### Assumptions"
check_heading "### Residual risk"

check_label "command:"
check_label "observed:"

# --- Task-owned failure state: mode-aware detection [F1] ---
# Only run if the heading is present (otherwise the heading check already
# reported it and we avoid a duplicate diagnostic).
FAILURE_MODE=""   # scalar | table | ""
TASK_SECTION=""
TABLE_DATA_ROWS=""
if grep -qE '^[[:space:]]*### Task-owned failure state([[:space:]]|$)' <<<"$PAYLOAD"; then
  TASK_SECTION=$(awk '
    /^### Task-owned failure state([[:space:]]|$)/ { ts=1; print; next }
    ts && /^### / { exit }
    ts { print }
  ' <<<"$PAYLOAD")

  SCALAR_OK=1
  for l in "fingerprint:" "hypothesis:" "count:" "reset_reason:"; do
    if ! grep -qE "^[[:space:]]*${l}" <<<"$TASK_SECTION"; then
      SCALAR_OK=0
      break
    fi
  done

  TABLE_HEADER_OK=0
  # Header pattern: leading `|` required, trailing `|` after reset_reason is
  # OPTIONAL (Markdown permits both forms). The 5 column names must appear in
  # order, separated by `|` with optional surrounding whitespace.
  if grep -qE '^\|[[:space:]]*task[[:space:]]*\|[[:space:]]*fingerprint[[:space:]]*\|[[:space:]]*hypothesis[[:space:]]*\|[[:space:]]*count[[:space:]]*\|[[:space:]]*reset_reason' <<<"$TASK_SECTION"; then
    TABLE_HEADER_OK=1
    # Data rows = pipe-rows that are NOT the header and NOT the separator.
    TABLE_DATA_ROWS=$(awk '
      /^\|/ {
        if ($0 ~ /task/ && $0 ~ /fingerprint/ && $0 ~ /hypothesis/ && $0 ~ /reset_reason/) next
        if ($0 ~ /^\|[[:space:]:|-]+\|([[:space:]:|-]+\|)*[[:space:]]*$/) next
        print
      }
    ' <<<"$TASK_SECTION")
  fi

  if [[ "$SCALAR_OK" -eq 1 ]]; then
    FAILURE_MODE="scalar"
  elif [[ "$TABLE_HEADER_OK" -eq 1 && -n "$TABLE_DATA_ROWS" ]]; then
    FAILURE_MODE="table"
  else
    if [[ "$TABLE_HEADER_OK" -eq 1 && -z "$TABLE_DATA_ROWS" ]]; then
      MISSING="${MISSING}Task-owned failure state table: header present but no data rows; "
    else
      MISSING="${MISSING}Task-owned failure state (scalar labels fingerprint/hypothesis/count/reset_reason OR table with task/fingerprint/hypothesis/count/reset_reason columns + >=1 data row); "
    fi
  fi
fi

# --- Semantic value validation [M2] ---
validate_count() {
  local v="$1"
  if ! [[ "$v" =~ ^[0-9]+$ ]]; then
    INVALID_VALUES="${INVALID_VALUES}count=${v} (not integer); "
  fi
}

validate_reset() {
  local v="$1"
  # em-dash (—) is the canonical ledger sentinel; accept byte-for-byte.
  if [[ "$v" == "—" ]]; then return; fi
  if ! printf '%s' "$v" | grep -qE "$RESET_RE"; then
    INVALID_VALUES="${INVALID_VALUES}reset_reason=${v} (not in canonical list); "
  fi
}

if [[ "$FAILURE_MODE" == "scalar" ]]; then
  cv=$(grep -E '^[[:space:]]*count:' <<<"$TASK_SECTION" | head -1 | sed 's/^[[:space:]]*count:[[:space:]]*//; s/[[:space:]]*$//')
  rv=$(grep -E '^[[:space:]]*reset_reason:' <<<"$TASK_SECTION" | head -1 | sed 's/^[[:space:]]*reset_reason:[[:space:]]*//; s/[[:space:]]*$//')
  validate_count "$cv"
  validate_reset "$rv"
elif [[ "$FAILURE_MODE" == "table" ]]; then
  # Each data row starts with `|`. awk -F'|' yields: $1="" (pre-leading-pipe),
  # $2=task, $3=fingerprint, $4=hypothesis, $5=count, $6=reset_reason, and $7=""
  # only when a trailing `|` is present (trailing pipe is optional).
  # M1 [CAS-169 fix-round 2]: enforce row contract — exactly 5 content fields
  # AND non-empty task id. Both violations → exit 4.
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    tv=$(printf '%s' "$row" | awk -F'|' '{ gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2 }')
    cv=$(printf '%s' "$row" | awk -F'|' '{ gsub(/^[[:space:]]+|[[:space:]]+$/, "", $5); print $5 }')
    rv=$(printf '%s' "$row" | awk -F'|' '{ gsub(/^[[:space:]]+|[[:space:]]+$/, "", $6); print $6 }')
    # Field-count check: strip one leading `|` and one trailing `|` (optional),
    # then count `|`-delimited fields. Exactly 5 content fields required.
    stripped=$(printf '%s' "$row" | sed 's/^[[:space:]]*|//; s/|[[:space:]]*$//')
    field_count=$(printf '%s' "$stripped" | awk -F'|' '{ print NF }')
    if [[ "$field_count" -ne 5 ]]; then
      INVALID_VALUES="${INVALID_VALUES}table row field count=${field_count} (expected 5: task|fingerprint|hypothesis|count|reset_reason); "
    fi
    # Empty task id (first content field after trim) → violation.
    if [[ -z "$tv" ]]; then
      INVALID_VALUES="${INVALID_VALUES}empty task id in table row; "
    fi
    validate_count "$cv"
    validate_reset "$rv"
  done <<<"$TABLE_DATA_ROWS"
fi

SECTIONS_MISSING=0
[[ -n "$MISSING" ]] && SECTIONS_MISSING=1
INVALID=0
[[ -n "$INVALID_VALUES" ]] && INVALID=1

# ---------------------------------------------------------------------------
# report + exit code
#   form issues = missing headings/labels AND/OR invalid semantic values.
#   Exit contract is fixed (0-5); invalid values fold into exit 4 / 5, not a
#   new code.
# ---------------------------------------------------------------------------
FORM_ISSUES=""
[[ -n "$MISSING" ]] && FORM_ISSUES="${MISSING}"
[[ -n "$INVALID_VALUES" ]] && FORM_ISSUES="${FORM_ISSUES}${INVALID_VALUES}"

if [[ "$TOO_LONG" -eq 1 && -n "$FORM_ISSUES" ]]; then
  echo "FAIL: $FILE — payload ${CHAR_COUNT}/${LIMIT} chars (too long) AND form issues: ${FORM_ISSUES}" >&2
  exit 5
elif [[ "$TOO_LONG" -eq 1 ]]; then
  echo "FAIL: $FILE — payload ${CHAR_COUNT}/${LIMIT} chars (too long; limit ${LIMIT})" >&2
  exit 3
elif [[ -n "$FORM_ISSUES" ]]; then
  echo "FAIL: $FILE — payload ${CHAR_COUNT}/${LIMIT} chars; form issues: ${FORM_ISSUES}" >&2
  exit 4
fi

echo "PASS: $FILE — payload ${CHAR_COUNT}/${LIMIT} chars, all required headings/labels present, semantic values valid"
exit 0
