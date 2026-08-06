---
name: wave-spec
version: 1.7.0
description: >
  Use when starting a sprint/wave that must not skip planning — user says "wave-spec",
  "spec first", "составь спеку/план", "interview then plan", or begins multi-session
  work (development, content, skill-port, translation, orchestration). Produces SPEC.xml
  + PLAN.xml + worker briefs + STATUS/handoff. Portable across OpenCode, Qwen Code, ZCode —
  writes files in the project, no vv-opencode runtime.
  ROUTER: новый проект → project-bootstrap · план спринта → wave-spec · 2+ модели → multi-model-orchestration.
  Do NOT use the full pipeline for trivial edits (≤1 файл, ≤30 мин, no deploy) — use mode=quick below.
---

# wave-spec

**Method:** same as vv-opencode (`vv-spec` → `vv-plan` → approve → exec), but **portable**:
structured XML artifacts in the repo, any orchestrator CLI.

**You (the agent) execute this skill.** The user does not need to invent the pipeline.

> **Positioning (identity):** wave-spec is a **universal plan-gate + lifecycle skill for 1–3 week product waves across any domain** — development, content, skill-port, translation, orchestration, site rebuild.
> It is NOT an SEO costume and NOT gsd-core / gsd-coordinator / vv-opencode runtime — no agentic dispatch, no worktree groups, no structured handoff beyond project-local SESSION_HANDOFF.
> The lifecycle gates below are the contract; full identity and boundaries in [Positioning](#positioning).

## TL;DR (minimum path — 5 минут)

**wave-spec = план-гейт.** Пишет в `waves/<date>-<slug>/`: INTENT → SPEC.xml → PLAN.xml → **approve** → exec → STATUS/handoff. Не для однострочных правок (для них `mode=quick`).

**Прочитай только:** Modes → Hard gate → Pipeline шаги 0–5 → approve. Остальное (NEXT_SESSION/Linear) — по мере возникновения; **LAUNCH.md обязателен для wave/program до dispatch** (см. Шаг 6.0).

**Лестница обучения:** Волна 1 = `mode=quick` (весь цикл за 1 сессию) → Волна 2 = полный `wave` + 1 review → Волна 3+ = `multi-model-orchestration`. Учись деланием, не чтением.

**Роутер:** новый проект → `project-bootstrap` · план спринта → `wave-spec` · 2+ модели → `multi-model-orchestration`.

## Modes

| Mode | Trigger | Output |
|------|---------|--------|
| `quick` | Trivial / пет-проект: **≤1 файл, ≤30 мин, no deploy** | INTENT 5 строк → SPEC 10 строк → approve → apply → archive (1 файл, без LAUNCH/NEXT_SESSION/Linear) |
| `wave` (default) | One sprint 2–7 days / one theme | `waves/<date>-<slug>/…` |
| `task` | Single atomic task inside approved wave | `waves/.../tasks/TNN-*.xml` + worker brief |
| `program` | Multi-wave portfolio (fidelity port, book translation, site rebuild) — редко; см. `references/program-maps.md` | `roadmap/PROGRAM_SPEC.xml` + `roadmap/PROGRAM_PLAN.xml` |

Default: if unclear, start **wave** (or **quick** for trivial). `program` — только для много-волновых портфелей; карты доменов в `references/program-maps.md`.

### Quick mode (mode=quick)

Для мелких правок и пет-проектов, которые не тянут полный lifecycle. Шаблон: `assets/templates/quick-spec.md.tmpl`.

1. **INTENT** — 5 строк (что хочу / успех / out of scope).
2. **SPEC** — 10 строк (goal + 2–3 success criteria + constraints).
3. **approve** — «Ответь approve» (hard gate, как в полном wave).
4. **apply** — выполнить (один исполнитель, без диспетчеризации).
5. **archive** — `mv waves/<date>-<slug> waves/archive/` по завершении.

**Порог:** quick только если ≤1 файл, ≤30 мин, no deploy. Иначе — полный `wave` (с lifecycle gates + review). Quick НЕ отменяет written≠persisted и secret-redaction.

## Installation / SoT

**Source of Truth:** `skills/wave-spec/` in the opencode-skills repo — git-tracked, canonical. All edits go here.

**Install into OpenCode** (active CLI):
```bash
ln -sf <repo>/skills/wave-spec ~/.config/opencode/skills/wave-spec
```

If the repo moves, recreate the symlink above with the new path.
## Hard gate

Until user says **approve / approved / proceed / dig / делай / утверждаю**:

- **Do** write planning artifacts (INTENT/SPEC/PLAN/STATUS templates).
- **Do not** implement site changes, bulk content, deploy, or dispatch workers for execution.
- **Do** research/read repo, AGENTS.md, SESSION_HANDOFF, diagnostics (read-only).

After approve: produce worker briefs and optionally Orca dispatch commands; still do not expand scope beyond PLAN.

> **Lifecycle gates:** before claiming Done or handing off to NEXT product, follow the contract in [Lifecycle Gates](#lifecycle-gates-production-lessons).

---

## Pipeline (run in order)

### 0. Locate workspace

1. Find project root (AGENTS.md or git root).
2. Read if present: `AGENTS.md`, last block of `SESSION_HANDOFF.md`, `plan.md`, `.agents/memory/MEMORY.md`.
3. Detect existing `roadmap/` and `waves/` — never overwrite approved artifacts without asking; version with new date slug instead.

### 1. INTENT (human or draft-for-human)

Path:

- program: `roadmap/INTENT.md`
- wave: `waves/<YYYY-MM-DD>-<slug>/INTENT.md`

If user already pasted free text → save it as INTENT.md (light edit for structure only).

If missing → write a draft INTENT from conversation and ask user to correct:

```markdown
# INTENT
## What I want (freeform)
## Targets (project / repo / site / book — if any)
## Stack / context (if known)
## Constraints (budget, no-deploy, region, language)
## Success in my words
## Out of scope (if known)
## Links to existing research
```

**Stop if INTENT is empty or contradictory** — ask 1–2 clarifying questions only.

### 2. Interview (3–7 questions)

After INTENT + context read:

1. List open issues: ambiguity / contradiction / blocker / risk / assumption.
2. Ask **only** questions that unblock SPEC (max 7). Each question: options + recommended default.
3. Do **not** interview for things already answered in AGENTS/handoff/research.

**Дисциплина интервью (lean):** (a) recommendation-first — каждый вопрос начинай с рекомендуемым ответом по умолчанию и обоснованием (большинство ответов закрывается одним словом); (b) мини-roadmap — перед первым вопросом покажи список открытых вопросов целиком; (c) recap — после интервью одной строкой резюмируй зафиксированные решения, чтобы поймать недопонимание до SPEC.

If user says «решай сам / use defaults» → mark assumptions explicitly: log them via `assets/templates/ASSUMPTIONS.md.tmpl` and record them in the SPEC `<assumptions>` block.

### 2.5 Pre-mortem triage

Дешёвый design check между Interview и SPEC: один review-only dispatch на сессию, который ловит failure surfaces в draft дизайне до формирования final контракта. **НЕ заменяет post-implementation review** (Fidelity Dual Review остаётся обязательным для fidelity ports) и **НЕ отменяет hard gate approve** (шаг 5).

**Trigger (OR — любое одно условие достаточно, чтобы сделать pre-mortem `required`):**

- `migration` — reference→platform, framework, DB migration, schema change
- `prod` — deploy to production, prod config change
- `data` — data migration, persistent data work, schema rewrite
- `security` — auth, secrets, permissions, RLS, threat model change
- `fidelity` / `reference port` — behavioral parity wave
- `packages >= 6` — PLAN планирует 6+ пакетов/задач
- `planned duration >= 7 days` — плановая длительность волны (не fact elapsed)

**Mode rules:**

1. `quick` — **всегда SKIP**, записать `skip_reason: quick mode` (quick ≤1 файл, ≤30 мин, no deploy — несовместим с pre-mortem dispatch).
2. `wave` / `program` — `required` если сработал хоть один trigger; иначе `skipped` (`skip_reason: no risk trigger`).
3. `task` — **всегда SKIP**, `skip_reason: task-level — pre-mortem родительской волны (wave-level) применяется/применён` (атомарная задача ВНУТРИ одобренной волны; gate считается на wave-level, не на task-level).
4. Если режим не указан — сначала решить режим (Modes), потом pre-mortem triage.

**Quota — ровно 1 dispatch на сессию:**

- Оркестратор выставляет wave-level поля (STATUS.md отдельная секция или wave notes):
  - `trigger` — какое условие сработало (или `skipped` + `skip_reason`)
  - `dispatch_used` — **ставится `true` ДО dispatch** (атомарность квоты, не после)
  - `brief` — path к заполненному `premortem-brief.md.tmpl`
  - `verdict` — `PASS | REVISE | BLOCK` после ответа
  - `report` — path к pre-mortem report
  - `skip_reason` — если `skipped`
- **Transport/API failure ≠ `REVISE`/`BLOCK`:** если worker/transport не дал verdict, это **non-counting operational failure** по правилам failure ledger (`failure-handling.md`) — не увеличивает failure streak и **НЕ автоматический второй dispatch** в той же сессии без явного owner request.

**Packet:** `assets/templates/premortem-brief.md.tmpl` — packet-first, review-only, **reviewer write allowlist = `None`**.

**Reviewer:** Qwen 3.8 Max medium — `A/agent1st_qwen-3.8`, **review-only**, `dispatch --inject`, `worker_done` exactly once. Pin и brief template — `multi-model-orchestration/references/model-card.md` и `routing.md`.

**Verdict contract (ровно один из трёх):**

- **PASS** — design готов к SPEC/PLAN. Разрешает писать SPEC/PLAN. **НЕ разрешает implementation** — hard gate approve (шаг 5) сохраняется; execution dispatch по-прежнему требует approve + LAUNCH (gate 6.0).
- **REVISE** — исправить design draft (assumptions / scope / ownership / validation strategy), один проход к SPEC/PLAN. **Второй pre-mortem в той же сессии запрещён.**
- **BLOCK** — стоп до owner decision или явной смены запроса. SPEC/PLAN и implementation запрещены.

**Verdict НЕ failure-ledger событие:** при нормальном verdict (PASS/REVISE/BLOCK) task-owned failure state = `fingerprint: none, hypothesis: none, count: 0, reset_reason: not_applicable`. Только сбой самого dispatch/worker (timeout, API failure, transport void) идёт через `failure-handling.md` как non-counting event.

**LAUNCH exception (см. gate 6.0):** pre-mortem planning review dispatch — единственный разрешённый до approve/LAUNCH review-only dispatch; **НЕ удовлетворяет gate 6.0** (LAUNCH.md не требуется для pre-mortem). Execution/writer/reviewer dispatch после approve по-прежнему требует `LAUNCH.md` с cross-family check + `## Prohibited`.

**Provenance:** сохранить `brief` и `report` paths в wave metadata. Принятые mitigations перенести в `<risks>`, `<acceptance>`, constraints или PLAN tasks/gates. INTENT остаётся human narrative; pre-mortem report — отдельный review artifact.

### 3. SPEC.xml (structured — agent-facing)

**Markdown с required-sections достаточен** для SPEC/PLAN (triage finding: свежий агент извлекает required-поля из MD и XML одинаково, 5/5). XML — опционален; портативный валидатор `scripts/verify-spec.sh` уже покрывает оба формата поровну, поэтому MD предпочтительнее (см. `## XML vs Markdown (policy)` ниже). Обязательные секции: Goal, Done_when, Verifier, Scope, Risks.
Human narrative stays in INTENT.md.

Use template: `assets/templates/SPEC.xml.tmpl`  
Write to: `…/SPEC.xml`

Required sections:

| Tag | Content |
|-----|---------|
| `status` | `draft` until user approves → then `approved` |
| `goal` | 1–2 paragraphs + measurable success criteria |
| `scope/in` `scope/out` | explicit |
| `constraints` | tech, legal, deploy gates, model roles |
| `sources` | existing files/URLs with dates — no invented metrics |
| `architecture` or `workstreams` | domain-specific (see `references/program-maps.md` — pick relevant streams, do NOT copy all) |
| `risks` | with mitigation |
| `acceptance` | checklist that proves wave/program done |

**Evidence rule:** every number needs `source` attribute or child `<source>`. Unknown → `<todo>…</todo>`, never invent.

### 4. PLAN.xml (waves, deps, owners)

Template: `assets/templates/PLAN.xml.tmpl`
Write to: `…/PLAN.xml`

Required:

- `waves` or for single wave: `tasks` with `id`, `title`, `depends_on`, `owner` (orchestrator|opencode|codex|human), `model_hint`, `artifact` path, `done_when`
- Parallel groups: tasks with empty/non-overlapping `depends_on` and different `artifact` paths
- `gates`: human approval points (deploy, purchase, CMS production)
- `roles`: orchestrator + executors with tool/agent/flags/effort/**family** + `<family_rule>`:

```xml
<roles>
  <!-- Default stack: Flash orchestrator + primary writer · Qwen reviewer/architect · GLM multi-file writer + 2nd-line reviewer · GPT-5.5 security gate -->
  <orchestrator tool="opencode" agent="A/agent1st_v37.3-flash" family="DeepSeek">
    deepseek-v4-flash
  </orchestrator>
  <executors>
    <executor id="writer" tool="opencode" agent="A/agent1st_v37.3-flash" family="DeepSeek">
      DeepSeek V4 Flash — primary writer/coder (single-file, bulk code, tests); fast + cheap, strong on 0731 benchmarks
    </executor>
    <executor id="writer-multifile" tool="opencode" agent="A/agent1st_glm" family="Zhipu" optional="true">
      GLM 5.2 — multi-file writer (3+ файлов; 1M state continuity); second-line reviewer
    </executor>
    <executor id="reviewer" tool="opencode" agent="A/agent1st_qwen-3.8" family="Alibaba">
      Qwen 3.8 Max — reviewer / архитектор / бизнес-аналитик (default reviewer; owner empirical: сильнее GLM в architecture)
    </executor>
    <executor id="security" tool="codex" family="OpenAI" optional="true">
      GPT-5.5 — behavioral regression gate (security/RLS/fidelity ports)
    </executor>
  </executors>
  <launch_file>LAUNCH.md</launch_file>
  <family_rule>writer.family ≠ reviewer.family</family_rule>
</roles>
```

For **program** PLAN: only high-level phases (Phase 0…N) and what the **first wave** will be.  
For **wave** PLAN: atomic tasks (3–12), not 50.

### 5. Human approve

Present short summary:

1. Goal + success  
2. Out of scope  
3. Task table (id / owner / artifact / depends)  
4. Open risks  
5. Exact phrase: «Ответь **approve**, если можно исполнять; или правки к SPEC/PLAN.»

On approve: set `<status>approved</status>` in SPEC.xml and PLAN.xml, append line to STATUS.md.

### 6.0 LAUNCH.md gate (после approve, ПЕРЕД dispatch) — HARD GATE

Для mode=wave/program: до любого dispatch воркеров `waves/<date>-<slug>/LAUNCH.md` **обязан существовать** и содержать:

- **Cross-family check** (writer.family ≠ reviewer.family)
- Секцию **«Prohibited»** (включая запрет terminal send для opencode)

Если LAUNCH.md отсутствует или не содержит оба элемента — **СТОП**: создать/обновить по шагу 6b, затем продолжить. Dispatch без LAUNCH.md = нарушение протокола (как dispatch без approve). mode=quick исключён (см. Modes).

Проверка перед первым dispatch (все три команды должны пройти):

```bash
ls waves/<date>-<slug>/LAUNCH.md
grep -qiE "cross-family|writer\.family" waves/<date>-<slug>/LAUNCH.md
grep -qiE "^## Prohibited" waves/<date>-<slug>/LAUNCH.md
```

Разграничение с 6b: **6.0 = gate** (проверка существования + валидность), **6b = генерация** (как создавать). Mandatory-секции не дублировать.

**Pre-mortem exception (шаг 2.5):** pre-mortem planning review dispatch — единственный разрешённый до approve/LAUNCH review-only dispatch; **НЕ удовлетворяет gate 6.0** (LAUNCH.md не требуется для pre-mortem). Execution/writer/reviewer dispatch после approve по-прежнему требует `LAUNCH.md` с cross-family + `## Prohibited`.

### 6. Dispatch prep (after approve only)

For each ready task (`depends_on` satisfied):

1. Write `tasks/<id>.xml` (optional if task fully in PLAN)  
2. Write `tasks/<id>.brief.md` — **worker-facing**, 20–40 lines:

```markdown
# Task <id>
## Role
You are EXECUTOR, not strategist.
## Read first
- AGENTS.md
- <SPEC path>
- <only relevant PLAN task + sources>
## Do only
...
## Write only
<path(s)>
## Done when
...
## Forbidden
- invent metrics
- expand scope
- edit plan/SPEC
```

Full brief shape — `ROLE / MODE`, Read first, Do only, Write only, Done when, Forbidden, and the worker report contract — lives in `assets/templates/worker-brief.md.tmpl`.

3. Execute the launch cycle per LAUNCH.md (обязательно — gate 6.0; Orca недоступна → распечатать команды для владельца):

```bash
# Full atomic cycle — see LAUNCH.md (step 6b) for per-model commands
orca terminal create --worktree active --title <id> --command "opencode --agent <pin>" --json
# Set variant/effort + sleep 3 (MANDATORY)
# task-create → parse result.task.id → dispatch --inject (NOT terminal send)
```

See step 6b (LAUNCH.md generation) for complete per-model launch cycles with `dispatch --inject`.

Orchestrator tracks progress in STATUS.md.

### 6b. LAUNCH.md generation (after approve, before dispatch)

Generate `waves/<date>-<slug>/LAUNCH.md` from:

**Reference versions** (check before generation — if references are newer, regenerate LAUNCH.md):
- `multi-model-orchestration/references/model-card.md` — see its "Updated:" marker
- `multi-model-orchestration/references/routing.md` — see its "Updated:" marker
- ⚠️ If either file modified after the marker → STALE REFERENCE. Regenerate LAUNCH.md.
1. `multi-model-orchestration/references/model-card.md` — agent pins, commands, **model family**
2. `PLAN.xml` — roles from `<roles>` section
3. `multi-model-orchestration/references/routing.md` — brief templates per model

Template: `assets/templates/LAUNCH.md.tmpl`

Mandatory sections:
- Tools and agents table (role, tool, command, mode, **family**)
- **Cross-family check:** writer.family ≠ reviewer.family (instruction: "verify → replace if same", NOT a static "✓")
- Full orchestration cycle (atomic bash block per tool)
- Review brief templates per model (DeepSeek, GLM, Codex, Qwen Code — from routing.md)
- "Prohibited" section (vv-controller, terminal send, skip sleep 3, result.id, Qwen without yolo, launch without model-card check, same-family review, coordinator writes code)

**Versioning:** on role change mid-wave (owner pin "сейчас writer=X") — regenerate LAUNCH.md, save previous as `LAUNCH.v{N}.md`.

### 6c. NEXT_SESSION generation (at iteration handoff)

**Format principle (model-agnostic):** any LLM orchestrator will execute a ready-made bash block blindly without validating against the source. Therefore NEXT_SESSION uses **steps + verification gates**, NOT copy-paste bash recipes.

Pattern:
1. **Unique file per iteration:** `NEXT_SESSION_I{N}.md` (e.g. `NEXT_SESSION_I1.md`). Never overwrite previous iteration's file.
2. **Copy-paste block at top:** short imperative (3-4 lines). Must include **full path** to the NEXT_SESSION file. Format by orchestrator model (from SPEC `<orchestrator>`).
3. **Step 0 = load source:** `orca skills get orchestration` — the orchestrator MUST read the actual guide, not guess from cache. This is the single most important step.
4. **Each step = action + verification gate:** a concrete verifiable fact in the output (e.g. `"ok": true`, file exists, worker_done received). NOT "check that X is correct".
5. **No copy-paste bash blocks:** the orchestrator builds dispatch commands from the orchestration guide itself. NEXT_SESSION provides the SEQUENCE (create → wait → variant → sleep → task-create → dispatch → check) but NOT the exact bash.
6. **Linear woven into flow:** In Progress at step 1, comment + In Review at step 7. NOT "at the end if you remember".
7. **Root pointer:** `NEXT_SESSION.md` (no suffix) — only a pointer + table of iteration files.
8. **Create on completion:** after finishing iteration, create `NEXT_SESSION_I{N+1}.md` and update the pointer.
9. **Spec-delta line:** each iteration file carries `Changes vs I{N-1}: [файлы/решения]` (пустая для I1). Ревьюер/длинная сессия смотрит дельту, а не весь SPEC заново — экономит контекст (особенно в 400k-сессиях).

Templates (two files mandatory):
- `assets/templates/NEXT_SESSION.md.tmpl` — pointer (table of iterations, current pointer)
- `assets/templates/NEXT_SESSION_ITER.md.tmpl` — iteration (steps 0-8 with gates)

MANDATORY: every iteration produces BOTH files. NEXT_SESSION.md without NEXT_SESSION_<iter>.md = incomplete. NEXT_SESSION_<iter>.md without NEXT_SESSION.md pointer = orphan.

**Порог компактности (гибрид):** волна **≤2 итераций** → компактный NEXT_SESSION = шаги **0 (load), 3 (dispatch), 8 (handoff)** + gates на каждый (без полных описаний шагов 1–2, 4–7); **3+ итераций** → ОБЯЗАТЕЛЬНО полный 9-шаг из `NEXT_SESSION_ITER.md.tmpl` (инциденты operational rules случались на итерируемых волнах — на 4-й итерации длинной волны). Шаблон-формула (9 шагов) остаётся учебником lifecycle. **Не путать с `mode=quick`:** quick — для trivial-правок (≤1 файл, вообще без NEXT_SESSION); компактный NEXT_SESSION — для коротких ВОЛН (1–2 итерации, с dispatch/review).

**Step structure (9 steps, 0–8):**
- Step 0: Load sources (orchestration guide + SPEC + linear-workflow)
- Step 1: Linear In Progress
- Step 2: Create brief file
- Step 3: Dispatch (build from guide, no copy-paste bash)
- Step 4: Verify (git status)
- Step 5: Review (same dispatch flow)
- Step 6: Commit + push
- Step 7: Linear comment + In Review
- Step 8: Handoff (create next NEXT_SESSION)

Copy-paste format by orchestrator (рабочие оркестраторы владельца):

| Orchestrator | Copy-paste format |
|-------------|-------------------|
| **Qwen 3.8 Max** | ### Context / ### Objective / ### Constraints |
| **GLM 5.2** | ### Goal / ### Constraints / ### Done |

Default (if orchestrator not specified): **DeepSeek V4 Flash** — формат брифов в `assets/templates/LAUNCH.md.tmpl` (writer brief = Flash/GLM; reviewer brief = Qwen/GLM; security brief = GPT-5.5). **Оркестратор по умолчанию — DeepSeek V4 Flash** (`A/agent1st_v37.3-flash`): полная роль — dispatch → wait → gate → synthesize, НЕ «механика только». **Writer по умолчанию — также DeepSeek V4 Flash** (single-file/bulk/tests; multi-file → GLM 5.2). Полная таблица форматов — в `assets/templates/LAUNCH.md.tmpl`.

### 6d. Linear workflow generation (if project uses Linear)

Generate `.agents/rules/linear-workflow.md` from wave parameters:
- `{{parent_epic}}`, `{{project_name}}`, `{{team_key}}`, `{{language}}`, `{{iteration_map}}`

Template: `assets/templates/linear-workflow.md.tmpl`

**On new wave in same project:** APPEND to §11 (wave history), do NOT overwrite the file.

### Linear validation (if project uses Linear)

- [ ] Task created in correct project (default from AGENTS.md / linear-workflow.md)
- [ ] Parent specified (if work under epic)
- [ ] Title contains CAS-XX / I{N}
- [ ] Description in Russian, with `- [ ]` checklist
- [ ] Status: Backlog → In Progress on start
- [ ] Comment-report on completion (§3 linear-workflow.md)

### 7. STATUS + HANDOFF

Maintain `…/STATUS.md`:

```markdown
# STATUS
| id | title | owner | state | artifact | fingerprint | hypothesis | count | reset_reason | notes |
|----|-------|-------|-------|----------|-------------|------------|-------|--------------|-------|
| T03 | port ledger columns | glm | in_review | skills/wave-spec/SKILL.md | orders-api::pytest::OrderTest.test_order_total::AssertionError::compute_total | discount applied twice (coupon + sale) | 2 | implementation_changed | same fingerprint 2nd fail; orchestrator reset after writer refactored compute_total |
```

**Column semantics (10 columns, exact order):**

| Column | Meaning |
|--------|---------|
| `id` | task/package identifier |
| `title` | краткое название задачи |
| `owner` | agent identifier (исполнитель задачи) |
| `state` | lifecycle enum: `implement_done \| in_review \| commit \| pr \| merge \| deploy_gate \| on_prod \| done` — НЕ заменяется failure status; lifecycle order и gates НЕ менять |
| `artifact` | пути артефактов через запятую |
| `fingerprint` | нормализованный id фейла: package + команда/тест + класс/сообщение + стабильный путь/символ; БЕЗ таймстампов, сгенерённых id, secret values; при отсутствии активного фейла — `—` |
| `hypothesis` | ровно ОДНА активная причина; при отсутствии — `—` |
| `count` | целое число consecutive counted failures для текущего task/package + fingerprint + hypothesis; при отсутствии фейла — `0` |
| `reset_reason` | transition value (см. ниже); при отсутствии активного фейла — `—` |
| `notes` | свободные заметки |

**reset_reason transition values (полный список, 8 значений):**

`pass` | `fingerprint_changed` | `package/command_changed` | `implementation_changed` | `hypothesis_changed` | `scope_changed` | `non_counting:<category>` | `same_fingerprint_retry`

Правила:
- `same_fingerprint_retry` — причина обычного инкремента count; НЕ сбрасывает count, НЕ эскалация, НЕ смена модели
- `implementation_changed` — обязательный (OFK требует reset при material change реализации, даже если гипотеза прежняя)
- `non_counting:<category>` — закрытый список категорий из CAS-168: `user_cancellation | tool_interruption | timeout | service_unavailable | browser_transport | dependency_environment | pre_existing_unrelated | outside_package_ownership` (эти фейлы не увеличивают count)
- reset_reason обязателен при reset / non-counting / смене серии

**Ownership:**
- Ledger-поля (`fingerprint` / `hypothesis` / `count` / `reset_reason`) обновляет ТОЛЬКО оркестратор
- Workers докладывают evidence/failure tuple в отчётах, но НЕ пишут в ledger
- Шаблон STATUS: «Updated by orchestrator; Workers may append notes only» + «orchestrator owns ledger fields»

**Review gate block — orchestrator-owned, separate from ledger:**

В дополнение к ledger-колонкам оркестратор поддерживает отдельный `## Review gate` блок в STATUS для метаданных Review mode. Блок **НЕ добавляется** в ledger-колонки (10-колоночная схема CAS-167 неизменна) и **НЕ добавляется** в canonical Handoff 6 headings (компактный snapshot или path-link может появиться в `### Residual risk`).

```markdown
## Review gate

- review_mode: Mechanical | Simple | Ordinary | Strong
- selection_basis: <precedence rule that fired — see §Review modes>
- review_dispatches: 0 | 1 | 2  <!-- per-dispatch reviewer name + family -->
- strong_session_used: true | false | n/a  <!-- set BEFORE first Strong dispatch; atomic double-Strong guard -->
- follow_up_reason: none | user-requested | unresolved-blocker-high
- synthesis_path: <path to review-synthesis.md, or "n/a — Mechanical skip">
```

Правила владения:
- Только оркестратор пишет этот блок.
- `strong_session_used` — **atomic compare-and-set** непосредственно перед первым Strong dispatch: если `strong_session_used == false` → атомарно set `true` → dispatch 2 complementary reviewers; если `strong_session_used == true` → **BLOCK**: Strong dispatch НЕ выполняется, оркестратор фиксирует `blocked_by: strong_session_used` в STATUS `## Review gate` блоке и выдаёт owner/escalation outcome (не тихий пропуск, не повторный dispatch). Флаг НЕ сбрасывается внутри сессии. **Recovery:** transport/API failure при первом Strong dispatch — non-counting operational failure (не инкремент ledger, не автоматический второй Strong dispatch); retry того же gate возможен только после явного owner-решения (или как fix-round против существующих findings — он Strong flag не потребляет).
- Для Mechanical блок фиксирует skip evidence (`review_dispatches: 0`, `synthesis_path: n/a — Mechanical skip`); synthesis-артефакт может не создаваться.
- Workers сообщают reviewer findings через стандартный output contract; они НЕ пишут этот блок.

**Legacy:** новые волны — по полной схеме (10 колонок); исторические STATUS в `waves/` НЕ переписывать (ничего не мигрировать).

**Per-iteration handoff:** each iteration creates `iterations/I{N}-<slug>.handoff.md` (unique file).
Template: `assets/templates/iteration-handoff.md.tmpl`

**Root SESSION_HANDOFF.md:** only a pointer, not full content:
```markdown
Current iteration: **I{N}** → iterations/I{N}-<slug>.handoff.md
```

**Prohibition:** overwriting a previous iteration's handoff file. Each iteration = new file.

End of session: append pointer to `SESSION_HANDOFF.md`. Facts → MEMORY.md.

### Handoff payload gate (CAS-169)

The canonical `## Handoff` block (6 headings + required labels) lives in `assets/templates/worker-brief.md.tmpl` and `assets/templates/iteration-handoff.md.tmpl`. After writing a handoff and **before** transitioning lifecycle state, run the payload gate:

```bash
bash skills/wave-spec/scripts/verify-handoff-payload.sh --handoff <path-to-handoff.md>
```

The gate extracts the first `## Handoff` block (from `## Handoff` to EOF or the next `## ` heading) and checks: 6 canonical headings (`### Changed files` / `### Delivered behavior` / `### Validation` / `### Task-owned failure state` / `### Assumptions` / `### Residual risk`), required labels (`command:` + `observed:` in Validation), **Task-owned failure state is mode-aware** [F1] — scalar labels (`fingerprint:` + `hypothesis:` + `count:` + `reset_reason:`) for single-task worker handoffs OR a Markdown table (`| task | fingerprint | hypothesis | count | reset_reason |` + separator + ≥1 data row) for multi-task iteration handoffs, **semantic value validation** [M2] (`count` = non-negative integer; `reset_reason` ∈ 8 canonical transition values / `non_counting:<cat>` / sentinel `not_applicable`/`none`/`—`), and payload ≤1500 UTF-8 chars.

- **Worker handoff (before `worker_done`):** exit 3/4/5 → handoff не принимается; worker правит блок и повторяет gate. exit 0 → send `worker_done`. (Hard gate — worker must not bypass.)
- **Iteration closeout (before pointer в `SESSION_HANDOFF.md`):** exit 3/4/5 → WARNING с N/1500 в STATUS notes (soft, не жёсткий блок) — оркестратор принимает handoff и помечает превышение. exit 0 → pointer в `SESSION_HANDOFF.md`.
- **mode=quick НЕ вызывает payload-gate** (SPEC guard: новые гейты только на выходе, не на входе dispatch).
- Defaults для успешного handoff (anti-bureaucracy): `fingerprint: none`, `hypothesis: none`, `count: 0`, `reset_reason: not_applicable`.
- **Sentinel scope (M1, CAS-169 fix-round):** `none` / `not_applicable` / `0` — **handoff-specific sentinels** (compact payload format). Канонический `—` (CAS-167/168) остаётся sentinel'ом для ledger/STATUS (см. §7 column semantics). Это НЕ переопределение канона — компактный alias только для handoff-payload.
- Словарь `fingerprint` / `hypothesis` / `count` / `reset_reason` — канон CAS-167/168 (`references/glossary.md` + `skills/multi-model-orchestration/references/failure-handling.md`).
- Для iteration-handoff (multi-task): `### Task-owned failure state` — таблица по task id (`| task | fingerprint | hypothesis | count | reset_reason |`), не единственный набор полей.
- **Boundary:** этот gate НЕ заменяет `verify-handoff-gate.sh` (project-bootstrap destination gate — 4/4 PASS, unchanged) и НЕ заменяет `verify-spec.sh` (SPEC/PLAN required-sections). Truthfulness of `command:`/`observed:` evidence остаётся обязанностью coordinator/lifecycle gates, не статического гейта.

> **Lifecycle gates:** before closing wave as Done, verify all gates passed — see [Lifecycle Gates](#lifecycle-gates-production-lessons).

---

## XML vs Markdown (policy)

| Artifact | Format | Why |
|----------|--------|-----|
| INTENT | Markdown | human freeform |
| SPEC / PLAN / task cards | **Markdown с required-sections (default); XML опционален** | format triage (2026-08): свежий агент извлекает required-поля из MD и XML одинаково (5/5); `scripts/verify-spec.sh` проверяет оба формата |
| Worker brief | Markdown | easy to paste into any terminal |
| STATUS / HANDOFF | Markdown | human + append-only |

**Одна точка правды** (format reconciliation): default = **Markdown с required-sections** (Goal, Done_when, Verifier, Scope, Risks — см. §2 примечание ~строка 128). XML — только если под него есть реальный парсер/валидатор; сейчас `scripts/verify-spec.sh` покрывает оба формата поровну, поэтому MD предпочтительнее (проще писать, читать и diffs). vv-opencode runtime не требуется ни для одного из форматов.

GRACE anchors: optional in INTENT/STATUS; for XML use attributes `id="…"` on elements instead of HTML comments.

---

## Scaling: tens of sessions (program → waves)

Do **not** put the entire project into one wave.

1. **Program** once: workstreams + phase order + definition of done for the domain.  
2. **Waves** repeatedly: each wave = one theme that fits 1–5 sessions.  
3. Pick domain-specific phase order from `references/program-maps.md`. Examples:

| Domain | Shape | Program phases |
|--------|-------|---------------|
| **Skill-port / orchestration** | successive skill-port waves (I0→I7) | P0 Inventory+baseline → P1 Architecture/contract → P2 Port/fidelity → P3 Review/lifecycle → P4 Dispatch → P5 Documentation → P6 Release |
| **Book translation** | multi-pass: glossary→draft→literary→QA→typeset | P0 Glossary freeze → P1 Draft (3 models × 3 passes) → P2 Literary adaptation → P3 Consistency QA → P4 Typesetting |
| **Product fidelity port** | SaaS/platform: reference→parity→port→regress→probe→review | P0 Reference capture → P1 Parity matrix → P2 Scaffolding+CI → P3 Core domain → P4 API surface → P5 UX/UI → P6 Regression+deploy probe |
| **Site/content rebuild** | SEO, content audit, site migration | P0 Inventory+access+baseline → P1 Technical foundations → P2 Performance/CWV → P3 Templates+schema → P4 Content system → P5 GEO/AEO → P6 Internal links+nav → P7 Measurement cadence |

**First session after skill install:** program SPEC/PLAN **or** one wave if program already exists in `plan.md`.

Tasks must appear in INTENT + evidence — never force irrelevant workstreams.

---

## Orchestrator vs executor

| Role | Default | Allowed (owner pin) |
|------|---------|---------------------|
| Orchestrator (runs this skill) | **DeepSeek V4 Flash** | DeepSeek V4 Flash (default) · GLM 5.2 ⚠️ |
| Writer (single-file / bulk / tests) | **DeepSeek V4 Flash** | DeepSeek V4 Flash (default) · GLM 5.2 (multi-file swap) |
| Reviewer / архитектор / аналитик | **Qwen 3.8 Max** | Qwen 3.8 Max (default) · GLM 5.2 (second line) |
| Security / fidelity gate | **GPT-5.5** (`codex` CLI) | GPT-5.5 (unique role) |

**Оркестратор и writer по умолчанию — DeepSeek V4 Flash** (`A/agent1st_v37.3-flash`). Owner pin: «сейчас orchestrator=GLM» (мульти-файловые/архитектурные волны) или «сейчас writer=GLM» (multi-file implement). Qwen 3.8 Max — default reviewer/architect (NE writer — slow). GLM = ⚠️ tool passivity (agent anti-patterns §4.5). См. `model-card.md`.

Executors **do not** rewrite SPEC/PLAN. They may append STATUS notes.
---

## Quality bar

- SPEC success criteria are **checkable** without vibes.  
- Every task has **one primary artifact path**.  
- Parallel tasks **do not share write paths**.  
- Deploy / paid tools / production CMS = `owner=human` gate.  
- No fabricated metrics (traffic, positions, conversion rates, benchmark scores) without source.
- `done_when` = **исполняемая команда** (grep/test/curl) или проверяемый факт; проза — только если команды нет.
- **no_placeholders** (только проза, не слоты шаблонов): в SPEC/PLAN запрещены «TBD / implement later», «similar to TNN» (повтори контракт полностью), «add error handling» без конкретных правил. XML-слоты (`<todo>`, `{{placeholders}}`) — легитимны.

## References

- `assets/templates/` — INTENT, SPEC.xml, PLAN.xml, STATUS, worker-brief, review-synthesis, fix-round-brief, **premortem-brief.md.tmpl** (шаг 2.5), ASSUMPTIONS, **quick-spec.md** (mode=quick), **LAUNCH.md**, **iteration-handoff.md**, **NEXT_SESSION.md** (pointer), **NEXT_SESSION_ITER.md** (iteration), **linear-workflow.md**
- `references/program-maps.md` — domain-specific program maps (4 menus: skill-port, translation, fidelity port, SEO)
- `references/vv-portability.md` — mapping to vv-opencode tags
- `references/glossary.md` — 15 терминов (SPEC/PLAN/lifecycle/residual-risk/deploy probe/worker_done/cross-family/…)
- `references/worked-examples.md` — 3 энд-ту-энд примера из реальных волн (quick / 1-итерация wave / pet-project)
- **Operational rules (3 rules):** `project-bootstrap/references/operational-rules.md` — `--to` на worker_done, проверка через global inbox (не handle-scoped check), writer-swap при API retry storm. Читать при диспетчеризации.

## Anti-patterns

- Implementing during interview.
- One PLAN with 40 tasks and no phases.
- Freeform-only plan with no SPEC.
- XML for INTENT (wrong layer).
- Requiring vv-opencode CLI to use this skill.
- Assuming domain-specific workstreams without INTENT + evidence.
- Referencing vv-controller as an agent (default OpenCode agent, not for product work).
- Generating `terminal send` commands for orchestration (only `dispatch --inject`).
- `terminal send` follow-up в работающий opencode TUI — текст уходит в shell («(eval)»), инструкция теряется; для диалога с воркером после старта — orchestration inbox (`send --to dispatch:<id>`) или headless `opencode run` (см. LAUNCH.md.tmpl Prohibited).
- Overwriting SESSION_HANDOFF.md or NEXT_SESSION files (only append pointer / create unique files).
- Creating LAUNCH.md without cross-family check and "Prohibited" section.
- Assigning writer and reviewer from the same model family (blind-spot risk).
- Launching a model without checking availability in model-card.md.
- **Generating LAUNCH.md with copy-paste bash blocks** (`$(...)`, `&&` chains, heredocs). Only sequence descriptions allowed (§6b, LAUNCH.md.tmpl).
- **Skipping or reordering steps in NEXT_SESSION.** Linear In Progress MUST be step 1, not later.
- **Writing wave artifacts outside the specified project directory.** Scope is relative to the REPO ROOT of the opencode-skills project.
---

## Lifecycle Gates (production lessons)

**Context:** production-incident root cause — agent marked "In Review" / "next product" while code not on prod. No hard states: implement ≠ In Review ≠ merged ≠ deployed ≠ owner smoke ≠ Done. This section encodes the lifecycle contract for waves built with this skill.

### Lifecycle States

| State | Definition | Gate |
|-------|-----------|------|
| **Implement done** | Writer finished, own verification green (build/lint/tests per project), implement notes written. **Every claimed path exists on disk** — before `worker_done`: `git status --short` and/or `ls`/`wc -l` prove each CHANGES path. Claimed-but-missing = FAIL (written≠persisted). | `worker_done` or executor signals completion + disk proof |
| **In Review** | Review per selected **Review mode** passed (see §Review modes): Mechanical = no reviewer (gate skipped, lifecycle still enforced); Simple / Ordinary = 1 cross-family reviewer; Strong = 2 complementary lines (GPT-5.5 ∥ GLM/Qwen); fidelity → Strong (§Fidelity Dual Review). 0 material findings (or all closed); writer ≠ reviewer (cross-family) | Synthesis: stricter wins, all material findings closed (template: `review-synthesis.md.tmpl`; action via `fix-round-brief.md.tmpl`) |
| **Commit** | Public paths committed to branch. Only project-tracked files staged — no dev files (AGENTS.md, SESSION_HANDOFF, .agents/) | `git status` clean of dev files. No merge yet |
| **PR** | Pull request opened, reviewable by orchestrator/team. All gates below merge verified independently | PR gate: description complete, reviewers assigned |
| **Merge** | PR approved, merged to main. CI green, no unresolved review threads | Merge gate: CI green |
| **Deploy gate passed** | Deploy probe passed: new routes/paths return ≠ 404 (see Deploy Probe below). 307/302 redirect = OK (route exists) | `curl` probes confirm route existence |
| **On prod (owner residual)** | Deployed. Smoke-tested by orchestrator OR owner | No live smoke = **RESIDUAL-RISK-OWNER-SMOKE**. Owner or next session handles production smoke |
| **Done (complete)** | All gates above passed, handoff written, project tracker updated | Orchestrator signs off |

**Explicit ordering:** Implement done → In Review → Commit → PR → Merge → Deploy gate → On prod (owner smoke OR RESIDUAL-RISK-OWNER-SMOKE) → Done.

Do **not** equate "writer claims Done" with "In Review passed" or "prod-ready". Do **not** collapse commit/PR/merge into "writer Done" — each gate (Commit, PR, Merge) is independent and verified. Do **not** handoff to "NEXT product" until Deploy gate passed.

**Ban:** «NEXT product» handoff while Deploy gate not passed. Handoff with residual risk must say **RESIDUAL-RISK-OWNER-SMOKE** explicitly — never claim Done without deploy proof.

### Wave closeout checklist

Gate before lifecycle-**Done** — tie the contract to concrete folder artifacts:

- STATUS.md final state = `done` (lifecycle enum); every task row reconciled, no orphan `in_review` / `commit`.
- **wave-spec validator:** перед закрытием волны запустить `bash skills/wave-spec/scripts/verify-spec.sh waves/<date>-<slug>/` — exit 0 = PASS. Что проверяется: SPEC = 5 required-секций (Goal, Done_when, Verifier, Scope, Risks); PLAN = минимум одна задача (checkbox/`<task>`/T-heading) + done_when. FAIL = волна не закрывается как Done, пока отсутствующие секции/элементы не будут добавлены.
- SESSION_HANDOFF block appended (project protocol); durable facts → MEMORY.md.
- `reviews/` and `notes/` archived inside the wave folder (`waves/<date>-<slug>/`).
- **Secret redaction:** перед коммитом/handoff прогнать value-aware паттерн (ловит ЗНАЧЕНИЯ, не имена переменных — на типичной волне с `SOURCE_API_KEY`/`.env` даёт 0 FP против 18 у наивного `'token|password|...'`): `grep -rnE '(token|password|api[_-]?key|bearer|secret|Token|Password|Bearer|Secret|TOKEN|PASSWORD|API[_-]?KEY|BEARER|SECRET)[[:space:]:=]+[^[:space:]]*[a-z][^[:space:]]{14,}' waves/<date>-<slug>/`. Механика: (a) явные case-варианты вместо `-i` — иначе `[a-z]` матчит UPPER; (b) требование `[a-z]` в значении отсекает `VAR_NAME`-формы; (c) `{14,}` после буквы = значение 15+ chars. Найденные секреты заменить на `[REDACTED]`. (Владелец работает с ключами внешних сервисов — CRM/склады/пиксели; секрет не должен уехать в handoff/review/tracker.)
- **Archive wave:** после Done — `mv waves/<date>-<slug> waves/archive/<date>-<slug>` (или `git tag wave/<date>-<slug>`). Волны не должны копиться в корне `waves/`.
- Residual risks named explicitly — `RESIDUAL-RISK-OWNER-SMOKE` when there is no live smoke.
- Deploy-probe evidence cited: the exact command + output that proves the artifact reached production.
- **Post-mortem → skill update:** if the wave revealed new operational errors (launch, routing, orchestration), create INTENT.md in `opencode-skills/waves/<date>-skill-improvements/` describing the problems. **Reflect-вопрос:** «какой один урок из этой волны обобщается в правило/ранбук?» → запись в MEMORY.md или `operational-rules.md`.

No probe and no named residual = not Done.

---

## Review modes

**Context:** review depth must be proportional to blast radius. A mechanical rename should not pay for a 2-reviewer dual review; a security / RLS change must not skip one. This section is the **single source of truth for non-fidelity review depth** — it resolves the ambiguity between the In Review lifecycle row (which describes gate wording) and Fidelity Dual Review (which overrides for fidelity ports).

> **Scope:** Review modes qualify the **review gate only**. They do NOT replace execution Modes (`quick` / `wave` / `task` / `program`), do NOT skip approve / LAUNCH / checks / written≠persisted / secret-redaction / deploy / closeout gates, and do NOT cancel `mode=quick` semantics. `Mechanical` = review gate skipped, **NOT** "task done without lifecycle".

### The four modes

| Mode | Reviewer count | Cross-family | Effort | When |
|------|----------------|--------------|--------|------|
| **Mechanical** | 0 (no reviewer) | n/a (no reviewer) | n/a | Review gate skipped — see precedence rule 3 |
| **Simple** | 1 | **yes** (`writer.family ≠ reviewer.family`) | low — model-specific launch contract (see `multi-model-orchestration/references/routing.md`) | Low-risk change that still warrants one independent look |
| **Ordinary** | 1 — default reviewer **Qwen 3.8 Max** | **yes** (swap reviewer family if writer is Alibaba) | default | Default — anything not classified as Mechanical / Simple / Strong |
| **Strong** | 2 complementary lines: **GPT-5.5** (behavioral / security / fidelity lens, mandatory) + **GLM 5.2** (static / architecture lens; swap to **Qwen 3.8 Max** when writer is GLM) | **yes** — both lines must differ from writer **and** from each other | default | High-risk — see precedence rule 2 |

**Cross-family for every mode with a reviewer.** `Mechanical` is the only mode without a reviewer; the Simple-without-cross-family exception is **cancelled** — low-risk work would get exactly the blind spot cross-family exists to prevent.

**Strong lens assignment is fixed by category, not by preference:**
- Security / RLS / auth / secrets / permissions / fidelity / abort-cost-state transitions → **GPT-5.5 mandatory** on the behavioral lens.
- Static parity / architecture / file:line matrix → **GLM 5.2** (default) or **Qwen 3.8 Max** (when writer is GLM).

**Strong "no retries" = do not re-dispatch the reviewer within the same review gate.** It does NOT cancel the existing fix-round contract (max 2 fix-rounds; round 3 → owner escalation — see §Fidelity Dual Review and `fix-round-brief.md.tmpl`). Reviewer dispatch retry / API failure / transport void = non-counting operational failure (`multi-model-orchestration/references/failure-handling.md`); it does not increment task-owned failure count and does not consume the Strong session flag.

### Precedence (floor + stricter-of; NOT first-applicable-wins)

**Algorithm:** a user/repo review requirement sets a **floor** (minimum mode); risk triggers then apply **unconditionally** on top of the floor; the final mode is the **stricter of (floor, risk result)**. Severity order for "stricter": **Strong > Ordinary > Simple > Mechanical**. A low floor NEVER suppresses a Strong risk trigger.

1. **Floor — explicit user or repo review requirement.** `Mechanical` is forbidden whenever a floor exists; the floor is the required mode (at least `Simple`; `Strong` if explicitly requested). Repo review requirements = project-level review policies recorded in AGENTS.md / SPEC (e.g. «all security changes Strong», «fidelity ports Strong»). **NOT review requirements (lifecycle / dispatch gates, observed at any mode and therefore NOT a floor):** `LAUNCH.md` cross-family mandates, `verify-spec.sh` dispatch gate, approve / handoff / closeout gates — these are satisfied regardless of mode and do NOT raise the floor.
2. **Risk trigger (any one) → Strong unconditionally** (even if the floor is lower):
   - security / RLS / auth / secrets / permissions
   - prod deploy / prod config / persistent data / schema migration
   - fidelity port / behavioral parity / reference→platform migration
   - abort / cost / state-transition semantics
   - unknown or unbounded blast radius
3. **Mechanical candidate** — only when: no runtime / control-flow / contract impact AND all applicable checks green AND no floor. Typical: rename, formatting, one-line constant fix without flow change, doc-only edit, type-narrowing annotation.
4. **Simple candidate** — low-risk change that does not meet rule 3 (and the floor is not above Simple). Typical: small refactor with tests, additive non-security config, single-file feature with green tests.
5. **Ordinary** — anything not classified above (default reviewer Qwen 3.8 Max; cross-family swap if writer is Alibaba).

**Selection basis — record ALL applicable inputs, not the first one.** When more than one rule applies, the orchestrator records every applicable basis input in `selection_basis` (STATUS `## Review gate` block + synthesis). Examples: `selection_basis: repo-floor=Ordinary + risk=prod → stricter=Strong`, `selection_basis: user-request=Strong + risk=security → stricter=Strong`, `selection_basis: no-floor + no-risk → Mechanical`. The final mode is the stricter of the floor and the risk result; a low floor NEVER suppresses a Strong risk trigger.

### Selection ownership and persistence

- **Orchestrator selects the mode** from the precedence above and records it in the STATUS `## Review gate` block (see §7) **before** the first reviewer dispatch.
- `review_mode` is part of the worker brief / orchestration packet — the reviewer does NOT compute it post-factum.
- **Solo-default does NOT cancel a selected `review_mode`.** If §1 of `multi-model-orchestration` routes the task solo for execution, the orchestrator still applies the selected Review mode to the review gate (a solo-written low-risk change can still be Mechanical; a solo-written security change is still Strong).
- **`strong_session_used` flag** — **atomic compare-and-set** by the orchestrator in STATUS **immediately before** the first Strong dispatch: `strong_session_used == false` → atomically set `true` → dispatch 2 complementary reviewers; `strong_session_used == true` → **BLOCK** the Strong dispatch, record `blocked_by: strong_session_used` in the STATUS `## Review gate` block, and surface an owner/escalation outcome (not a silent skip, not a second Strong dispatch). The flag is not reset within the same session. Transport/API failure on the first Strong dispatch is a non-counting operational failure (no ledger increment, no automatic second Strong dispatch); retry of the same gate requires an explicit owner decision (or a fix-round against existing findings, which does NOT consume the Strong flag).

### Follow-up review

- **Automatic follow-up: none.** A follow-up review is dispatched ONLY by (a) explicit user request, OR (b) unresolved BLOCKER / HIGH finding from the prior review.
- A follow-up is a NEW review gate with its own mode selection — do not assume the prior mode carries over.
- Follow-up is distinct from fix-round (writer action on existing findings) and from reviewer retry (transport / API recovery).

### Relationship to Fidelity Dual Review

For **fidelity ports, reference→platform migrations, behavioral parity waves**: precedence rule 2 forces **Strong**, which satisfies the Fidelity Dual Review contract (GPT-5.5 ∥ GLM/Qwen as two complementary lenses from different model families). For non-fidelity waves, this section is the single authority — dual review is no longer implied by the In Review row alone.

---

## Fidelity Dual Review

For fidelity ports, reference→platform migrations, or behavioral parity waves:

1. **Dual review mandatory:** a static-parity reviewer (file:line matrix, code structure) ∥ a behavioral-semantics reviewer (hosted semantics, cost/state regressions). Example pair: GLM ∥ Codex — but the ROLE matters, not the product: any two complementary lenses from different model families satisfy this. Single-reviewer fidelity ports are NOT accepted.
2. **Writer ≠ reviewer.** Flash не назначается fidelity-ревьюером (judgment-роль; reasoning-бенчи заметно слабее GLM/GPT-5.5 — GPQA 71.2 vs 91.2/93.6).
3. **MAJOR from any reviewer → fix round before In Review.** Stricter severity wins on contradictions. **2 fix-rounds на ревью; round 3 = эскалация владельцу (не ещё один round).**
4. **No live smoke = RESIDUAL-RISK-OWNER-SMOKE** in handoff. Document explicitly. Do not claim Done — claim Done-with-residual.
5. **Deploy gate:** curl new routes before handoff (see below).

For non-fidelity waves: dual review is recommended but not mandatory. At minimum, writer ≠ reviewer.

---

## Deploy Probe (Universal Pattern)

Before handoff after merge: prove that new/affected routes or artifacts exist at the deploy surface. The probe checks existence, not correctness — correctness is verified at In Review.

```bash
# Existence check — no -L so redirect is the proof (auth-protected routes):
curl -sI https://<deploy-url>/<new-route> | head -1
# Expected: HTTP/... 307 or 302 (redirect = route exists).
# 404 = route missing → fix before handoff.

# OR probe final status (follow redirects, get final HTTP code + effective URL):
curl -sIL -o /dev/null -w '%{http_code} %{url_effective}\n' https://<deploy-url>/<new-route>
# Interpret: final 200/307/401/403 ≠ 404 = route exists.
# final 404 = route missing.
```

Adapt the probe to your deploy surface:
- **Web app:** curl route/path endpoints
- **Static site:** curl page URLs after deploy
- **Package/skill:** verify file existence + size at install path
- **API:** curl API endpoints

Principle: one observable command that proves the artifact reached production. No probe = RESIDUAL-RISK-OWNER-SMOKE.

Evidence: production waves had untracked route files — if deployed without tracking, 404. This gate catches missing artifacts before signoff.

---

## Positioning

wave-spec is a **universal plan-gate + lifecycle skill for 1–3 week product waves across any domain** (development, content, skill-port, translation, orchestration, site rebuild). It is NOT gsd-core, gsd-coordinator, or vv-opencode runtime — no agentic dispatch, no worktree groups, no structured handoff beyond project-local SESSION_HANDOFF. The lifecycle gates above are the contract; everything else is project protocol.
For multi-model orchestration (parallel review, dispatch, fidelity port routing): see `skills/multi-model-orchestration/` — a separate skill for multi-model coordination. wave-spec delegates to it when multi-model review is needed; multi-model does NOT own the plan-gate pipeline.

## Cross-skill compatibility

wave-spec is the **canonical source of truth** for lifecycle gates, fidelity dual review rules, and deploy probe pattern. Other skills reference these definitions.

### Recommended ordering
1. **project-bootstrap** — creates agent infrastructure (AGENTS.md, SESSION_HANDOFF.md, .agents/memory/)
2. **wave-spec** (this skill) — creates SPEC.xml + PLAN.xml with lifecycle gates
3. **multi-model-orchestration** — executes dispatch/review via Orca, references wave-spec lifecycle

### Canonical definitions (referenced by other skills)
- **Lifecycle Gates** (§Lifecycle Gates): 8 states — Implement→In Review→Commit→PR→Merge→Deploy→On Prod→Done
- **Fidelity Dual Review** (§Fidelity Dual Review): 5 rules, dual review mandatory, writer≠reviewer
- **Deploy Probe** (§Deploy Probe): curl existence check pattern

### Skills that depend on wave-spec
- **multi-model-orchestration** — §2b/§2c/§2d reference wave-spec as source of truth. Keeps inline SUMMARY for standalone use.
