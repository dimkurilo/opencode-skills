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

## Worker Self-Correction

1. Worker encounters error → tries 1 self-correction (re-read → diagnose → fix → re-verify).
2. If self-correction succeeds → continue normally.
3. If still failing after 1 correction → report FAIL in worker_done with:
   - What was tried
   - Error evidence (command output, stack trace)
   - Hypothesis on root cause
4. Coordinator decides:
   - Re-dispatch to SAME model with fix context ("previous attempt failed: <evidence>. Try different approach.")
   - OR route to DIFFERENT model (cross-family perspective)
   - OR escalate to human (if ownership/scope unclear)

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
- All models failed (3+ failures across models)

---

## Circuit-Breaker

After 3 consecutive failures on one task (any combination of models):
1. STOP retrying.
2. Report to human: what was tried, what failed, evidence.
3. Ask: "Task X failed 3 times. Options: (a) simplify scope, (b) different approach, (c) abandon."

---

## Model-Specific Failure Modes

| Model | Known failure mode | Mitigation |
|-------|-------------------|------------|
| GLM 5.2 | Overthinking under `max` → output displacement | Stop-signals in protocol; pair "don't" with "do" |
| DeepSeek Pro | Roleplay thinking without 【】 injection | Always append 【思维模式要求】 |
| DeepSeek Flash | Weak on complex SWE / October CMS core | Route core paths to Pro; Flash for bulk only |
| Qwen 3.8 Max | Reasoning not preserved across turns | Verbalize key state to content field |
| Qwen Code | Without `--approval-mode yolo` blocks orca commands. Effort persists across sessions | Always `--approval-mode yolo`. Always `/effort <val>` explicitly + `sleep 3` before dispatch |
| Grok 4.5 | "I'll do it myself" instead of routing. 3+ identical tool calls → loop (P15/P18) | Explicit scope boundaries in brief. 3 identical actions → circuit-break + text response to user |

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

# 4. Re-dispatch with context about previous failure
TASK_ID=$(orca orchestration task-create --spec "<brief + 'Previous attempt failed: <evidence>. Try different approach.'>" --json | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['result']['task']['id'])")
orca orchestration dispatch --task $TASK_ID --to <new_handle> --inject --json
```

## Message Routing Void ([RULE])

**Symptom:** `orca orchestration send` returns `Sent msg_<id>` in terminal, but coordinator's `check --wait` never receives the message. Queue shows heartbeats but no worker_done.

**Root cause:** `--to <coordinator-handle>` flag missing. Orca returns msg ID even on route void — terminal output is NOT proof of delivery.

**Detection protocol:**
1. After every `check --wait` that should receive worker_done, ALWAYS run `check --peek --json`
2. Grep queue for type=worker_done: `check --peek --json | grep -A 2 worker_done`
3. If queue empty but worker printed "Sent msg_..." → routing bug confirmed

**Recovery:**
1. `terminal read --terminal <worker_handle>` — see what worker actually did
2. If worker finished work but send command lacked `--to` → re-instruct: `terminal send "Re-send worker_done with --to <COORDINATOR-HANDLE>"`
3. If worker gone → recover report from terminal output, manually update coordinator state

**Source:** [TICKET][ITER] [incident-date] — [MSG] lost in void route.

---

## API Retry Storm — Writer Swap ([RULE])

**Symptom:** worker terminal shows `Request Timeout: request timeout [retrying in 8s attempt #10]` or similar API retry loop.

**Wrong response:** wait indefinitely OR redo from scratch. Both waste resources.

**Swap protocol:**
1. **Terminal read first** — confirm retry storm: `orca terminal read --terminal <worker_handle> --json`
2. **File inspection** — check what work was actually done: `git diff --stat` or `git status --short`
3. **Decision branch:**
   - **Files modified match expected scope** → writer did the work, just cannot signal. Ctrl-C worker terminal. Dispatch NEW writer terminal with brief "verify + finalize" (lint, git diff review, send worker_done). NOT redo from scratch.
   - **Files not modified or partial** → writer did not do the work. Ctrl-C, re-dispatch from scratch (optionally cross-family swap).
4. **Document** in handoff: branch chosen, reserve dispatch consumed.

**Source:** [TICKET][ITER] — DeepSeek Pro applied 6 items but stuck on retry #10. Codex 5.5 verify+finalize succeeded in 5 min. If coordinator had redo-from-scratch → all Pro work lost.

