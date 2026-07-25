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
| Grok 4.5 | "I'll do it myself" instead of routing | Explicit scope boundaries in brief |
| GPT-5.6 | Over-asking without autonomy policy | Include compact autonomy policy in brief |

---

## Recovery After Worker Crash

```bash
# 1. Check what happened
orca terminal read --terminal <handle> --json

# 2. If terminal gone — create new one
orca terminal create --worktree active --title worker-<name>-retry --command "opencode" --json
orca terminal wait --terminal <new_handle> --for tui-idle --timeout-ms 60000 --json

# 3. Re-dispatch with context about previous failure
orca orchestration task-create --spec "<brief + 'Previous attempt failed: <evidence>. Try different approach.'>" --json
orca orchestration dispatch --task <new_id> --to <new_handle> --inject --json
```
