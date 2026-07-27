# Worker Output Contract & Inject Preamble

## Output Contract (mandatory for every worker)

Every worker ends with exactly this structure (in the **report file** and/or notes — not necessarily the full `worker_done` body):

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
- review-only mode: CHANGES must be "None". Findings only (except the review report path if the brief allows writing it).
- implement mode: CHANGES lists every modified file.
- **written≠persisted gate (ALL workers, implement mode):** before `worker_done`, run `git status --short` and/or `ls -la` / `wc -l` and confirm **every** path in CHANGES / `--files-modified` exists on disk with expected content. A claimed file missing on disk = **FAIL** — do **not** send success `worker_done`. Report FAIL in `--subject` and list missing paths in `--body` / report. Trusting self-report without disk proof caused [TICKET] BLOCK (notes claimed `model-card.md` NEW while `ls` showed absent).

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
- Do the work. Then send worker_done exactly once (live Orca CLI — discrete flags, NOT a JSON --payload blob):
  orca orchestration send --to <coordinator_handle> --type worker_done \
    --subject "<PASS|FAIL|PARTIAL — short status>" \
    --body "<3-sentence executive summary: what you did, what you found, what's left>" \
    --task-id <TASK_ID> \
    --dispatch-id <DISPATCH_ID> \
    --files-modified "path/a,path/b" \
    --report-path "<optional path to full report with SUMMARY/EVIDENCE/CHANGES/RISKS/BLOCKERS>" \
    --json
- --body = short exec summary for the coordinator inbox. Full SUMMARY/EVIDENCE/CHANGES/RISKS/BLOCKERS → report file via --report-path (or in notes). Do not pack the entire 5-field contract into --body.
- --files-modified = comma-separated paths (empty or omit when review-only with no report file, or list the report path if you wrote one).
- Blocked → send ask or escalation. Do not thrash.
- After worker_done → idle (end turn).
- Heartbeat only if preamble asks for it (typical inject: every ~5 min while still working):
  orca orchestration send --to <coordinator_handle> --type heartbeat \
    --subject "alive" \
    --task-id <TASK_ID> --dispatch-id <DISPATCH_ID> \
    --json
  Heartbeat = alive, not done. Coordinator must not restart on heartbeat alone.
```

---

## worker_done field map (logical → live CLI)

| Logical field | Live CLI flag / channel | Notes |
|---------------|-------------------------|-------|
| taskId | `--task-id` | Required for lifecycle authority |
| dispatchId | `--dispatch-id` | Required for lifecycle authority |
| status | `--subject` prefix | e.g. `PASS: …` / `FAIL: …` / `PARTIAL: …` |
| summary | `--body` | 3 sentences max |
| filesModified | `--files-modified` | Comma-separated paths |
| reportPath | `--report-path` | Optional path to full contract artifact |
| duration | optional in report file | Not a separate CLI flag |

Do **not** use `--payload '{"taskId":...}'` as the primary form — older docs used a JSON payload; current Orca orchestration send accepts the discrete flags above (as injected by `dispatch --inject`).

---

## Parsing Orca JSON Responses

| Command | Correct path | Common mistake |
|---------|-------------|----------------|
| `task-create --json` | `result.task.id` | ~~`result.id`~~ |
| `terminal create --json` | `result.terminal.handle` | ~~`result.handle`~~ |
| `dispatch --json` | `result.dispatch.id` | — |

Python one-liner pattern:
```bash
TASK_ID=$(orca orchestration task-create --spec "<brief>" --json | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['result']['task']['id'])")
```

---

## terminal send Prohibition

`terminal send` does NOT inject the lifecycle preamble (ROLE/SCOPE/MODE/COORDINATOR_HANDLE/TASK_ID/DISPATCH_ID). Without it, the worker cannot send `worker_done` through the protocol. **The only path for task delivery is `dispatch --inject`.** Exception: manual debugging (not orchestration).

---

## Qwen Code Note

Qwen Code (`qwen --approval-mode yolo`) natively understands worker_done, heartbeat, escalation — no inject preamble wrapping needed for lifecycle. However, `--approval-mode yolo` is mandatory for Orca workers (without it, orca commands block on confirmation). Effort (`/effort medium|high|xhigh|max`) persists across sessions — always set explicitly.

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
