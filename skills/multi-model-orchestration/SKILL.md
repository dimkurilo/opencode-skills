---
name: multi-model-orchestration
description: >-
  Coordinate 2+ AI models (GLM 5.2, DeepSeek V4 Pro/Flash, Qwen 3.8 Max, Grok 4.5,
  Codex 5.5, GPT-5.6) for parallel review, cross-validation, or bulk work via Orca
  orchestration. Use when the coordinator says "обсудите этот вопрос с 2 моделями",
  "multi-model review", "cross-validate with N models", "parallel architecture specs",
  or any task requiring independent perspectives from different model families.
  Do NOT use for single-model tasks, trivial edits, or when §1 decision tree says solo.
---

# Multi-Model Orchestration

Coordinator dispatches tasks to 2+ model workers via Orca, waits for results, synthesizes.
Coordinator NEVER implements — only routes, waits, gates, synthesizes.
Coordinator = any model with this skill loaded. This skill does not prescribe coordinator family.

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
2. In each terminal: launch the model's CLI (`opencode`, `claude`, `grok`, etc.).
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

| Work | Route to | Why |
|------|----------|-----|
| Deep analysis, cross-audit, verification points | **DeepSeek V4 Pro** | 1M context, structured thinking |
| Long multi-file implement, architecture synthesis | **GLM 5.2** | 1M state continuity, long-horizon |
| Complex analysis, multimodal, cross-examination, **fidelity writer** | **Qwen 3.8 Max** | 2.4T weights, native vision, CoT; default fidelity port writer (§2c) |
| Security / RLS / auth / Storage review | **Codex 5.5 + Qwen Max** (+ Pro for depth) | Gate + RLS; not Pro-only (I4 lesson) |
| Fast research, SEO/tools, speed loops | **Grok 4.5** | Speed, tool-native |
| Bulk mechanical, inventory, simple edits | **DeepSeek V4 Flash** | Cheap, fast |
| Lean contracts, outcome-focused coding | **GPT-5.6** | Goal+Success, lean prompts |
| Cross-QA (review someone else's work) | **Different family** | Blind-spot detection |
| **Fidelity port** (generator, vectorizer, reference→platform) | **Qwen 3.8 Max** write · **GLM 5.2** ∥ **Codex 5.5** review | [TICKET] evidence: Qwen byte-identical prompt matrix; GLM exhaustive static parity; Codex behavioral regression gate (caught abort/cost MAJOR). Dual review mandatory — complementary, not redundant |
| **Orchestration / dispatch / handoff** | **Grok 4.5** | Orchestrator NEVER implements (§3 role lock). Dispatch → wait → synthesize → gate |

**Writer replaceable:** owner phrase «сейчас writer=X» (GLM or Qwen) pins writer instantly — no skill rewrite. Both have confirmed fidelity-implementer capability. See `references/routing.md` for the full [platform] routing table with evidence anchors.

Synthesis: MAJOR from any reviewer → fix before merge; prefer stricter severity on contradictions.

Full routing details + brief templates: `references/routing.md`.

---

## 2b. Deploy / smoke gate (prove surface exists before signoff)

**Principle:** after merge/deploy (or skill install), prove the shipped surface exists before handoff. Do not claim Done on a missing route, missing skill file, or dead install path.

Adapt the probe to the target stack. **Canonical examples** (web curl dual-pattern + skills-repo check): `references/routing.md` → **Deploy / smoke gate**.

Evidence: [TICKET] had untracked route files (balance, refine) — if deployed without tracking, 404. The same class of bug is "claimed done, surface missing."

---

## 2c. Fidelity Port Rules ([platform] mandatory)

Any task labeled "fidelity port" / "reference→platform" / "behavioral parity":
1. **Dual review mandatory:** GLM 5.2 (static parity, file:line matrix) ∥ Codex 5.5 (hosted semantics, cost/state regressions). Single-reviewer fidelity ports are NOT accepted. [TICKET] evidence: GLM-only would have missed abort MAJOR; Codex-only would have missed normTemperature + refine edge.
2. **Writer = Qwen 3.8 Max** (default) or GLM 5.2 (owner override). Both confirmed fidelity-capable. Flash = explicitly excluded (simplifies, per I3 post-mortem).
3. **MAJOR any → fix round before In Review.** Codex MAJOR rated on behavioral semantics carries equal weight to GLM's static findings.
4. **No live smoke = RESIDUAL-RISK-OWNER-SMOKE** in handoff. If paid-generation budget prevents live smoke ([TICKET] pattern), document explicitly. Do not claim Done — claim Done-with-residual.
5. **Deploy gate:** prove shipped surface before handoff (§2b / routing.md).

---

## 2d. Lifecycle — Done vs In Review vs On Prod

| State | Definition | Gate |
|-------|-----------|------|
| **Implement done** | Writer finished, build/tsc/lint green, own notes written; **every claimed path exists on disk** | Before `worker_done`: `git status --short` and/or `ls`/`wc -l` prove each CHANGES path. Claimed-but-missing = FAIL (written≠persisted). Then `worker_done` + implement notes |
| **In Review** | Dual review passed (0 MAJOR or all MAJOR fixed), fix-round complete if any MAJOR | Synthesis: stricter wins, all MAJOR closed |
| **Commit + PR** | Public paths committed to branch, PR opened, reviewable | `git add skills/<name>/` only; `git status` clean of dev files. No merge yet |
| **Merge** | PR approved, merged to main | Merge gate: CI green, no unresolved review threads |
| **Deploy gate passed** | `curl` new routes ≠ 404, Vercel build green (or target platform deploy confirmed) | §2b deploy gate |
| **On prod (owner residual)** | Deployed, smoke-tested by orchestrator OR owner | No live smoke = RESIDUAL-RISK-OWNER-SMOKE ([TICKET] pattern). Owner or next session handles production smoke |
| **Done (complete)** | All gates above passed, handoff written, Linear updated | Orchestrator signs off |

Do not equate "writer claims Done" with "In Review passed" or "prod-ready". Do not collapse commit/PR/merge into "writer Done" — each gate is independent and verified. Fidelity dual review (§2c) is mandatory between implement and In Review.

**Explicit ordering:** Implement done → In Review → commit public paths → PR → merge → Deploy gate → On prod (owner smoke OR RESIDUAL-RISK-OWNER-SMOKE) → Done. Commit, PR, merge, and deploy are separate verify-then-advance gates — do not batch them into a single step.

---

## 3. Coordinator Loop

```
1. CLASSIFY task → solo or multi (§1)
2. SELECT models (§2) — name them explicitly to human
3. CREATE terminals (one per worker, same worktree)
4. BUILD briefs (model-specific pattern — see references/routing.md)
5. DISPATCH: task-create --spec "<brief>" → dispatch --inject
6. WAIT: check --wait --types worker_done,escalation,decision_gate
7. GATE: read artifacts → synthesize → decide next
8. REPORT to human: consensus / contradictions / gaps
```

### Role Lock (coordinator session)

```
ORCHESTRATOR: dispatch → wait → synthesize → gate.
Review-only worker_done ≠ right to edit files. Implement = new task.
Heartbeat ≠ done. One timeout ≠ fail → liveness check → wait again.
Max 3 workers per wave. Do not "help" workers by editing in coord session.
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

Model-specific wrapping:
- **GLM 5.2**: Goal → Context → Constraints → Done. No 【】. No "think step by step".
- **DeepSeek**: Задача → Где → Контекст → Не трогать + 【思维模式要求】 at end.
- **Qwen**: Context → Objective → Steps → Examples → Response Format. CoT ok.
- **Grok**: Task → Done. Lean.
- **GPT-5.6**: Goal → Success → Context → Constraints → Autonomy → Stop.

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

1. Coordinator writes code "while worker thinks"
2. 3 models on a linear task
3. Restart worker because of silence
4. Flash-only on complex core without file access
5. OpenCode subagents confused with Orca multi-model
6. Cross-QA "always" without expensive error → cost without gain
7. Slash-commands through `orca terminal send` (they don't work — use plain text briefs)
8. Treating brief template labels as fixed-language (structure is language-agnostic; labels match coordinator's working language per §8)
9. Claiming files in CHANGES/`worker_done` without disk proof (written≠persisted — [TICKET]). Verify with `git status`/`ls` first

---

## 10. Orca Commands Quick Reference

```bash
# Create worker terminal (same worktree)
orca terminal create --worktree active --title worker-<name> --command "opencode" --json
orca terminal wait --terminal <handle> --for tui-idle --timeout-ms 60000 --json

# Dispatch task
orca orchestration task-create --spec "<brief>" --json
orca orchestration dispatch --task <id> --to <handle> --inject --json

# Wait for completion
orca orchestration check --wait --types worker_done,escalation,decision_gate --timeout-ms 900000 --json

# Liveness check (on timeout)
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
| DeepSeek V4 Flash | Low | Bulk, mechanical, inventory |
| Grok 4.5 | Low-Medium | Speed-critical, research |
| DeepSeek V4 Pro | Medium | Deep analysis, cross-audit |
| GLM 5.2 | Medium | Long multi-file, architecture |
| Qwen 3.8 Max | High | Complex reasoning, multimodal, fidelity writer, cross-examination |
| Codex 5.5 | High | Security/RLS gate, behavioral regression, fidelity merge gate |
| GPT-5.6 | High | Lean outcome-focused, pro mode |

Budget rule: use cheapest model that can do the task. Escalate to expensive models only when:
- Task requires depth Flash/Grok cannot provide
- Cross-family review on expensive error (justifies 2-3x cost)
- Multimodal input requires native vision (Qwen Max only)

Coordinator names models to human BEFORE dispatch — human can veto expensive choices.

---

## References (load on-demand)

- `references/routing.md` — full model routing table, brief templates per model, examples
- `references/worker-contract.md` — output contract spec, inject preamble, worker_done format
- `references/failure-handling.md` — timeout policy, escalation, self-correction, circuit-breaker
- `references/model-card.md` — model roles + «не путать с» + evidence 1-liners + owner pin + launch pins
<!-- Changelog: v1.0 · v1.1 MCP/audit/cost · v1.2 dispatch fix · v1.3 [platform] · v1.4 model-card · v1.5 Qwen postmortem P0–P2: live worker_done CLI, written≠persisted gate, Codex/GPT launch pins, README model-card, cost Codex, deploy gate principle + canonical routing curl, heartbeat §5, Solo Defaults, fidelity writer in §2 -->
