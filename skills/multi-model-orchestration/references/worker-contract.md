# Worker Output Contract & Inject Preamble

## Output Contract (mandatory for every worker)

Every worker ends with exactly this structure:

```
SUMMARY: [1-3 sentences: what was done, what was found]
EVIDENCE: [file:line, command+exit, URL+finding — concrete proof]
CHANGES: [list of files modified, or "None" for review-only]
RISKS: [what could go wrong, or "None observed"]
BLOCKERS: [what prevents completion, or "None"]
```

Rules:
- `worker_done` sent exactly once, even on failure.
- After `worker_done` → idle. Do not poll or continue.
- review-only mode: CHANGES must be "None". Findings only.
- implement mode: CHANGES lists every modified file.

---

## Inject Preamble (dispatched via `--inject`)

When using `orca orchestration dispatch --inject`, the preamble is auto-generated.
For manual dispatch or `terminal send`, include this preamble:

```
ROLE: worker (not coordinator).
SCOPE: <file paths or "all project">.
MODE: review-only | implement.
COORDINATOR_HANDLE: <handle for worker_done>.
TASK_ID: <id>. DISPATCH_ID: <id>.

TASK:
<the actual brief — model-specific format>

LIFECYCLE:
- Do the work. Then send worker_done exactly once:
  orca orchestration send --to <coordinator_handle> --type worker_done \
    --subject "<short status>" \
    --body "<SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS>" \
    --payload '{"taskId":"<id>","dispatchId":"<id>","filesModified":[...]}' --json
- Blocked → send ask or escalation. Do not thrash.
- After worker_done → idle (end turn).
- Heartbeat only if preamble asks for it.
```

---

## worker_done Payload Schema

```json
{
  "taskId": "<task_id>",
  "dispatchId": "<dispatch_id>",
  "filesModified": ["path/a", "path/b"],
  "reportPath": "<optional: path to detailed report file>",
  "status": "PASS | FAIL | PARTIAL",
  "duration": "<optional: wall-clock time>"
}
```

---

## Coordinator Synthesis Template

After collecting N worker reports:

```markdown
## Multi-Model Review: <topic>

### Consensus (high confidence)
- [items all models agree on]

### Contradictions (human decides)
- ⚠️ Model A says X. Model B says Y.
  - A evidence: [quote]
  - B evidence: [quote]

### Gaps (one found, others missed)
- [finding unique to one model]

### Decisions needed
1. ⚠️ HUMAN DECISION REQUIRED: [question]

### Action items
- [ ] [fix/implementation task → route to one writer]
```
