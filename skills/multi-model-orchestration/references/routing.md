# Routing — Model Selection & Brief Templates

## Full Routing Table

| Task type | Primary | Alternative | Avoid |
|-----------|---------|-------------|-------|
| Architecture spec (independent) | GLM 5.2 + DeepSeek Pro (parallel) | Qwen Max | Flash |
| Cross-audit of 2 specs | DeepSeek Pro | Qwen Max | Flash |
| Architecture synthesis | GLM 5.2 | Qwen Max | Flash |
| Deep code analysis (PHP/CMS/legacy) | DeepSeek Pro | GLM 5.2 | Flash (without files) |
| Multi-file implement (3+ files) | GLM 5.2 | Grok 4.5 | Flash |
| Complex debugging (unknown root cause) | Qwen 3.8 Max | DeepSeek Pro | Flash |
| Research / SEO / browse | Grok 4.5 | Qwen Max | — |
| Bulk inventory / meta lists | Flash | Grok 4.5 | Pro (waste) |
| Cross-QA / review | Different family than writer | — | Same family |
| **Security / RLS / auth / Storage review** | **Codex 5.5 + Qwen Max** (parallel) | + DeepSeek Pro for race/depth | **Pro-only** as sole security gate; writer self-review |
| Multimodal (screenshots, images) | Qwen 3.8 Max | — | GLM (text-only) |
| Lean outcome-focused coding | GPT-5.6 | Grok 4.5 | — |
| Protocol/skill review (3-model) | GLM + DeepSeek Pro + Qwen Max | — | — |

**Evidence ([client-project] I4, 2026-07-25):** same review task ×3 → Codex best merge gate (user-scoped idempotency MAJOR); Qwen best RLS (`is_active_user`); Pro best race depth but under-severity on RLS. Synthesis: any MAJOR from any N → fix before merge; prefer stricter severity.

## [platform] Routing ([client-project] — experience I3–[TICKET])

| Task type | Primary | Review/Gate | Notes |
|-----------|---------|-------------|-------|
| **Fidelity port** (generator, vectorizer) | **Qwen 3.8 Max** | **GLM 5.2** (static parity) ∥ **Codex 5.5** (hosted semantics/merge gate) | Qwen confirmed strong fidelity writer ([TICKET]: 5832-case byte-identical prompt matrix, build/tsc green). GLM = best static parity auditor; Codex = best behavioral regression gate (caught abort/cost MAJOR GLM missed). Flash = explicitly excluded on fidelity ports (simplifies, per I3 post-mortem). |
| **Security / RLS / auth** | **Codex + Qwen Max** (parallel) | + Pro for depth/race analysis | **Never Pro-only as sole security gate** (I4 lesson: Pro under-severity'd disabled-user SELECT + global nonce as PASS/soft, while Codex/Qwen rated MAJOR). Pro = correctness/depth supplement, not gate authority. |
| **Architecture multi-file** (3+ files) | **GLM 5.2** (default) | Pro + Codex or Qwen | OR **Qwen 3.8 Max** if owner says "fidelity override" or "Qwen writer" — owner phrase pins without skill rewrite. GLM multi-file = confirmed I4/I5 (~15 min implement, fix-round ~10 min, build green). |
| **Deep race / ordering / ops unblock** | **DeepSeek V4 Pro** | **Codex 5.5** (semantics) | Pro = best depth on race conditions, lock ordering, constraint matrices. NOT sole merge gate — pair with Codex for behavioral semantics. |
| **Bulk / mechanical / hotfix** | **DeepSeek V4 Flash** | — | Flash only on bulk, 1-2 file hotfixes, inventory, mechanical tasks. Not primary multi-file (I3 post-mortem: edge-case bugs, lock leaks, almost-right-then-hotfix pattern). |
| **Orchestration / dispatch / handoff** | **Grok 4.5** | — | Orchestrator NEVER implements code. Role lock: dispatch → wait → synthesize → gate → Linear/handoff. |
| **Implement (post-I6 default)** | **GLM 5.2** or owner re-pick | Writer family ≠ reviewer family | Writer ≠ reviewer is mandatory for product code. If owner says "сейчас writer=Qwen", pin Qwen for the session. |

**Synthesis rules ([platform], evidence-based):**
- **MAJOR or BLOCK from any reviewer → fix-round before In Review.** Do not average away.
- **Contradiction severity** (one PASS/soft, another MAJOR) → prefer the **stricter** finding; re-read evidence paths.
- **Pro under-severity note:** Pro trends toward depth on correctness but under-severity on security/behavioral regressions (I4 evidence). If Pro rates something O*/soft while Codex/Qwen rate MAJOR → take stricter. Never Pro-only on security/auth/RLS gate.
- **Fidelity dual review mandatory:** any behavioral port task (generator, vectorizer, any reference→platform) MUST have dual review (GLM∥Codex) — static parity + hosted semantics are complementary, not redundant ([TICKET] evidence). No single-reviewer fidelity port.
- **No live smoke = owner residual gate:** if paid-generation budget prevents live smoke ([TICKET] pattern), document explicitly in handoff as RESIDUAL-RISK-OWNER-SMOKE. Do not claim Done without live smoke — claim Done-with-residual.

**Deploy gate ([platform], post-merge):**
Before handoff to NEXT_SESSION after merge: run one curl check that new routes return ≠ 404. `307 → /login` is OK (route exists, redirects). `404` = route missing → fix before handoff.
```bash
# Auth-protected routes — prove route exists behind auth (no -L so redirect is the proof):
curl -sI https://<deploy-url>/api/<new-route> | head -1
# Expected: HTTP/... 307 (redirect to login = route exists) or 302.
# 404 = route missing → fix before handoff.

# OR probe final status (follow redirects, get final HTTP code + effective URL):
curl -sIL -o /dev/null -w '%{http_code} %{url_effective}\n' https://<deploy-url>/api/<new-route>
# Interpret: final 200/307/401/403 ≠ 404 = route exists.
# final 404 = route missing.
```

**Writer GLM ↔ Qwen replaceable:**
Owner phrase «сейчас writer=X» (X = GLM or Qwen) instantly pins the writer model for the current wave. No skill rewrite needed. The orchestrator reads this phrase from NEXT_SESSION §2 or owner chat and routes accordingly. Both GLM and Qwen have confirmed fidelity-writer capability ([TICKET]: Qwen write/GLM review; I4/I5: GLM write/Codex∥Pro review). The model card in docs/orchestration/ tracks current writer capabilities.

## Solo Defaults (when NOT multi)
---

## Brief Templates Per Model

### GLM 5.2 (agent1st_v13-glm)

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

### DeepSeek V4 Pro / Flash (agent1st_v36-pro / v36-flash)

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

**Rules:** 【思维模式要求】 ALWAYS at end (Chinese text is model-specific, not language-dependent). Separate "what" from "why". Better under-structure than over-structure. Flash: skip injection for trivial tasks.

**Language note:** Field names (Задача/Где/Контекст) are Russian by convention for this user's workflow. For non-Russian coordinators, use equivalent structure: Task / Where / Context / Do-not-touch. The 【】 injection block stays in Chinese regardless.

### Qwen 3.8 Max (agent1st_v5.2-qwen-3.8) — **CURRENT default**

| | |
|--|--|
| **Launch** | `opencode --agent A/agent1st_v5.2-qwen-3.8` |
| **Agent file** | `~/.config/opencode/agents/A/agent1st_v5.2-qwen-3.8.md` |
| **Absolute** | `/Users/dimk/.config/opencode/agents/A/agent1st_v5.2-qwen-3.8.md` |
| **v5.1** | **Do not use for new work** — historical/rollback only |
| **v5.2 delta** | v5.1 + [TICKET] JUDGMENT patches (runtime-boundary fidelity, self-skepticism, evidence hygiene, brief-as-plan, written≠persisted, …) |


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

### Grok 4.5

```
### Task
[1-2 sentences, verb-first: what to get]

### Context
- Files: [paths]
- Now: [state]

### Done
- Acceptance: [criterion]
- Deliverable: SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS

### Autonomy
- Mode: Execute | Plan first | Research only
```

**Rules:** Lean. Task + Done carry the load. No think-directives. No persona in user-prompt.

### GPT-5.6

```
### Goal
[1-2 sentences, verb-first: user-visible outcome]

### Success
- Acceptance: [what must be true]
- Validation: [test / command]

### Context
- Files: [paths]
- Evidence: [what's known / what's missing]

### Constraints
- Invariants: [hard rules only]
- Do not touch: [boundaries]

### Autonomy
- Mode: Research only | Plan first | Execute
```

**Rules:** Lean contracts. Goal + Success carry load. No 【】. No "think step by step". No thick scaffolding.

---

## Multi-Model Review Pattern (3-model consensus)

For protocol/skill/architecture review:

1. Dispatch SAME task to 3 models in parallel (GLM + DeepSeek Pro + Qwen Max).
2. Each produces independent review (no anchoring on others' output).
3. Coordinator synthesizes: consensus items (high confidence), contradictions (human decides), gaps (one found, others missed).
4. Consensus blocker → fix immediately. Non-consensus → backlog.

Independent parallel generation prevents anchoring — each model produces its review without seeing others' output.

### Synthesis severity rule (post real dual-review waves)

- **MAJOR or BLOCK from any reviewer** → fix-round before merge / In Review. Do not average away.
- On **contradiction** (one PASS/soft, another MAJOR): prefer the **stricter** finding; re-read evidence paths.
- **Security/RLS/auth:** do not close on a single Pro-only approve if Codex/Qwen unavailable without an explicit residual note.
- Append short post-mortem to project handoff when a wave teaches a routing lesson (experience → next wave).