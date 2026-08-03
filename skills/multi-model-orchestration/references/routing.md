# Routing — Model Selection & Brief Templates

> Updated: see CHANGELOG.

## Full Routing Table

> **Перед запуском:** проверить доступность модели в `model-card.md`. Пины и статусы меняются.

| Task type | Primary | Family | Alternative | Avoid |
|-----------|---------|--------|-------------|-------|
| Architecture spec (independent) | **Qwen 3.8 Max** + GLM 5.2 (parallel) | Alibaba + Zhipu | — | Same-family pairing |
| Cross-audit of 2 specs | **Qwen 3.8 Max** (default reviewer) | Alibaba | GLM 5.2 | Writer self-review |
| Architecture synthesis / business analysis | **Qwen 3.8 Max** | Alibaba | GLM 5.2 | — |
| Deep code analysis (PHP/CMS/legacy) | **Qwen 3.8 Max** (analyst) | Alibaba | GLM 5.2 | — |
| Single-file implement / bulk code / tests | **DeepSeek V4 Flash** (default writer) | DeepSeek | GLM 5.2 | — |
| Multi-file implement (3+ files) | **GLM 5.2** (default multi-file writer) | Zhipu | DeepSeek V4 Flash (pieces) | — |
| Complex debugging (unknown root cause) | **Qwen 3.8 Max** (analysis) + DeepSeek V4 Flash (implement) | Alibaba + DeepSeek | GLM 5.2 | — |
| Research / SEO / browse | **DeepSeek V4 Flash** (fast) | DeepSeek | Qwen 3.8 Max | — |
| Bulk inventory / meta lists | DeepSeek V4 Flash (orchestrator-scope triage) | DeepSeek | Qwen 3.8 Max | — |
| Cross-QA / review | Different family than writer | — | — | Same family |
| **Security / RLS / auth / Storage review** | **GPT-5.5 + DeepSeek V4 Flash** (parallel) | OpenAI + DeepSeek | Qwen 3.8 Max | **Writer self-review**; single-model gate |
| **Behavioral regression gate** | **GPT-5.5** | OpenAI | — | "Just another reviewer" framing |
| Multimodal (screenshots, images) | Qwen 3.8 Max | Alibaba | — | GLM (text-only), Flash (text-only) |
| Protocol/skill review (3-model) | Qwen 3.8 Max + GLM 5.2 + GPT-5.5 | Alibaba + Zhipu + OpenAI | — | — |

**Evidence (production wave):** same review task ×3 → GPT-5.5 best merge gate (user-scoped idempotency MAJOR); Qwen best RLS (`is_active_user`); Pro best race depth but under-severity on RLS. Synthesis: any MAJOR from any N → fix before merge; prefer stricter severity.

## Production Routing (production-wave experience)

| Task type | Primary | Review/Gate | Notes |
|-----------|---------|-------------|-------|
| **Single-file implement / bulk code / tests** (default) | **DeepSeek V4 Flash** (default writer; fast, cheap, strong 0731) | **Qwen 3.8 Max** (architect/reviewer) ∥ **GPT-5.5** (security) | Writer ≠ reviewer mandatory (cross-family). Flash = primary writer/coder; Qwen = architect/reviewer; GPT-5.5 = security gate. |
| **Multi-file implement** (3+ files) | **GLM 5.2** (default multi-file writer; 1M state continuity) · DeepSeek V4 Flash (single-file pieces) | **Qwen 3.8 Max** + **GPT-5.5** | Owner phrase «сейчас writer=Flash» pins Flash as writer (Qwen/GPT-5.5 review). GLM multi-file = confirmed in production waves (~15 min implement, ~10 min fix-round, build green). |
| **Fidelity port** (generator, vectorizer) | **DeepSeek V4 Flash** (default) · **GLM 5.2** (multi-file swap) | **Qwen 3.8 Max** (architect/analyst) ∥ **GPT-5.5** (hosted semantics/merge gate) | Dual review mandatory (cross-family). Qwen = best architect/reviewer (owner empirical); GPT-5.5 = best behavioral regression gate (caught abort/cost MAJOR GLM missed). |
| **Security / RLS / auth** | **GPT-5.5 + DeepSeek V4 Flash** (parallel) | Qwen 3.8 Max (depth/architecture supplement) | Never single-model security gate. GPT-5.5 = behavioral semantics authority; Flash = fast implementer; Qwen = architecture/depth supplement. |
| **Architecture / synthesis / business analysis** | **Qwen 3.8 Max** (default reviewer/architect) · GLM 5.2 (second line) | — | Qwen = strongest architecture/depth (owner empirical: level ~ Kimi K3, сильнее GLM). |
| **Deep race / ordering / ops unblock** | **DeepSeek V4 Flash** (implement) | **Qwen 3.8 Max** (constraint analysis) + **GPT-5.5** (behavioral semantics) | Qwen for deep constraint analysis; GPT-5.5 for hosted semantics — complementary. |
| **Orchestration / dispatch / handoff** | **DeepSeek V4 Flash** (default) · **GLM 5.2** ⚠️ (owner pin, see model-card.md) | — | Role lock: оркестратор не совмещает оркестрацию с написанием кода в одной задаче. Flash = full orchestrator role (dispatch → wait → gate → synthesize). GLM = ⚠️ tool passivity + drift (agent anti-patterns §4.5). |
| **Implement (default)** | **DeepSeek V4 Flash** | Writer family ≠ reviewer family | Writer ≠ reviewer is mandatory for product code. If owner says "сейчас writer=GLM", pin GLM for multi-file work; "сейчас writer=Flash" — pin Flash for single-file/bulk. |

**Synthesis rules (production evidence-based):**
- **MAJOR or BLOCK from any reviewer → fix-round before In Review.** Do not average away.
- **Contradiction severity** (one PASS/soft, another MAJOR) → prefer the **stricter** finding; re-read evidence paths.
- **Fidelity dual review mandatory:** any behavioral port task (generator, vectorizer, any reference→platform) MUST have dual review (GLM∥Codex) — static parity + hosted semantics are complementary, not redundant. No single-reviewer fidelity port.
- **No live smoke = owner residual gate:** if paid-generation budget prevents live smoke, document explicitly in handoff as RESIDUAL-RISK-OWNER-SMOKE. Do not claim Done without live smoke — claim Done-with-residual.

**Deploy / smoke gate (post-merge or post-deploy handoff):**

**Canonical definition:** wave-spec §Deploy Probe. See also multi-model SKILL.md §2b.

**Principle:** prove the shipped surface exists before signoff. One observable command that proves the artifact reached production. No probe = RESIDUAL-RISK-OWNER-SMOKE.

Adapt the probe to your deploy surface:
- **Web app:** curl route/path endpoints
- **Static site:** curl page URLs after deploy
- **Package/skill:** verify file existence + size at install path
- **API:** curl API endpoints

Evidence: production waves — untracked route files, deployed without tracking → 404.

**Writer Flash ↔ GLM replaceable:**
Owner phrase «сейчас writer=X» (X = Flash or GLM) instantly pins the writer model for the current wave. No skill rewrite needed. Default writer: DeepSeek V4 Flash (fast, cheap, strong 0731). GLM = swap для multi-file implement (1M state continuity, ~15 min implement + ~10 min fix-round, build green). Qwen 3.8 Max = default reviewer/architect (NE writer — slow). See `references/model-card.md` for current roles + launch pins.

## Solo Defaults (when NOT multi)

Use **one** model only. Skip Orca multi-dispatch.

| Situation | Default solo |
|-----------|----------------|
| Clear single deliverable, linear, &lt; 2–3h | Cheapest model that can finish (§1 SOLO) |
| Single-file implement / bulk code / tests | DeepSeek V4 Flash (default writer) |
| Multi-file product implement (3+ files) | GLM 5.2 |
| Fidelity / deep port solo (no dual review budget) | DeepSeek V4 Flash — **document residual risk** (no dual review) |
| Architecture / synthesis / business analysis | Qwen 3.8 Max (analyst/reviewer) |
| Deep race / audit / protocol draft | DeepSeek V4 Flash + Qwen 3.8 Max (analyst) (parallel) |
| Bulk / inventory / triage | DeepSeek V4 Flash (orchestrator-scope) |
| Research / browse / SEO tools | DeepSeek V4 Flash (fast) |
| Security/RLS alone | Prefer dual later; if solo, GPT-5.5 + explicit residual note |

If §1 later says multi (expensive error, parallel pieces) — stop solo and open multi with writer ≠ reviewer.

---

## Brief Templates Per Model

### GLM 5.2 (agent1st_glm)

```
### Goal
[1-2 sentences: what to produce]

### Context
- Files: [paths]
- Current state: [what exists / what's wrong]
- Why: [purpose]

### Constraints
- Do not touch: [boundaries]
- Style: [language, code style]
- Mode: review-only | implement

### Done
- Check: [command or criterion]
- Output format: SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS
```

**Rules:** No 【】. No "think step by step". No persona roleplay. Pair every "don't" with a "do". First sentences = most important (IndexCache).

### DeepSeek V4 Flash (agent1st_v37.3-flash) — orchestrator

```
Задача: [one sentence — what to do]

Где: [files, paths, functions]
Сейчас: [current state / bug]
Должно быть: [expected result]

Контекст: [2-3 sentences — why]

Не трогать: [boundaries]
Mode: review-only | implement
Output: SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS

【思维模式要求】在你的思考过程（think标签内）中，请遵守以下规则：
1. 禁止使用圆括号包裹内心独白，所有分析内容直接陈述即可
2. 禁止以第一人称描写内心活动，请用分析性语言替代
3. 思考内容只包含：约束条件、陷阱识别、工具选择、执行步骤
4. 复杂任务使用结构化分析：UNDERSTAND→ANALYZE→APPROACH→PLAN→CRITIQUE
5. 路径明确时跳过思考，立即执行工具调用
```

**Rules:** 【思维模式要求】 ALWAYS at end (Chinese text is model-specific, not language-dependent). Separate "what" from "why". Better under-structure than over-structure. For trivial triage/dispatch tasks, skip the injection block.

**Language note:** Field names (Задача/Где/Контекст) are Russian by convention for this user's workflow. For non-Russian coordinators, use equivalent structure: Task / Where / Context / Do-not-touch. The 【】 injection block stays in Chinese regardless.

### Qwen 3.8 Max (agent1st_qwen-3.8) — **CURRENT default reviewer / архитектор**

| | |
|--|--|
| **Launch** | `opencode --agent A/agent1st_qwen-3.8` |
| **Agent file** | `~/.config/opencode/agents/A/agent1st_qwen-3.8.md` |
| **Absolute** | `~/.config/opencode/agents/A/agent1st_qwen-3.8.md` |
| **Pin** | **Versionless** — skills always pin `A/agent1st_qwen-3.8`. Versioned `v5.1` / `v5.2` files may remain on disk as history/rollback only, never the launch target for new work. |
| **Protocol** | Production-wave JUDGMENT patches (runtime-boundary fidelity, self-skepticism, evidence hygiene, brief-as-plan, written≠persisted, …) live **inside the agent file** — bumping the protocol does not require a skill edit. |
| **Benchmarks (2026-08-03)** | Vendor (qwen.ai/blog): GPQA-D 92.6 · Terminal-Bench 2.1 86.6 · OSWorld-V 86.1 · IFBench 82.8 · SWE-bench Pro 67.7 (Fable 5: 80.0). Independent verification pending — role остаётся owner-decided. ⚠️ не путать с 3.7 Max (SWE-bench 80.4 / GPQA 92.4 — другая модель). |


```
### Context
[Background, files involved, why this matters]

### Objective
[1-2 sentences: concrete goal, verb-first]

### Steps
1. [step 1]
2. [step 2]
3. [step 3]

### Examples
[If structured output needed: input → expected output]

### Response Format
SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS
Mode: review-only | implement

### Constraints
[Boundaries, what not to touch]
```

**Rules:** CoT works ("разбери шаг за шагом"). Few-shot examples > constraints. Separators ### help parsing. Prompt chaining > mega-prompt for complex tasks.

### Qwen Code (qwen --approval-mode yolo)

| | |
|--|--|
| **Launch** | `qwen --approval-mode yolo` |
| **Family** | Alibaba |
| **Effort** | `/effort medium` (implement) · `/effort xhigh` (review/analysis) |
| **Orchestration** | Native: worker_done, heartbeat, escalation |
| **Approval** | `--approval-mode yolo` MANDATORY for Orca worker |
| **Cross-family review** | Reviewer: GLM 5.2 or GPT-5.5 (NOT OpenCode Qwen — same family) |

Brief format: standard worker-contract (ROLE/MODE/TASK/DONE/OUTPUT).
Qwen Code does not require model-specific wrapping — native CoT, understands structured briefs.

---

## GPT-5.5 — Behavioral Regression Gate (unique role)

GPT-5.5 is NOT "just another reviewer". Unique role: behavioral regression gate.
- Production waves: caught abort/cost MAJOR that GLM's static review missed
- Production waves: caught UNIQUE(user_id,nonce) cross-user MAJOR
- Hosted-semantics gate: checks what static parity misses

**Mandatory in:**
- Security / RLS / auth review (parallel with Qwen Max)
- Fidelity port merge gate (GLM static ∥ GPT-5.5 behavioral)
- Any task with behavioral semantics (abort, cost, state transitions)

**Launch:** `codex` (native CLI, not OpenCode agent)
**Family:** OpenAI

### GPT-5.5 brief template

```
### Goal
[1-2 sentences: what to review — behavioral semantics focus]

### Success
- Acceptance: [what must be true for behavioral correctness]
- Validation: [test / command / state transition check]

### Context
- Files: [paths]
- Evidence: [what's known about behavioral semantics]

### Constraints
- Invariants: [hard rules — abort, cost, state transitions]
- Do not touch: [boundaries]

### Autonomy
- Mode: Research only
```

**Rules:** Lean contracts. Goal + Success carry load. Focus on behavioral semantics (abort, cost, state transitions) — not static parity (that's GLM's job). No 【】. No "think step by step".

---

## Qwen Code vs OpenCode Qwen

| | Qwen Code | OpenCode Qwen |
|--|-----------|---------------|
| CLI | `qwen` | `opencode --agent A/agent1st_qwen-3.8` |
| Family | Alibaba | Alibaba |
| Mode | `/effort medium\|high\|xhigh\|max` | `/variants default\|low\|medium\|xhigh` |
| Approval | `--approval-mode yolo` mandatory | `--auto` or allow-rules |
| Orchestration | Native worker_done | Via inject preamble |
| Cross-family review | Reviewer: GLM / Codex | Reviewer: GLM / Codex |
| **Do NOT assign** | As reviewer for OpenCode Qwen (same family) | As reviewer for Qwen Code (same family) |

---

## Cross-Family Pairs (writer.family ≠ reviewer.family)

| Writer | Family | Valid reviewers | Invalid reviewers |
|--------|--------|----------------|-------------------|
| Qwen Code | Alibaba | GLM 5.2, GPT-5.5 | OpenCode Qwen (Alibaba) |
| Qwen 3.8 Max | Alibaba | GLM 5.2, GPT-5.5 | OpenCode Qwen (Alibaba) |
| GLM 5.2 | Zhipu | Qwen Code, Qwen 3.8 Max, GPT-5.5 | — |
| GPT-5.5 | OpenAI | Qwen Code, Qwen 3.8 Max, GLM 5.2 | — |

**Rule:** writer.family ≠ reviewer.family. Violation = blind-spot risk (production-wave evidence).

---

## Multi-Model Review Pattern (3-model consensus)

For protocol/skill/architecture review:

1. Dispatch SAME task to 3 models in parallel (GLM + Qwen 3.8 Max + GPT-5.5).
2. Each produces independent review (no anchoring on others' output).
3. Coordinator synthesizes: consensus items (high confidence), contradictions (human decides), gaps (one found, others missed).
4. Consensus blocker → fix immediately. Non-consensus → backlog.

Independent parallel generation prevents anchoring — each model produces its review without seeing others' output.

### Synthesis severity rule (post real dual-review waves)

- **MAJOR or BLOCK from any reviewer** → fix-round before merge / In Review. Do not average away.
- On **contradiction** (one PASS/soft, another MAJOR): prefer the **stricter** finding; re-read evidence paths.
- **Security/RLS/auth:** do not close on a single-model approve without an explicit residual note.
- Append short post-mortem to project handoff when a wave teaches a routing lesson (experience → next wave).