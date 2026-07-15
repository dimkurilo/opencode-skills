# Orca recipes

File-first truth - Orca is **transport only**. Stamp file and reports on disk are authority.

**Author recommendation:** use [Orca](https://onorca.dev) ([github.com/stablyai/orca](https://github.com/stablyai/orca)) when two agents must run side by side (two-model review, multi-CLI workers). Pros/cons and a real model stack: skill README, section *How I actually use this*.

## Dual-worker parallel review (1.1 default for dual-review)

**Goal:** two complementary reviews without dual bare `opencode run` (DB lock).

```bash
# 1) Create two terminals — pin agent + model in the command each worker will use
orca terminal create --worktree active --title po-f04-ledger --command "opencode" --json
orca terminal create --worktree active --title po-stress --command "opencode" --json

# 2) Send role-specific briefs (different jobs — see dispatch-iron.md)
orca terminal send --terminal <handle-f04> --text "$(cat prompts/…/f04-ledger.md)" --enter --json
orca terminal send --terminal <handle-stress> --text "$(cat prompts/…/stress-fail.md)" --enter --json

# 3) Wait / poll for worker_done artifacts on disk (not chat vibes)
# 4) Coordinator reads both paths → identity gate → merge into audits/ or wave STATUS
```

| Worker | Role | Output example |
|--------|------|----------------|
| Terminal A | F-04 ledger | `audits/f04/REVIEW.md` |
| Terminal B | Stress | `audits/stress/FAILURE_MODES.md` |

**Never:**

- Two parallel bare `opencode run` processes sharing the same OpenCode DB  
- Subject / chat line `AGREED` without `REVIEW-STAMP.md` = YES  
- Same prompt to both workers labeled “dual”

If Orca unavailable → sequential single terminals or human dual; mark `DEGRADED_DUAL` if only one family.

## Single wave review dispatch

```bash
orca terminal create --worktree active --title wave-review --command "grok" --json
orca terminal send --terminal <handle> --text "$(cat waves/<id>/prompts/wave-review.md)" --enter --json
```

## Execute after stamp YES

```bash
# Confirm stamp on disk first
grep -E '^AGREED:[[:space:]]*YES' waves/<id>/REVIEW-STAMP.md

orca terminal create --worktree active --title wave-exec --command "opencode" --json
orca terminal send --terminal <handle> --text "$(cat waves/<id>/prompts/execute.md)" --enter --json
```

Executor writes `EXEC-REPORT.md` only — not STATUS/MEMORY/HANDOFF.

## Message types (logical)

| Type | Meaning |
|------|---------|
| task REVIEW | Produce stamp or dual-review artifact |
| task EXECUTE | Run approved PLAN after YES |
| worker_done | Artifact path ready |
| escalation | Blocker needs human / orchestrator |
| decision_gate | Human G0/G1/G-deploy |

## Identity + invalid

Pin agent+model per terminal. Fail identity → invalid archive (`dispatch-iron.md`).
