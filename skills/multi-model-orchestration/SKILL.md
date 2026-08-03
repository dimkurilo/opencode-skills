---
name: multi-model-orchestration
description: "Coordinate 2+ AI models (DeepSeek V4 Flash, Qwen 3.8 Max, GLM 5.2, GPT-5.5) for parallel review, cross-validation, or bulk work via Orca orchestration. Use when the coordinator says \"обсудите этот вопрос с 2 моделями\", \"multi-model review\", \"cross-validate with N models\", \"parallel architecture specs\", or any task requiring independent perspectives from different model families. ROUTER: новый проект → project-bootstrap · план спринта → wave-spec · 2+ модели → multi-model-orchestration. Do NOT use for single-model tasks, trivial edits, or when §1 decision tree says solo."
---

# Multi-Model Orchestration

Coordinator dispatches tasks to 2+ model workers via Orca, waits for results, synthesizes.
Coordinator dispatches, waits, synthesizes, gates. Writing code in a coordinator session requires an explicit owner-pin switch to writer role — coordinator does not combine orchestration with code writing in the same task.
Coordinator = any model with this skill loaded. This skill does not prescribe coordinator family.

## TL;DR (minimum path)

**multi-model-orchestration = dispatch/review движок для ≥2 моделей.** Координатор маршрутизирует задачи воркерам (Orca), ждёт, синтезирует. Координатор не совмещает оркестрацию с написанием кода в одной задаче.

**Когда:** «обсудите с 2 моделями», cross-validate, parallel review, fidelity port, security/RLS (никогда одной моделью). **Когда нет:** §1 говорит solo, тривиал, одна модель.

**Ядро:** solo-vs-multi дерево (§1) → роутинг моделей (§2) → **cross-family rule: writer.family ≠ reviewer.family** → brief (§4) → dispatch через Orca (`dispatch --inject`, НЕ `terminal send`, sleep 3) → wait (`check --wait`) → синтез (§7, stricter wins). Worker contract: SUMMARY/EVIDENCE/CHANGES/RISKS/BLOCKERS + written≠persisted.

**Роутер:** новый проект → `project-bootstrap` · план спринта → `wave-spec` · 2+ модели → `multi-model-orchestration`. Lifecycle gates (Commit/PR/Merge/Deploy/On prod) — канон в `wave-spec`.

---

## 0. Preconditions

```bash
orca status --json          # runtime up?
```

If Orca unavailable → manual fallback (§0b). Do not guess flags.

Skills required: `orca-cli` (terminal ops), `orchestration` (task/dispatch/wait).

### 0b. Manual Fallback (Orca unavailable)

If `orca status` fails or Orca is not installed:

1. Coordinator opens N terminal tabs/windows manually (one per model).
2. In each terminal: launch the model's CLI (`opencode`, `codex`, etc.).
3. Copy-paste the model-specific brief (from `references/routing.md`) into each terminal.
4. Collect outputs manually when workers finish.
5. Synthesize per §7.

No `worker_done` lifecycle in manual mode — coordinator polls visually.
Skill still applies: routing (§2), brief structure (§4), synthesis (§7), write policy (§6).

---

## 1. Decision: Solo vs Multi

```
Task clear, 1 deliverable, linear, < 2-3h?
  └─ YES → SOLO. Stop. Do not open multi.

2+ independent pieces needed IN PARALLEL?
  └─ YES → multi ok.

Expensive error + need second family? (prod, security, big refactor)
  └─ YES → multi: writer ≠ reviewer.

Bulk > 1 context window?
  └─ YES → multi by layers.

Scope unclear?
  └─ solo discovery first. Then re-evaluate.

Otherwise → solo.
```

**Not multi:** trivial fix, single short report, no patience for wait loops.

---

## 2. Routing — Which Model for What

| Work | Route to | Family | Why |
|------|----------|--------|-----|
| **Orchestration / dispatch / handoff** | **DeepSeek V4 Flash** | DeepSeek | Role lock: не совмещает оркестрацию с написанием кода в одной задаче. Dispatch → wait → synthesize → gate. Full role |
| **Implement (primary writer/coder)** | **DeepSeek V4 Flash** (`A/agent1st_v37.3-flash`) | DeepSeek | Default writer — fast ($0.14/$0.28 per 1M), strong on 0731 benchmarks (SWE-bench 79.0 Flash-Max, LiveBench Coding 69.2). Single-file, bulk code, tests |
| **Multi-file implement (3+ files)** | **GLM 5.2** (`A/agent1st_glm`) | Zhipu | 1M state continuity, long-horizon multi-file specialty (~15 min implement, ~10 min fix-round) |
| **Review / architecture / business analysis (default reviewer)** | **Qwen 3.8 Max** (`A/agent1st_qwen-3.8`) | Alibaba | 2.4T/95B active, native vision, CoT. Vendor benches 2026-08-03 (qwen.ai/blog): GPQA-D 92.6, Terminal-Bench 2.1 86.6 — indep verification pending. Owner empirical: level ~ Kimi K3, **сильнее GLM 5.2 в architecture и depth**. NE основной кодер (slow) |
| Complex analysis, multimodal, cross-examination | **Qwen 3.8 Max** | Alibaba | 2.4T/95B active, native vision, CoT |
| Security / RLS / auth / Storage review | **GPT-5.5 + DeepSeek V4 Flash** (parallel) | OpenAI + DeepSeek | Gate + implementer; cross-family mandatory |
| **Behavioral regression gate** | **GPT-5.5** | OpenAI | Unique role — caught abort/cost MAJOR GLM missed. NOT "just another reviewer" |
| **Fidelity port** (generator, vectorizer, reference→platform) | **DeepSeek V4 Flash** write (default) / **GLM 5.2** (multi-file) · **Qwen 3.8 Max** ∥ **GPT-5.5** review | DeepSeek/Zhipu · Alibaba ∥ OpenAI | Evidence (production waves): Flash bulk implement; GLM exhaustive static parity; GPT-5.5 behavioral regression gate; Qwen architect/analyst. Dual review mandatory — complementary, not redundant |
| Cross-QA (review someone else's work) | **Different family** | — | Blind-spot detection |

**Cross-family rule:** writer.family ≠ reviewer.family. Qwen Code (Alibaba) writer → reviewer must be DeepSeek/Zhipu/OpenAI, NOT OpenCode Qwen (also Alibaba). Full pairs: `references/routing.md` → Cross-Family Pairs.

**Writer replaceable:** owner phrase «сейчас writer=X» (Flash or GLM) pins writer instantly — no skill rewrite. Default writer: DeepSeek V4 Flash (fast, cheap). GLM = swap для multi-file. Qwen 3.8 Max = default reviewer/architect (NE writer — slow). See `references/routing.md` for the full routing table with evidence anchors.

Synthesis: MAJOR from any reviewer → fix before merge; prefer stricter severity on contradictions.

Full routing details + brief templates: `references/routing.md`.

---

## 2b. Deploy / smoke gate

**Canonical definition:** `skills/wave-spec/SKILL.md` §"Deploy Probe (Universal Pattern)".
**Canonical examples:** `skills/wave-spec/SKILL.md` §Deploy Probe — curl dual-pattern + skills-repo check.

**SUMMARY:** After merge/deploy (or skill install), prove the shipped surface exists before handoff. The probe checks existence, not correctness — correctness is verified at In Review. Adapt the probe to the target stack (web curl, CLI binary, package install, skill load path). Principle: one observable command that proves the artifact reached production. No probe = RESIDUAL-RISK-OWNER-SMOKE.

Evidence: production waves had untracked route files — if deployed without tracking, 404.

---

## 2c. Fidelity Port Rules

**Canonical definition:** `skills/wave-spec/SKILL.md` §"Fidelity Dual Review".

**SUMMARY (5 rules):**
1. **Dual review mandatory:** static-parity reviewer ∥ behavioral-semantics reviewer as two complementary lenses from **different model families**. Single-reviewer fidelity ports are NOT accepted.
2. **Writer ≠ reviewer.** Cross-family mandatory (writer.family ≠ reviewer.family).
3. **MAJOR from any reviewer → fix round before In Review.** Stricter severity wins.
4. **No live smoke = RESIDUAL-RISK-OWNER-SMOKE** in handoff. Document explicitly.
5. **Deploy gate:** prove shipped surface before handoff (§2b).

Evidence (production waves): GLM-only would have missed abort MAJOR; Codex-only would have missed a numeric edge case + refine path.

For non-fidelity waves: dual review is recommended but not mandatory. At minimum, writer ≠ reviewer.

---

## 2d. Lifecycle Gates

**Canonical definition:** `skills/wave-spec/SKILL.md` §"Lifecycle Gates (lessons from production incidents)".

8 states, linear order, deploy probe, RESIDUAL-RISK-OWNER-SMOKE — полная таблица в каноне (дубль убран, один источник правды).

---

## Cross-skill compatibility

multi-model-orchestration is a **dispatch/review skill** — it does NOT own the plan-gate pipeline. Lifecycle gates, fidelity dual review rules, and deploy probe are defined in wave-spec (§Lifecycle Gates, §Fidelity Dual Review, §Deploy Probe). This skill keeps inline SUMMARIES for standalone use.

### Recommended ordering
1. **project-bootstrap** — creates agent infrastructure (AGENTS.md, SESSION_HANDOFF.md, .agents/memory/)
2. **wave-spec** — creates SPEC.xml + PLAN.xml with lifecycle gates, fidelity rules, deploy probe
3. **multi-model-orchestration** (this skill) — executes dispatch/review via Orca

### Canonical sources (wave-spec)
- **Lifecycle:** wave-spec §Lifecycle Gates — 8 states, linear ordering
- **Fidelity Dual Review:** wave-spec §Fidelity Dual Review — 5 rules, dual review mandatory
- **Deploy Probe:** wave-spec §Deploy Probe — existence check pattern

### Standalone use
This skill can be used without wave-spec. Inline SUMMARIES in §2b/§2c/§2d cover base definitions. For full lifecycle contract, load wave-spec.

---
## 3. Coordinator Loop

```
1. CLASSIFY task → solo or multi (§1)
2. SELECT models (§2) — name them explicitly to human
3. CREATE terminals (one per worker, same worktree)
4. BUILD briefs (model-specific pattern — see references/routing.md)
5. PRE-DISPATCH GATE (mandatory before EVERY worker):
   a. model-card.md checked → model available, pin current
   b. --agent / --approval-mode yolo specified in command
   c. variant/effort set + sleep 3
   d. dispatch --inject (NOT terminal send)
   e. writer.family ≠ reviewer.family (cross-family)
   f. Brief contains: ROLE/SCOPE/MODE/DONE + written≠persisted gate
   If ANY item fails — DO NOT dispatch. Fix first.
6. DISPATCH: task-create → parse result.task.id → dispatch --inject
7. WAIT: check --wait --types worker_done,escalation,decision_gate
8. POST-WORKER_DONE SEQUENCE (do not skip):
   a. git status --short → verify claimed files exist (written≠persisted)
   b. Linear comment (project protocol, if applicable)
   c. Dispatch reviewer (model-specific brief INLINE, not lazy prompt)
   d. Wait reviewer worker_done
   e. Synthesis (stricter wins)
   f. ONLY THEN: In Review / next step
9. GATE: read artifacts → synthesize → decide next
10. REPORT to human: consensus / contradictions / gaps
```

**User message interrupt:** if the user sends a message while coordinator is in a tool-calling loop — IMMEDIATELY stop the loop. Respond with text: current status + what's next. Do not continue tool calls without acknowledging the user.

### Role Lock (coordinator session) — HARD GATE

```
ORCHESTRATOR: dispatch → wait → synthesize → gate.
If coordinator edits ANY worker file without an explicit owner-pin switch to writer role → STOP. Undo. Re-dispatch to worker.
Switching orchestrator → writer is an explicit owner-pin decision («сейчас writer=X» or «сейчас orchestrator=X»), not a same-task combination.
Review-only worker_done ≠ right to edit files. Implement = new task.
Heartbeat ≠ done. One timeout ≠ fail → liveness check → wait again.
Max 3 workers per wave. Do not "help" workers by editing in coord session.
3+ identical tool calls → circuit-break → text response to user.
```

---

## 4. Worker Brief Structure

Every brief MUST contain (adapt format to model — see `references/routing.md`):

```
ROLE: worker (not coordinator). Scope: <paths>.
MODE: review-only | implement.
TASK: <what to do — 1-3 sentences>.
DONE: <acceptance criterion>.
OUTPUT: SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS.
review-only → findings only, NO file edits.
Blocked → ask/escalation, do not thrash.
After worker_done → idle (end turn).
```
- **NEW worker_done rule**: Brief ALWAYS contains explicit `--to <coordinator-handle>` example. Without `--to`, orca returns msg ID but message goes to void route (production incident: message lost).
- **NEW writer-swap rule self-protection for implement workers**: Brief contains clause: "On API retry attempt #5+ → terminal read first → git diff --stat → if files modified match expected → idle and signal via heartbeat; if blocked → Ctrl-C and wait for coordinator swap. Do NOT continue retrying."

Model-specific wrapping:
- **GLM 5.2**: Goal → Context → Constraints → Done. No 【】. No "think step by step".
- **DeepSeek V4 Flash**: Задача → Где → Контекст → Не трогать + 【思维模式要求】 at end.
- **Qwen 3.8 Max**: Context → Objective → Steps → Examples → Response Format. CoT ok.
- **GPT-5.5**: Goal → Success → Context → Constraints → Autonomy. Lean contracts, behavioral semantics focus.

---

## 5. Wait & Failure Handling

| Event | Action |
|-------|--------|
| `worker_done` | Read artifacts → **verify claimed files on disk if implement** → gate/synthesize |
| `heartbeat` | Worker alive, **not done**. Keep waiting. Do not restart; do not treat as completion |
| `escalation` / `decision_gate` | Human or coordinator decision. Not blind re-dispatch |
| timeout / count:0 | Liveness check (`terminal read`). NOT restart. Wait again |
| 3 consecutive failures | Circuit-break. Route to different model or escalate to human |
| Worker reports FAIL | Coordinator decides: re-dispatch with fix context OR route to different model |

| **NEW verify-arrival rule** | After `check --wait`, verify delivery via **GLOBAL inbox** (`orca orchestration inbox --limit 20 --json`, filter by payload taskId), NOT handle-scoped `check`. `check` is handle-scoped → it misses worker_done on **handle drift** (stale recipient handle after terminal restart) or **self-send** (stored from==to); both give `check=0` while `inbox=N`. If inbox has the worker_done but `check --wait` didn't return it → your handle changed (restart): re-resolve via `terminal list` / re-dispatch. If inbox lacks it → real routing miss, recover from terminal output (writer-swap rule) |
| **NEW writer-swap rule** | On API retry attempt #5+ in worker terminal: `terminal read` first → `git diff --stat` → if files modified match expected scope → dispatch verify+finalize brief to fresh writer terminal (NOT redo from scratch). If files not modified → re-dispatch from scratch or cross-family swap |

Details: `references/failure-handling.md`.

---

## 6. Write Policy

- Parallel workers: **read-only** OR **disjoint paths** only.
- Any implement/fix → **one writer** (serial task or separate worktree).
- Multiple writers on same worktree = merge conflict.

---

## 7. Synthesis & Report

After all workers complete:

1. Read each worker's OUTPUT (SUMMARY/EVIDENCE/CHANGES/RISKS/BLOCKERS).
2. Identify: **consensus** (all agree), **contradictions** (disagree + quotes), **gaps** (one covered, other missed).
3. Present to human: decisions needed marked `⚠️ HUMAN DECISION REQUIRED`.
4. If implementation needed → new task to one writer (not coordinator).

---

## 8. Language Discipline

- Coordinator ↔ human: match human's language.
- Coordinator → workers: brief language = coordinator's working language (match human's language unless model guide requires otherwise).
- DeepSeek 【思维模式要求】 block: always in Chinese (model-specific, not human-language-dependent).
- Code, paths, identifiers, tool names: always English/original form.

---

## 9. Anti-Patterns

**Hard Prohibitions (11 rules with alternatives): `references/prohibitions.md`** — single source of truth.

Key gates (details in prohibitions.md):
- Coordinator writes code → HARD GATE: undo + re-dispatch (§3)
- `terminal send` for task delivery → only `dispatch --inject`
- Writer + reviewer same family → cross-family mandatory
- Tool-calling loop > 3 identical actions → STOP + text response to user

---

## 10. Orca Commands — Build From Guide, Not From Memory

**Step 0 before any dispatch:** run `orca skills get orchestration` and read the output. This is the authoritative source for dispatch/wait/worker_done commands. Do NOT copy-paste bash from this skill, from NEXT_SESSION files, or from memory.

### Required sequence per worker

Build the exact commands from the orchestration guide. The sequence is:

1. **terminal create** — worktree active, command = launch from model-card.md
2. **terminal wait --for tui-idle** — timeout 60s (agent must be ready before dispatch)
3. **terminal send** — variant/effort command + **sleep 3** (race condition prevention). Note: this is `terminal send` for mode-setting, NOT for task delivery — task delivery is step 5 `dispatch --inject` only (see prohibitions.md #3)
4. **task-create** — spec = brief content or brief file path
5. **dispatch --task --to --inject** — injects lifecycle preamble
6. **check --wait --types worker_done,escalation,decision_gate** — rolling wait

### Verification gates

- After step 2: terminal is idle (ready for input). If not idle → wait more.
- After step 5: dispatch confirmed in output.
- After step 6: worker_done received. **Timeout ≠ failure** → terminal read → if working → repeat wait.
- If worker printed report as text but no worker_done → terminal send: "worker_done = orca orchestration send CLI command. Not text."

### NEW operational rules (3 rules)

Canonical source: `skills/project-bootstrap/references/operational-rules.md`.

**Rule 1 (worker_done rule)**: `worker_done` MANDATORY `--to <coordinator-handle>`. Without it → void route.
**Rule 2 (verify-arrival rule)**: After `check --wait` → verify delivery via **GLOBAL inbox** filtered by taskId (`inbox --limit 20 --json`), NOT handle-scoped `check`. `check` misses worker_done on handle drift (stale recipient handle) or self-send (from==to): `check=0` while `inbox=N`. Terminal "Sent msg_..." ≠ delivery proof.
**Rule 3 (writer-swap rule)**: On API retry #5+ → `terminal read` → file inspect → verify+finalize brief (NOT redo).

Source: production incident — reviewer missed `--to`, message lost.

### Shell timeout rule

When running `check --wait` from a shell subprocess, the shell timeout MUST be ≥ the Orca `--timeout-ms`. For 15-min Orca waits, either:
- Run check in background mode (`is_background: true`) and poll later
- Or set shell timeout to 600000ms with Orca timeout ≤ 540000ms

### Fallback when worker_done doesn't arrive

1. `terminal read --terminal <worker_handle>` — check if worker is still active
2. If active → repeat `check --wait` (rolling window)
3. If terminal gone → worker crashed, re-create + re-dispatch
4. Check `/private/tmp/task_<id>*` for report files (some models write there)

### Liveness check (on timeout)

```bash
orca terminal read --terminal <handle> --json
```

For non-TUI fallback: `opencode run --agent <agent> --model <model> --prompt "<brief>"`.

---

## 11. MCP Server Policy

Workers inherit MCP servers configured in their opencode instance (`opencode.json` or `~/.config/opencode/opencode.json`).

- Coordinator does NOT assume specific MCP availability across workers.
- If a task requires specific MCP (e.g., `excel`, `linear`, `meta-ads`): state it in the brief under CONSTRAINTS.
- Workers report unavailable MCP in BLOCKERS field of output contract.
- Permission rules: each agent's frontmatter `permission:` block governs tool access. Workers cannot exceed their agent's permissions.

---

## 12. Audit Log

After each multi-model wave, coordinator appends to the session handoff (or dedicated log file):

```
## Multi-Model Wave: <topic>
- Models: [list]
- Task: [1-line summary]
- Verdict: CONSENSUS | CONTRADICTIONS | PARTIAL
- Duration: [wall-clock]
- Key findings: [1-3 bullets]
- Decisions taken: [list or "none"]
- Artifacts: [paths to worker reports if saved]
```

Location: `SESSION_HANDOFF.md` (append) or `research/session-logs/` for project-specific logs.
Purpose: post-mortem traceability. Not a journal — one block per wave, 5-8 lines max.

---

## 13. Cost Guidance

| Model | Relative cost | When justified |
|-------|--------------|----------------|
| **DeepSeek V4 Flash** | **Low** | **Orchestrator (default) + primary writer/coder** — dispatch, routing, synthesis, bulk code, tests, single-file implement |
| GLM 5.2 | Medium | Multi-file implement, architecture, static parity review |
| Qwen 3.8 Max (OpenCode) | High | **Reviewer / архитектор / бизнес-аналитик** — architecture spec, cross-audit, business analysis, deep constraint analysis (NE основной кодер — slow) |
| GPT-5.5 | High | Security/RLS gate, behavioral regression (unique role) |

Budget rule: use cheapest model that can do the task. Escalate to expensive models only when:
- Cross-family review on expensive error (justifies 2-3x cost)
- Multimodal input requires native vision (Qwen 3.8 Max)
- Behavioral semantics gate (GPT-5.5)

Coordinator names models to human BEFORE dispatch — human can veto expensive choices.

---

## References (load on-demand)

- `references/routing.md` — full model routing table, brief templates per model, cross-family pairs, examples
- `references/worker-contract.md` — output contract spec, inject preamble, worker_done format, Orca JSON parsing, worker_done delivery rule
- `references/failure-handling.md` — timeout policy, escalation, self-correction, circuit-breaker
- `references/model-card.md` — model roles + family field + «не путать с» + evidence 1-liners + owner pin + launch pins + Qwen Code
- `references/prohibitions.md` — 11 hard prohibitions with correct alternatives
- **`orca-cli` skill** — terminal ops, worktree management, handoffs. Load via `orca skills get orca-cli`
- **`orchestration` skill** — task/dispatch/wait, worker_done authority, coordinator loops. Load via `orca skills get orchestration`
