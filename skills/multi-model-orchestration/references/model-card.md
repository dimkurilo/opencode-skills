# Model Card — Multi-Model Orchestration

> **What this IS:** Evidence-based role map. 30-second reference: who does what, what to never confuse.
> **What this is NOT:** Capability rankings. ★★★★★ beauty contests. Roles differ, not "smarter."

Source: production-wave post-mortems + current stack. Self-contained — reads without any product checkout.
Updated: see CHANGELOG.

---

## Agent pins (launch from this skill alone)

> **Правило доступности:** перед запуском любой модели проверить её статус в этой таблице.
> Доступность может меняться (временные ограничения тарифа, новые лимиты).
> Модель помечена ⚠️ — временно недоступна, использовать замену.
> Модель без пометки — доступна, запускать по указанному пину.

| Model | Family | Pin / CLI | Launch (Orca terminal or shell) |
|-------|--------|-----------|----------------------------------|
| **DeepSeek V4 Flash** | DeepSeek | OpenCode `A/agent1st_v37.3-flash` | `opencode --agent A/agent1st_v37.3-flash` · fallback: `-m opencode-go/deepseek-v4-flash` |
| **Qwen 3.8 Max** | Alibaba | OpenCode agent **`A/agent1st_qwen-3.8`** (versionless) | `opencode --agent A/agent1st_qwen-3.8` |
| **GLM 5.2** | Zhipu | OpenCode `A/agent1st_glm` | `opencode --agent A/agent1st_glm` · fallback model: `-m zai-coding-plan/glm-5.2` |
| **GPT-5.5** | OpenAI | native `codex` CLI (not an OpenCode `A/` agent) | `orca terminal create --command "codex" --json` · or shell `codex` · optional: `codex --model gpt-5.5` / effort flags per host |

**LAUNCH РЕЦЕПТ (SoT — проверено 2026-08-06; `--variant` НЕ существует для TUI-argv opencode, только для `opencode run`):**

Для **OpenCode TUI-воркера через Orca** (dispatch --inject обязателен):
1. `terminal create` — worktree active, command = `opencode --agent A/<agent>` **БЕЗ `--variant`** (TUI его не принимает — выведет help)
2. `terminal wait --for tui-idle` — timeout 60s
3. variant задаётся slash-командой ВНУТРИ TUI: `terminal send --text "/variants <variant>" --enter` + `sleep 3` (MANDATORY, race prevention). **ИСКЛЮЧЕНИЕ из запрета terminal send**: запрет относится к ДОСТАВКЕ ЗАДАЧИ (текст брифа в TUI уходит в shell), установка variant через `/variants` — допустима
4. `task-create` — spec = brief file → `dispatch --task --to --inject` → `check --wait`

Для **codex-воркера**: effort задаётся флагом при запуске (`codex --model gpt-5.5 -c model_reasoning_effort="high"` / `gpt-5.6-luna ... "max"`), `sleep 3`.

Per-model variant values: GLM `low|medium|high|xhigh|max`; Qwen 3.8 Max `default|low|medium|xhigh`; DeepSeek `default|minimal|high` (проверить актуальный список `/variants` в TUI).

**headless** (`opencode run --agent A/<agent> --variant <v> --auto ...`) — работает, но НЕ даёт lifecycle preamble/worker_done: только для ручного fallback, НЕ для оркестрации.

**SoT-правило:** этот блок — единственный источник launch-рецепта. LAUNCH.md.tmpl шаг 3 и multi-model SKILL.md §10 ссылаются сюда, без дублирования.

**OpenCode agents** live under `~/.config/opencode/agents/` (nested `A/` → launch name **`A/<stem>`**, e.g. `A/agent1st_qwen-3.8`).  
**Qwen versionless pin:** skills always pin `A/agent1st_qwen-3.8`. Versioned `v5.3` files may remain as history/rollback only. Protocol patches (incl. written≠persisted) live **inside the agent file** — bumping protocol does not require a skill edit.

**Codex is not a missing pin:** it is **outside** OpenCode agent files. Security gate and fidelity merge gate still **route to GPT-5.5** via the native `codex` CLI above. Do not invent a fake `A/agent1st-codex` unless the host actually provides one.

**written≠persisted is a skill-wide worker gate**, not only a Qwen patch — see `worker-contract.md` and SKILL.md §2d.

---

## 30-Second Role Table

| Model | Role | Не путать с | Evidence 1-liner |
|-------|------|-------------|------------------|
| **DeepSeek V4 Flash** (`agent1st_v37.3-flash`) | **Orchestrator (default)** · dispatch → wait → gate → synthesize; **primary writer/coder + tester (default)** — single-file, bulk code, tests | Multi-file heavy implement (→ GLM), judgment/architecture review (→ Qwen) | Role: owner decision. Benchmarks (see §Benchmarks): code confirmed (SWE-bench 79.0 Flash-Max indep, LiveBench Coding 69.2); **agentic/review NOT confirmed** (Terminal-Bench/DSBench vendor-only, Agentic Coding 37.6, GPQA-D 71.2 ≪ GLM/GPT-5.5). Role lock: does not combine orchestration with writing code in the same task. Fast + cheap ($0.14/$0.28 per 1M) — default writer/coder for new work. |
| **Qwen 3.8 Max** (`agent1st_qwen-3.8`) | **Reviewer / архитектор / бизнес-аналитик (default reviewer)** · Architecture spec · Cross-audit · Business analysis · RLS reviewer | Bulk code writer (slow), fast single-file implement, long-session undisciplined runs | Role: **owner decision + vendor benchmarks (qwen.ai/blog, 2026-08-03) + anecdotal**; independent verification pending. Specs [blog 2026-08-03]: 2.4T sparse MoE, **95B active**; context 1M (blog config; docs.qwencloud.com ранее: 983,616; max output 131,072); reasoning_effort xhigh/medium/low (default xhigh); multimodal input; **first open-weight Max-class** (веса обещаны «next week» на HF/ModelScope; на 2026-08-03 не вышли). Vendor benches: GPQA-D **92.6**, Terminal-Bench 2.1 **86.6**, OSWorld-V **86.1**, IFBench **82.8**, PaperBench **93.0**; слабее: SWE-bench Pro 67.7 (Fable 5: 80.0), FrontierSWE 73.5 (88.8), HLE 43.6 (53.3). ⚠️ do NOT confuse with Qwen 3.7 Max (SWE-bench 80.4, GPQA 92.4 — другая модель). Anecdotal: StackPerf 80/100 vs Kimi K3 83; KingBench 65/80; 36kr 4/6 (фейковое решение в «карусели»). Owner empirical: level ~ Kimi K3, сильнее GLM 5.2 в architecture/depth. NE основной кодер (slow: «slowest model I've used» — Wiegold). Production-wave evidence: caught `is_active_user()` MAJOR, deep race/ordering analysis. **Перед запуском проверить доступность.** |
| **GLM 5.2** (`agent1st_glm`) | **Multi-file writer (default для 3+ файлов)** · second-line reviewer (architecture-heavy waves) · static-parity reviewer | Sole orchestrator, fast bulk code | Role: benchmark-supported. AAII 51 (open-weight leader, indep); GPQA-D 91.2; LiveBench 73.2 (indep). Production waves: ~15 min multi-file implement, ~10 min fix-round, build green; 40+ verification points, 9 functions byte-checked, 0 false positives. Second-line reviewer когда Qwen недоступен или для перекрёстной проверки architecture. **Перед запуском проверить доступность** — возможны временные ограничения тарифа. |
| **GPT-5.5** | Merge gate · Behavioral regression gate · Security/RLS | "Just another reviewer" | Role: benchmark-supported. AAII 55 (indep); GPQA-D 93.6; OSWorld 78.7; BrowseComp 84.4. Production waves: caught UNIQUE(user_id,nonce) cross-user MAJOR + abort/cost MAJOR that GLM's static review missed. Best hosted-semantics gate — unique role, not redundant. |

---

## Owner Pin (Writer Replaceability)

**Owner phrase instantly pins the session writer — no skill rewrite, no routing table change.**

- **«сейчас writer=Flash»** / **«writer=DeepSeek»** → DeepSeek V4 Flash is the writer for this session/wave (default; fast, cheap, strong on benchmarks 0731). Qwen becomes reviewer.
- **«сейчас writer=GLM»** → GLM 5.2 is the writer for this session/wave (multi-file / architecture-heavy waves; 1M state continuity). Qwen becomes reviewer.

**Default writer: DeepSeek V4 Flash.** GLM = swap для multi-file implement. Qwen 3.8 Max = reviewer/architect по умолчанию, NE writer (slow).

Confirmed fidelity-capable writers: Flash (production waves: bulk code, tests, fast iteration), GLM (production waves: multi-file architecture, ~15 min implement + ~10 min fix-round, build green). Qwen = reviewer/architect (production waves: caught `is_active_user()` MAJOR, deep race/ordering analysis).

The orchestrator reads the owner pin and routes accordingly. The model card documents current capability — it does not encode a permanent assignment.

## Owner Pin — Reviewer

**«сейчас reviewer=X» instantly pins the session reviewer. Default: Qwen 3.8 Max.**

- **«сейчас reviewer=Qwen»** → Qwen 3.8 Max (default reviewer; архитектор / бизнес-аналитик; owner empirical: level ~ Kimi K3, сильнее GLM в architecture)
- **«сейчас reviewer=GLM»** → GLM 5.2 (second-line reviewer; benchmark-supported static parity, AAII 51; ⚠️ возможны временные ограничения тарифа)
- **«сейчас reviewer=GPT-5.5»** → GPT-5.5 (security/fidelity merge gate only — NOT general reviewer)

## Owner Pin — Orchestrator

**«сейчас orchestrator=X» instantly pins the session orchestrator. Default: DeepSeek V4 Flash.**

- **«сейчас orchestrator=Flash»** / **«orchestrator=DeepSeek»** → DeepSeek V4 Flash (default, DeepSeek family, full orchestrator role: dispatch → wait → gate → synthesize)
- **«сейчас orchestrator=Qwen»** → Qwen 3.8 Max (2.4T weights, CoT, vision)
- **«сейчас orchestrator=GLM»** → GLM 5.2 (1M state continuity, Self-Harness. ⚠️ Watch: tool passivity, session drift, overthinking — agent anti-patterns §4.5). Best for architecture-heavy waves.

**Flash = default orchestrator + default writer/coder (full role):** DeepSeek V4 Flash (`A/agent1st_v37.3-flash`) serves as the **default orchestrator** AND **default writer/coder** — full orchestrator role (dispatch → wait → gate → synthesize) + primary writer on single-file, bulk code, and tests. Fast ($0.14/$0.28 per 1M), strong on 0731 benchmarks. Role lock: оркестратор не совмещает оркестрацию с написанием кода в одной задаче; переключение (оркестратор → writer) — явным owner-pin решением («сейчас orchestrator=X» или «сейчас writer=Flash»). Multi-file (3+) сложные правки → GLM (default multi-file writer).

The orchestrator pin affects:
- NEXT_SESSION copy-paste block format (Flash: Задача/Где/Должно быть/Не трогать, Qwen: Context/Objective/Constraints, GLM: Goal/Context/Constraints/Done)
- LAUNCH.md default orchestrator in tools table
---

## Stack Composition

| Task type | Writer | Review | Notes |
|-----------|--------|--------|-------|
| **Single-file implement / bulk code / tests** | **DeepSeek V4 Flash** (default) · GLM 5.2 (multi-file swap) | Qwen 3.8 Max ∥ GPT-5.5 (security) | Flash = fast, cheap, strong on 0731 benchmarks. Writer ≠ reviewer — cross-family. |
| **Multi-file implement** (3+ files) | **GLM 5.2** (default) · DeepSeek V4 Flash (single-file pieces) | Qwen 3.8 Max + GPT-5.5 | GLM = 1M state continuity + multi-file specialty. Writer ≠ reviewer mandatory. Owner pin overrides default. |
| **Fidelity port** | DeepSeek V4 Flash (default) · GLM 5.2 (multi-file swap) | **Qwen 3.8 Max** (architect/analyst) ∥ GPT-5.5 (hosted semantics) | Dual review mandatory. Writer ≠ reviewer — cross-family. |
| **Security / RLS / auth** | GPT-5.5 + DeepSeek V4 Flash (parallel) | Qwen 3.8 Max (depth supplement) | Never single-model sole gate. GPT-5.5 = behavioral semantics authority; Flash = fast implementer; Qwen = architect/depth. |
| **Architecture spec / synthesis / business analysis** | DeepSeek V4 Flash (implement) | **Qwen 3.8 Max** (default reviewer/architect) · GLM 5.2 (second line) | Qwen = strongest architecture/depth (owner empirical: ~ Kimi K3 level, сильнее GLM). |
| **Deep race / ordering** | DeepSeek V4 Flash (implement) | **Qwen 3.8 Max** (constraint analysis) · GPT-5.5 (hosted semantics) | Qwen for deep constraint analysis; GPT-5.5 for hosted semantics — complementary. |
| **Orchestration** | **DeepSeek V4 Flash** (default) · **GLM 5.2** ⚠️ | — | Owner pin (§below). Role lock: does not combine orchestration with writing code in the same task. GLM = ⚠️ tool passivity + drift. |

### Cross-family pairs (writer.family ≠ reviewer.family)

| Writer | Family | Valid reviewers | Invalid reviewers |
|--------|--------|----------------|-------------------|
| Qwen Code | Alibaba | GLM 5.2, GPT-5.5 | OpenCode Qwen (Alibaba) |
| Qwen 3.8 Max | Alibaba | GLM 5.2, GPT-5.5 | OpenCode Qwen (Alibaba) |
| GLM 5.2 | Zhipu | Qwen Code, Qwen 3.8 Max, GPT-5.5 | — |
| GPT-5.5 | OpenAI | Qwen Code, Qwen 3.8 Max, GLM 5.2 | — |

---

## Benchmarks (2026-08-03)

Compact evidence snapshot. Roles are owner-decided (see 30-Second Role Table); benchmarks **do not** drive role assignment — they document the current capability surface. Numbers collected 2026-08-03; **do not invent numbers beyond this table**.

| Model | Code (SWE-bench Verified / Pro) | Judgment (GPQA-Diamond) | Context / Agentic | Price (in/out per 1M, USD) | Source tags |
|-------|---------------------------------|-------------------------|-------------------|----------------------------|-------------|
| **DeepSeek V4 Flash** (build 0731, API release 2026-07-31; HF weights = April preview) | 79.0 (Flash-Max) [indep llm-stats]; Terminal-Bench 2.1 = 82.7 **[vendor self-reported]**; DSBench-FullStack 68.7 / Hard 59.6 **[vendor]** | 71.2 **[vendor]** | 1M context; LiveBench overall 65.5 (Coding 69.2, Agentic Coding **37.6**, Math 79.6; cost/task $0.016) [indep livebench.ai, release 2026-06-25]; MMLU-Pro 86.2 [indep]; AAII 50 [indep artificialanalysis]; LMArena Elo 1431 (#40, snapshot 2026-07-28) | $0.14 / $0.28; 2500 concurrency | api-docs.deepseek.com/updates, livebench.ai, llm-stats.com, artificialanalysis.ai, LMArena |
| **DeepSeek V4 Pro** (preview) | 80.6 **[vendor]** | 90.1 **[vendor]** | 1M context; LiveBench overall 71.6 (Agentic 42.6) [indep]; AAII 44 [indep] | $0.435 / $0.87 | vendor, livebench.ai, artificialanalysis.ai |
| **Qwen 3.8 Max** (GA blog 2026-08-03) | SWE-bench Pro 67.7 **[vendor]** (Fable 5 80.0, Opus 4.8 69.2, GPT-5.6 Sol 64.6); DeepSWE 1.1 56.6; FrontierSWE 73.5 (Fable 5 88.8); SWE-bench Verified в блоге НЕ опубликован. ⚠️ **Do NOT confuse with Qwen 3.7 Max** (SWE-bench Verified 80.4, GPQA 92.4, Terminal-Bench 69.7 — different model, all 3.8 numbers in early reviews are actually 3.7). **Anecdotal/community (single runs, NOT reproducible):** Trilogy AI StackPerf 80/100 vs Kimi K3 83/100 (269-file arch task, 0 failed tool-calls, tool-use 9/10; longer + more tokens); KingBench 65/80 (#2 behind Fable 5, community); 36kr 22.07 won 4/6 rounds vs GLM-5.2/K3 BUT дал ФЕЙКОВОЕ решение в раунде «карусель». | GPQA-Diamond **92.6 [vendor]** (GPT-5.6 Sol 94.1, Fable 5 92.6, Opus 4.8 92.0; GLM 5.2 ref 91.2); HLE 43.6 (Fable 5 53.3); IFBench **82.8 [vendor]** (lead) | 1M context (blog config `context_window: 1000000`; docs.qwencloud.com ранее: 983,616); max output 131,072; reasoning_effort xhigh/medium/low (default xhigh); multimodal input (text/images/video/docs). Agentic [vendor]: Terminal-Bench 2.1 **86.6** (Claude Code harness, avg@10), OSWorld-Verified **86.1** (lead), PaperBench **93.0** (lead), Toolathlon 72.5, WideSearch 81.9, MRCR v2 256K 92.9. Multimodal [vendor]: MMMU-Pro 82.3, MathVision 95.2/97.7, VideoMME 90.4, OmniDocBench 1.5 92.1. Open weights: **first Max-class open-weight model** — HF/ModelScope «next week» (анонс 2026-08-03; HF-репо на дату проверки ещё нет, Qwen/Qwen3.8-Max → 401). **All vendor self-reported; independent verification pending.** | Per-token price официально НЕ опубликована. **Token Plan** [official]: Lite $6, Standard ~$18-20, Pro $68-70/month. Mirror claim $2/$6/$0.25-cached per 1M [MarkTechPost, **unverified**]. Owner subscription confirmed. | qwen.ai/blog?id=qwen3.8 (vendor, 2026-08-03); docs.qwencloud.com (specs 2026-07-19); marktechpost.com (price mirror, unverified); trilology.ai/stackperf, kingbench (community), 36kr.com (2026-07-22) |
| **GLM 5.2** (Zhipu) | SWE-bench Pro 62.1 **[vendor]**; Terminal-Bench 2.1 = 81.0 **[vendor]**; FrontierSWE 74.4; DeepSWE 46.2 | 91.2 **[vendor]** | 1M context; LiveBench 73.2 [indep]; MCP-Atlas 76.8; AAII 51 (**open-weight leader**) [indep]; ~106 tok/s | Z.ai $1.40 / $4.40 | z.ai/blog/glm-5.2, livebench.ai, artificialanalysis.ai |
| **GPT-5.5** (OpenAI) | SWE-bench Pro 58.6 **[vendor]**; Terminal-Bench 2.0 = 82.7 **[vendor]** | 93.6 **[vendor]** | 1M context; OSWorld 78.7; BrowseComp 84.4; AAII 55 [indep] | $5 / $30 | openai.com/index/introducing-gpt-5-5, artificialanalysis.ai |

### Caveats (read before quoting any number)

- **Flash-0731 agentic numbers (Terminal-Bench 2.1, DSBench) are vendor self-reported; independently not reproduced.** LiveBench Coding 69.2 and SWE-bench Verified 79.0 (Flash-Max) are independent, but LiveBench **Agentic Coding sub-score = 37.6** flags weak multi-step agency. Do not cite Flash as a strong agentic coder based on vendor data alone.
- **Flash reasoning is weak:** GPQA-Diamond 71.2 vs GLM 91.2 and GPT-5.5 93.6. Roles that depend on judgment-heavy review are **not benchmark-supported for Flash**. Flash role = orchestrator (dispatch/synthesize) + writer/test-writer on single-file + tests — **not** reviewer/judgment role.
- **Qwen 3.8 Max: vendor benchmarks published 2026-08-03 (qwen.ai/blog?id=qwen3.8); independent verification pending.** Role (default reviewer / архитектор / бизнес-аналитик) = **owner decision + vendor benches + anecdotal**. Judgment теперь vendor-supported: GPQA-D 92.6 (уровень GLM 91.2 / GPT-5.5 93.6); agentic сильные на бумаге: Terminal-Bench 2.1 86.6 (Claude Code harness, avg@10), OSWorld-V 86.1, IFBench 82.8, PaperBench 93.0 — все vendor, harnesses различаются по моделям (сравнения не apples-to-apples). Coding: SWE-bench Pro 67.7 — ниже Fable 5 (80.0); SWE-bench Verified не опубликован. Specs: 2.4T total / **95B active**, 1M context, first open-weight Max-class (веса обещаны «next week» на HF/ModelScope; на дату проверки не вышли). Owner subscription confirmed. **⚠️ Do NOT confuse with Qwen 3.7 Max** (SWE-bench 80.4, GPQA 92.4, Terminal-Bench 69.7 — это ДРУГАЯ модель, все цифры «3.8» в ранних обзорах — на самом деле 3.7). Anecdotal/community measurements (single runs, NOT reproducible): StackPerf 80/100 vs Kimi K3 83 (architectural task, 269 files, 0 failed tool-calls, tool-use 9/10); KingBench 65/80 (#2 behind Fable 5); 36kr 22.07: won 4/6 rounds vs GLM-5.2/K3 BUT дал ФЕЙКОВОЕ решение в раунде «карусель». Strengths [anecdotal]: креатив/дизайн, письмо, deep one-shot сборки, архитектурный анализ с чистой tool-дисциплиной. Weaknesses [anecdotal]: ОЧЕНЬ медленный thinking для кода («slowest model I've used» — Wiegold; 20 min thinking над лендингом — r/LocalLLaMA); галлюцинации/потеря задачи в длинных сессиях (3 раза подряд — r/Qwen_AI); фейковые решения при неясных требованиях (36kr). NE основной кодер (slow) — vendor-бенчи не отменяют latency-данные. Production-wave evidence supports review/architect role empirically.
- **«Flash не хуже GLM» — partially:** AAII 50 vs 51 (close), but reasoning is materially weaker (GPQA 71.2 vs 91.2). A Flash→reviewer swap is **not** benchmark-supported.
- **GPT-5.5 and GLM 5.2 are the only models with confirmed independent judgment/review numbers** (AAII 55 and 51; GPQA-D 93.6 and 91.2). Their roles (security/fidelity gate, static-parity reviewer) are benchmark-supported.
- **DeepSeek V4 Pro** is listed for reference only (preview, vendor-only judgment numbers); it is **not** in the active stack — current default orchestrator is Flash.

### Sources (accessed 2026-08-03)

- `api-docs.deepseek.com/updates` — DeepSeek V4 Flash 0731 + Pro preview (vendor)
- `livebench.ai` (release 2026-06-25) — LiveBench overall + sub-scores (independent)
- `artificialanalysis.ai` — AAII aggregate index (independent)
- `llm-stats.com` — SWE-bench Verified independent tracker
- `z.ai/blog/glm-5.2` — GLM-5.2 vendor numbers
- `openai.com/index/introducing-gpt-5-5` — GPT-5.5 vendor numbers
- `lmarena.ai` (Elo leaderboard, snapshot 2026-07-28) — Flash Elo 1431, rank #40
- `qwen.ai/blog?id=qwen3.8` (2026-08-03, official GA launch + benchmark tables — vendor self-reported, indep verification pending)
- **Qwen 3.8 Max**: `qwen.ai/blog?id=qwen3.8` (2026-08-03, vendor benches); `docs.qwencloud.com` + `x.com/Alibaba_Qwen` (2026-07-19, official specs); `hf.co/Qwen/Qwen3.8-Max` (verified 2026-08-03: HF API 0 models, 401 — open weights announced «next week»); `marktechpost.com` (2026-08-03, price mirror $2/$6 — unverified); `trilogy.ai/stackperf` (StackPerf 80/100 vs Kimi K3 83); KingBench community run; `36kr.com` (2026-07-22, Chinese coverage); `manish.sh`, `ben.wiegold.com` review, `r/LocalLLaMA`, `r/Qwen_AI` (anecdotal community evidence)

---

## Anti-Patterns

1. **Writer = reviewer (same model family)** → Blind-spot risk. Cross-family review mandatory for product code. Qwen Code writer + OpenCode Qwen reviewer = BOTH Alibaba = violation.
2. **GPT-5.5 = "just another reviewer"** → GPT-5.5 = the behavioral regression gate. Caught abort/cost MAJOR that GLM's static review missed (production waves). Unique role — "ещё reviewer" understates its gate function.
3. **Writer self-review** → No model reviews its own work on fidelity/security tasks. Dual review = different families.
4. **Single-model merge decision on security** → Security/RLS gates need behavioral semantics (GPT-5.5) + cross-family review. Never single-model approve.
5. **written≠persisted** → Claim `worker_done` / CHANGES without `ls`/`git status` proof. Production incident: notes said a file NEW while public path missing. Gate binds **all** workers (`worker-contract.md`).
6. **Launching model without checking availability** → Pins and availability change. Check this table before every launch. ⚠️ = temporarily unavailable.
7. **Orchestrator combines orchestration with code writing in the same task** → Role lock violation. Orchestrator dispatches, waits, synthesizes, gates. Writing code in a coordinator session requires an explicit owner-pin switch to writer role. If coordinator edits worker files without that switch → undo → re-dispatch.

---

## Evidence Anchors (Post-Mortem Sources)

- **Production wave (Qwen/GPT-5.5 complementary):** Qwen wrote 5832-case byte-identical prompt matrix with 0 failures (fidelity work at that time). Current role: reviewer/architect (stack revise 2026-08-03). GLM reviewed 40+ static verification points with 0 false positives (static parity confirmed). GPT-5.5 caught abort/cost MAJOR — a hosted-semantics regression that GLM's static-only review missed. Dual review = necessary, not redundant. GPT-5.5 gate = complementary, not "just another review."
- **Current stack:** DeepSeek V4 Flash (default orchestrator + default writer/coder; full role + primary writer on single-file/bulk/tests), Qwen 3.8 Max (default reviewer / архитектор / бизнес-аналитик; NE основной кодер — slow; owner empirical: level ~ Kimi K3, сильнее GLM в architecture), GLM 5.2 (multi-file writer для 3+ файлов + second-line reviewer; benchmark-supported static parity), GPT-5.5 (security/fidelity gate via `codex` CLI). Roles are owner-decided; benchmark evidence status per model is documented in §Benchmarks (2026-08-03) — read caveats before quoting any number.
