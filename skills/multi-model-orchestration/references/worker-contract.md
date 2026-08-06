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
- **written≠persisted gate (ALL workers, implement mode):** before `worker_done`, run `git status --short` and/or `ls -la` / `wc -l` and confirm **every** path in CHANGES / `--files-modified` exists on disk with expected content. A claimed file missing on disk = **FAIL** — do **not** send success `worker_done`. Report FAIL in `--subject` and list missing paths in `--body` / report. Trusting self-report without disk proof caused a production BLOCK (notes claimed a file NEW while `ls` showed absent).

---

## Failure-State Reporting (failure-ledger integration)

When a worker hits a reproducible package-owned validation failure, it reports a failure-state payload so the orchestrator can keep the ledger (vocabulary canon: `skills/wave-spec/references/glossary.md`, CAS-167). Fields:

| Field | What to report |
|-------|----------------|
| `ledger_path` | Path to the orchestrator-owned `failure-events.md` (worker references it, does not own it) |
| `event_ids` | FE-NNNN ids the worker is contributing to (e.g. `FE-0007`); `—` if no active streak |
| `fingerprint` | Normalized id: `package + command/test + class-or-message + stable path/symbol` (no timestamps / generated ids / secrets); `—` if no active failure |
| `hypothesis` | One active root-cause hypothesis; `—` if none |
| `count` | Consecutive same-fingerprint same-hypothesis count the worker observed |
| `reset_reason` | Last transition of the current series: `same_fingerprint_retry` on a counted retry (series continues), a reset-value (`pass / fingerprint_changed / package/command_changed / implementation_changed / hypothesis_changed / scope_changed`) on an actual reset, `non_counting:<category>` on a non-counting event; `—` only when there is no active failure |
| `category` | `counted`, or `non_counting:<one of 8>` (`user_cancellation / tool_interruption / timeout / service_unavailable / browser_transport / dependency_environment / pre_existing_unrelated / outside_package_ownership`) |
| `evidence` | Command + observed output / `file:line` proving the failure |
| `ownership` | `package-owner | orchestrator | infrastructure | outside_package:<owner>` — **mandatory for every non-counting event** (identifies who owns the failing package/surface) |

**5th-fail rule:** at `count = 5` the worker STOPs, does not self-fix further, and references the full ledger (`ledger_path` + `event_ids` + `fingerprint` + `hypothesis` + `evidence`) in its report so the orchestrator can do a material re-plan. The 3-sentence `worker_done` body limit still holds — failure-state detail goes in the report file / notes, not in `--body`.

**Non-counting:** infrastructure/liveness failures (`timeout`, `service_unavailable`, …) do not increment `count`; still report `category` + `reset_reason: non_counting:<category>` + ownership/evidence.

See `references/failure-handling.md` → Failure Ledger for the entry format and the full reset_reason list.

## Handoff Section → Output Contract Mapping

When a worker's report or an iteration handoff uses prose section headers, map them onto the Output Contract fields when filling `worker_done` / report files:

| Handoff section | Output Contract field |
|-----------------|----------------------|
| `### Changed files` | `CHANGES` |
| `### Delivered behavior` | `SUMMARY` |
| `### Validation (command + observed)` | `EVIDENCE` |
| `### Residual risk` | `RISKS` |

`BLOCKERS` has no handoff-section equivalent — report it inline as its own field.

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

## worker_done Delivery Rule

**worker_done MUST be sent via `orca orchestration send --type worker_done` CLI command.** Printing the report as text in chat is NOT a substitute — the coordinator's `check --wait` only receives messages sent through the orchestration protocol.

If you print the report as text AND send worker_done via CLI — that's fine (coordinator gets the signal, human sees the report). But worker_done via CLI is mandatory.

```bash
orca orchestration send --to <coordinator_handle> --type worker_done \
  --subject "<PASS|FAIL|PARTIAL — short status>" \
  --body "<3-sentence executive summary>" \
  --task-id <TASK_ID> --dispatch-id <DISPATCH_ID> \
  --files-modified "path/a,path/b" \
  --report-path "<optional>" \
  --json
```

## Anti-Pattern: Reconstructing send from memory (worker_done rule)

**Hard prohibition:** never reconstruct `orca orchestration send` command from memory. Always copy from this document or `orca skills get orchestration`.

**Reason:** Some worker families have a documented tendency to reconstruct CLI commands from parametric memory, dropping the `--to <coordinator-handle>` flag. Without `--to`, orca returns a msg ID (e.g., `Sent msg_<id>`) but message routes to void — coordinator never receives it.

**Production incident:** a reviewer reconstructed send, dropped `--to`, message lost. Coordinator trusted "Sent msg_..." terminal output, waited 15+ min, then became messenger (pasted verdict manually).

**Mitigation:**
1. Brief MUST contain explicit example: `orca orchestration send --to <COORDINATOR-HANDLE> --type worker_done ...`
2. Worker copy-pastes from brief, does not retype
3. Coordinator verifies every expected worker_done via GLOBAL `inbox` filtered by payload taskId — not handle-scoped `check --peek` (verify-arrival rule; see warning below)

---

## Handle Drift Warning: `check` is handle-scoped, `inbox` is global (verify-arrival rule)

> **check is handle-scoped; inbox is global. Handle drift after terminal restart makes `check=0` while `inbox=N`. Verify via inbox filtered by taskId.**

`check` (`--peek/--unread/--all`) returns only messages addressed to the checking terminal's CURRENT handle. `inbox` (no `--terminal`) is runtime-global and shows every message regardless of recipient. A worker_done that exists in `inbox` but not in `check` is addressed to a handle that is no longer the coordinator's current handle — typically a **stale handle after a terminal restart (handle drift)** — or is a **self-send** (stored `from == to`) which `check` skips. Handles are ephemeral routing metadata; a pane gets a new handle on restart, but messages to the old handle remain in the global log.

**Worker rule:** set an explicit `--from <own-handle>` on lifecycle mail; never rely on `--from` auto-resolution when sending from a shared/coordinator terminal (auto-resolve to the coordinator handle == `--to` creates a self-send that `check` skips).

**Coordinator rule:** verify arrival via `orca orchestration inbox --limit 20 --json` filtered by `type=="worker_done"` and payload `taskId` — not handle-scoped `check`. If inbox has it but `check --wait` missed it, re-resolve via `orca terminal list --worktree active --json` and re-dispatch active tasks onto the new handle.

**Source:** production incident + routing investigation.

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
