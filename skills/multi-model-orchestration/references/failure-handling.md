# Failure Handling, Escalation & Self-Correction

## Timeout Policy

| Event | Coordinator action |
|-------|-------------------|
| `check --wait` returns timeout / count:0 | Liveness check: `terminal read`. If active → wait again (rolling 15m windows) |
| Heartbeat received | Worker alive, not done. Keep waiting |
| Terminal disappeared / exited | Worker crashed. Re-create terminal, re-dispatch with same brief |
| 3 consecutive timeouts with no liveness | Circuit-break: mark task failed, escalate to human |

**Key rule:** One timeout ≠ failure. Long coding tasks routinely run 15-60 minutes. Use rolling waits.

---

## Failure Ledger (fingerprint / count / 5th-fail rule)

**Vocabulary canon:** `skills/wave-spec/references/glossary.md` (CAS-167). Same terms as wave-spec STATUS.md columns (`fingerprint / hypothesis / count / reset_reason`). The orchestrator owns the ledger; workers report evidence payloads only.

### Fingerprint — normalized failure identity

- **Composition:** `package + command/test + class-or-message + stable path/symbol`.
- **Exclude from fingerprint:** timestamps, temporary paths, generated ids, secret values.
- **No active failure:** `fingerprint = —` (with `hypothesis = —`, `count = 0`, `reset_reason = —`).

### Consecutive count (`count`)

- Increments **only** on evidence-bearing, reproducible, **package-owned** validation failures with the **same fingerprint** AND the **same hypothesis**.
- **Do NOT increment** without a confirmed failure: self-correction, tool retry, API retry, re-dispatch alone do not bump `count`.
- `reset_reason` stores the **last transition of the current series** (not only resets):
  - `same_fingerprint_retry` — ordinary counted retry; the series continues and `count` increments (this is NOT a reset, NOT escalation, NOT a model switch).
  - a reset-value (`pass | fingerprint_changed | package/command_changed | implementation_changed | hypothesis_changed | scope_changed`) — the series actually reset.
  - `non_counting:<category>` — a non-counting event was recorded.
  - `—` — no active failure.
- Closed list of transition values (8): `pass | fingerprint_changed | package/command_changed | implementation_changed | hypothesis_changed | scope_changed | non_counting:<category> | same_fingerprint_retry`.
- `implementation_changed` forces a reset on any material implementation change, even when the hypothesis is unchanged.

### Non-counting categories (closed list — exactly these 8)

`user_cancellation | tool_interruption | timeout | service_unavailable | browser_transport | dependency_environment | pre_existing_unrelated | outside_package_ownership`

- These failures do **not** increment `count`.
- Always record `category` + `reset_reason` (`non_counting:<category>`) + ownership/evidence.
- Classification axis: **infrastructure/liveness** vs **reproducible package-owned**.

### 5th-fail rule (escalation)

- Attempts 1–4: same worker, **no model switch**.
- On the **5th consecutive failure with the same fingerprint AND same hypothesis** → STOP. Return to the orchestrator: `package + ledger + evidence + hypothesis`.
- Orchestrator MUST perform a **material re-plan** (hypothesis / boundaries / scope / validation).
- No new plan → `blocked`, ask the human. (`blocked` is an orthogonal disposition, NOT a lifecycle-enum state.)
- **Switching the model alone is NOT a re-plan.**

### failure-events.md format (ledger entry)

The ledger lives at `waves/<date>-<slug>/failure-events.md` (wave-level). It is **append-only**: entries are only ever added, never overwritten or deleted; `FE-NNNN` ids are monotonic and never reused. The orchestrator is the **sole writer**; workers only report event payloads. Entry format:

```
## FE-NNNN
- package: <package>
- agent: <agent id>
- command/test: <команда или тест>
- fingerprint: <нормализованный id фейла>
- hypothesis: <одна активная причина>
- category: <counted | non_counting:<категория>>
- count: <целое число>
- reset_reason: <last transition value | —>
- status: <open | resolved | reset>
- evidence: <команда + вывод / file:line>
- ownership: <package-owner | orchestrator | infrastructure | outside_package:<owner>>
```

`ownership` is **mandatory for every non-counting event** (it identifies who owns the failing package/surface); for `outside_package_ownership` specify the real owner as `outside_package:<owner>`.

`status` shows **only the active streak** (not the full journal). Iteration handoff = compact snapshot + links to FE-IDs (not the full ledger). Root `SESSION_HANDOFF.md` carries a pointer, not a second ledger.

**`STATUS.md` vs lowercase `status`.** The wave-spec `STATUS.md` file (10 columns, CAS-167 canon — incl. `fingerprint / hypothesis / count / reset_reason`) holds **only the active streak / current row** for each open series; it does NOT duplicate the append-only history. The full history lives **only** in the wave-level `failure-events.md`. Lowercase `status` inside an FE-record is the event's own state (`open | resolved | reset`), NOT the `STATUS.md` file.

### Example ledger row

```
## FE-0007
- package: orders-api
- agent: A/agent1st_v37.3-flash
- command/test: pytest tests/orders/test_total.py::test_order_total
- fingerprint: orders-api::pytest::OrderTest.test_order_total::AssertionError::compute_total
- hypothesis: tax-rate rounding drops fractional cents inside compute_total()
- category: counted
- count: 5
- reset_reason: same_fingerprint_retry
- status: open
- evidence: pytest tests/orders/test_total.py::test_order_total → AssertionError: assert 19.99 == 20.00 (orders/api/compute_total.py:42)
```

At `count = 5` the worker STOPs and hands this entry (ledger ref + evidence + hypothesis) back to the orchestrator for a material re-plan. Attempts 1–4 stayed on the same worker with no model switch.

---

## Escalation Triggers

Worker sends `escalation` when:
- Blocked by missing permissions or access
- Task scope is ambiguous and could cause damage
- Contradicts coordinator's brief (brief says X, code shows Y)

Coordinator sends `decision_gate` when:
- Two workers contradict each other
- Implementation choice affects architecture
- Scope expansion beyond original brief

Human escalation when:
- Destructive actions needed
- External system writes
- Budget/cost concerns
- 5th-fail rule exhausted (`count = 5` → material re-plan performed and failed again)

---

## Model-Specific Failure Modes

| Model | Known failure mode | Mitigation |
|-------|-------------------|------------|
| GLM 5.2 | Overthinking under `max` → output displacement | Stop-signals in protocol; pair "don't" with "do" |
| DeepSeek V4 Flash | Roleplay thinking without 【】 injection (orchestrator role) | Always append 【思维模式要求】 in brief; skip only for trivial triage |
| Qwen 3.8 Max | Reasoning not preserved across turns | Verbalize key state to content field |
| GPT-5.5 | Effort persists across sessions; without explicit `/effort` may run at wrong depth | Always `/effort <val>` explicitly + `sleep 3` before dispatch |

---

## Recovery After Worker Crash

```bash
# Structure only — build exact flags from `orca skills get orchestration`.
# 1. Check what happened
orca terminal read --terminal <handle> --json

# 2. If terminal gone — create new one (use launch command from model-card.md, NOT bare "opencode")
orca terminal create --worktree active --title worker-<name>-retry \
  --command "<launch_command from model-card.md>" --json
orca terminal wait --terminal <new_handle> --for tui-idle --timeout-ms 60000 --json

# 3. Set variant/effort explicitly + sleep 3 (MANDATORY)
orca terminal send --terminal <new_handle> --text "<variant_or_effort>" --enter --json
sleep 3

# 4. Re-dispatch with a delta-only packet (NOT brief concatenation)
#    Fill skills/wave-spec/assets/templates/re-dispatch-brief.md.tmpl as the tail:
#      BASE_PACKET_PATH (immutable base brief, authoritative), ATTEMPT, FAILURE_EVENT_PATH,
#      FINGERPRINT, HYPOTHESIS, COUNT, RESET_REASON, PREVIOUS_EVIDENCE, CHANGED_DIFF_REF,
#      NEXT_ACTION, REVIEW_MODE (if applicable).
#    The base brief is NOT copied into the task text — the worker reads it by path.
#    Delta cannot override base scope/write-allowlist/acceptance/output-contract/Prohibited.
#    If BASE_PACKET_PATH is missing/unreadable → the worker sends escalation (not guessing).
#    Build the exact task-create / dispatch flags from `orca skills get orchestration`.
TASK_ID=$(orca orchestration task-create --spec "$(cat <path-to-filled-re-dispatch-tail.md>)" --json | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['result']['task']['id'])")
orca orchestration dispatch --task $TASK_ID --to <new_handle> --inject --json
```

**Same-worker / re-plan rules (preserved):** attempts 1–4 stay on the same worker with no model switch; on the 5th consecutive failure with the same fingerprint AND same hypothesis → STOP and the orchestrator performs a material re-plan (hypothesis / boundaries / scope / validation). Switching the model alone is NOT a re-plan. The retry delta references the ledger (`FAILURE_EVENT_PATH` + `FINGERPRINT` + `COUNT`) — it does NOT create a second ledger and does NOT replace the same-worker/re-plan contract above. See `skills/wave-spec/SKILL.md` §6e Context placement for the prefix/tail/precedence contract and `references/worker-contract.md` for the preamble/base/delta cross-reference.

**Not a `terminal send` follow-up:** retry delivery stays on `dispatch --inject` (the only path that injects the lifecycle preamble with fresh TASK_ID/DISPATCH_ID). `terminal send` does not inject the preamble and is not a retry channel.

## Message Routing Void (verify-arrival rule)

**Symptom:** `orca orchestration send` returns `Sent msg_<id>` in terminal, but coordinator's `check --wait` never receives the message. Queue shows heartbeats but no worker_done.

**Root cause:** `--to <coordinator-handle>` flag missing. Orca returns msg ID even on route void — terminal output is NOT proof of delivery.

**Detection protocol:**
1. Verify via GLOBAL inbox FIRST (handle-scoped `check` can miss it — see "Handle Drift / Stale Recipient" below): `orca orchestration inbox --limit 20 --json`, filter `type=="worker_done"` by payload taskId
2. Cross-check handle-scoped queue: `check --peek --json | grep -A 2 worker_done`
3. If inbox EMPTY but worker printed "Sent msg_..." → true routing void (missing `--to`). If inbox HAS it but `check` empty → handle drift / self-send (next section)

**Recovery:**
1. `terminal read --terminal <worker_handle>` — see what worker actually did
2. If worker finished work but send command lacked `--to` → re-instruct: `terminal send "Re-send worker_done with --to <COORDINATOR-HANDLE>"`
3. If worker gone → recover report from terminal output, manually update coordinator state

**Source:** production incident — message lost in void route.

---

## Handle Drift / Stale Recipient (verify-arrival rule)

**Symptom:** coordinator's `check --wait` / `check --peek` / `check --all` return 0 messages, but `orca orchestration inbox` shows the expected worker_done (and others). The worker correctly sent `worker_done` with `--to` (worker_done rule satisfied).

**Root cause:** `check` is **handle-scoped** ("every message for the handle"); `inbox` (no `--terminal`) is **runtime-global** ("across recipients"). Terminal handles are ephemeral routing metadata — a pane gets a NEW handle after restart/reconnect. A worker_done addressed to the coordinator's OLD handle (the one in the worker's preamble at dispatch time) stays in the global log (`inbox`) but is invisible to `check` on the coordinator's CURRENT handle. Identical symptom, second trigger: a **self-send** (stored `from == to`, e.g. a worker running in the coordinator's terminal sends `worker_done --to <coordinator>` without `--from`) is skipped by `check` but present in `inbox`.

**Detection protocol:**
1. Verify delivery via GLOBAL inbox, not handle-scoped check: `orca orchestration inbox --limit 20 --json`, filter `type=="worker_done"` by payload taskId.
2. If inbox HAS the worker_done but `check --wait` didn't return it → compare its `to_handle` to the coordinator's current handle: `orca terminal list --worktree active --json`. Mismatch = handle drift.
3. Confirm the target is orphaned: `orca terminal list --json | grep <to_handle>` → no live pane = stale.
4. If `to_handle` equals the current handle yet `check` missed it → check for self-send (stored `from == to`).

**Recovery:**
1. Read the worker_done from `inbox` (global) — report/payload intact; recover `reportPath` and `filesModified` from it.
2. Re-resolve the coordinator handle: `orca terminal list --worktree active --json`.
3. Re-dispatch active tasks (or have workers re-resolve) so subsequent lifecycle mail targets the NEW handle.
4. Self-send prevention: workers set an explicit `--from <own-handle>`; never rely on auto-resolution from a shared/coordinator terminal.

**Source:** production incident + routing investigation. A message addressed to an orphaned handle while the coordinator was on a different handle; `check=0`, `inbox` showed it. Proven: self-send skip + stale-handle invisibility.

---

## API Retry Storm — Writer Swap (writer-swap rule)

**Symptom:** worker terminal shows `Request Timeout: request timeout [retrying in 8s attempt #10]` or similar API retry loop.

**Wrong response:** wait indefinitely OR redo from scratch. Both waste resources.

**Swap protocol:**
1. **Terminal read first** — confirm retry storm: `orca terminal read --terminal <worker_handle> --json`
2. **File inspection** — check what work was actually done: `git diff --stat` or `git status --short`
3. **Decision branch:**
   - **Files modified match expected scope** → writer did the work, just cannot signal. Ctrl-C worker terminal. Dispatch NEW writer terminal with brief "verify + finalize" (lint, git diff review, send worker_done). NOT redo from scratch.
   - **Files not modified or partial** → writer did not do the work. Ctrl-C, re-dispatch from scratch (optionally cross-family swap).
4. **Document** in handoff: branch chosen, reserve dispatch consumed.

**Source:** production incident — primary writer applied 6 items but stuck on retry #10. Fallback writer verify+finalize succeeded in 5 min. If coordinator had redo-from-scratch → all primary work lost.

