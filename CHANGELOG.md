# Changelog

Заметные изменения по релизам.

Формат - [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
версии - [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **wave-spec v1.6.0**:
  - Стек: DeepSeek V4 Flash = оркестратор по умолчанию (полная роль) + writer по умолчанию (single-file/bulk/tests); Qwen 3.8 Max = reviewer/архитектор/бизнес-аналитик (default reviewer); GLM 5.2 = multi-file writer (3+) + second-line reviewer; GPT-5.5 = security/fidelity gate (`codex` CLI). Roles XML в шаблонах обновлён.
  - Именование: «Codex 5.5» → «GPT-5.5» (модель) / «codex» (CLI) — 10 файлов (исторические записи не переписывались).
  - Lean-дельта из vv-opencode 1.2.1 (re-diff): interview дисциплина (§2), `done_when` = исполняемая команда, no_placeholders (prose-only), лимит fix-rounds 2 → эскалация; `vv-portability.md` обновлён до v1.2.1.
  - Карточки моделей = текущее состояние + evidence, без истории переходов; убраны упоминания Claude Code.
  - NEW Benchmarks-секции (2026-08-03) в `model-card.md`/`model-profiles.md`: данные по 5 моделям с evidence-статусами (vendor/indep/anecdotal), включая глубокий ресёрч Qwen 3.8 Max (спеки 983,616 токенов, публичных бенчей нет, ⚠️ не путать с 3.7 Max).
- **multi-model-orchestration / project-bootstrap**: стек и именование синхронизированы (Flash/Qwen/GLM/GPT-5.5); model-profiles дополнены Qwen 3.8 Max и GPT-5.5.
- **wave-spec**: format policy reconciliation (format triage 2026-08, 5/5) — секция `## XML vs Markdown (policy)` в SKILL.md приведена в соответствие с §2 (~строка 128): default = Markdown с required-sections (Goal, Done_when, Verifier, Scope, Risks), XML опционален. Одна точка правды по XML vs MD (устранён дрейф формата в волнах: 07-25 XML, 07-27 MD, 08-02 без SPEC). README.md + README.ru.md синхронно обновлены. NEW портативный валидатор `skills/wave-spec/scripts/verify-spec.sh` (bash + grep, без рантайма, macOS/Linux) — встроен в wave-closeout checklist (верификация на обоих format-ab-образцах: PASS для MD и XML).
- **multi-model-orchestration / project-bootstrap**: карточка Qwen 3.8 Max обновлена по официальному GA-блогу `qwen.ai/blog?id=qwen3.8` (2026-08-03): vendor-бенчи (GPQA-D 92.6, Terminal-Bench 2.1 86.6, OSWorld-V 86.1, IFBench 82.8, PaperBench 93.0; SWE-bench Pro 67.7 — ниже Fable 5 80.0; independent verification pending), спеки 2.4T/95B active + 1M context, first open-weight Max-class (веса «next week», на дату проверки не вышли), цена официально не опубликована. Обновлены: `model-card.md` (role row + Benchmarks + caveats + sources), `routing.md` (таблица Qwen), multi-model `SKILL.md` (§2), `model-profiles.md` (зеркало — sibling-синхронизация). Роли не меняются: Qwen = default reviewer/архитектор (НЕ кодер — slow).
- **wave-spec / multi-model-orchestration**: убраны inline-ченджлоги из SKILL.md (wave-spec §Changelog, multi-model trailing HTML-комментарий). Причины: история версий принадлежит корневому CHANGELOG.md; inline-ченджлог = контекстный балласт при каждой загрузке скилла + дрейф (v1.6.0 числился раньше v1.5.0); HTML-комментарий в multi-model SKILL.md принудительно переводил редактор в code mode («Editable only in code mode because this file contains HTML, JSX, or MDX»).

### Added
- **multi-model-orchestration v1.7.0**:
  - 3 operational rules в SKILL: §4 brief structure (explicit `--to` example + writer-swap rule self-protection clause), §5 failure handling (verify-arrival rule queue arrival + writer-swap rule protocol rows), §10 Orca commands cross-ref to operational-rules.md
  - `references/worker-contract.md`: anti-pattern "Reconstructing send from memory" (worker_done rule) с production incident evidence
  - `references/failure-handling.md`: 2 new failure modes — "Message Routing Void" (verify-arrival rule) + "API Retry Storm — Writer Swap" (writer-swap rule) с detection/recovery protocols
- **project-bootstrap v2.1.0**:
  - NEW `references/operational-rules.md`: canonical 3 operational rules reference для embedding в generated AGENTS.md
  - `assets/templates/AGENTS.md.tmpl`: 2 new conditional placeholders `${OPERATIONAL_RULES_MULTI_MODEL}` (преамбула) + `${OPERATIONAL_RULES_RECENCY}` (closing anchors) — включаются для multi-model project type
  - SKILL.md: variant-e-model expanded с multi-model detection logic; placeholders table expanded с 2 new entries; banner → v2.1.0
- **AGENTS.md (repo dev)**: преамбула расширена с 4 до 7 железных правил (3 operational rules + 4 существующих) + closing anchors extended с 3 до 6 compressed правил

- **wave-spec v1.4.0**:
  - LAUNCH.md auto-generation (step 6b): cross-family check, per-model brief templates (6 models), prohibitions, versioning. No copy-paste bash — sequence description only
  - NEXT_SESSION pattern (step 6c): **steps + verification gates format** (model-agnostic). Step 0 = load `orca skills get orchestration`. 8 steps with concrete gates. No copy-paste bash blocks. Linear woven into flow (step 1 = In Progress, step 7 = comment + In Review)
  - Iteration handoff (step 7): unique per-iteration files, root SESSION_HANDOFF.md as pointer
  - Linear workflow generation (step 6d): parametric template with {{language}}, APPEND on new wave
  - Linear validation checklist in dispatch prep
  - PLAN.xml `<roles>` with family + `<family_rule>`
  - Post-mortem → skill update in closeout checklist
  - New templates: LAUNCH.md.tmpl, iteration-handoff.md.tmpl, NEXT_SESSION.md.tmpl, linear-workflow.md.tmpl
  - worker-brief.md.tmpl + fix-round-brief.md.tmpl: written≠persisted gate + worker_done CLI rule
- **multi-model-orchestration v1.6.0**:
  - Qwen Code first-class: separate CLI, `/effort`, native worker_done, `--approval-mode yolo`
  - Family field for all models (Alibaba, Zhipu, DeepSeek, OpenAI, xAI) + cross-family routing
  - PRE-DISPATCH GATE (§3): 6-point mandatory checklist before every dispatch
  - POST-WORKER_DONE sequence: verify → Linear → reviewer → wait → synthesis → In Review
  - §10 "Build From Guide, Not From Memory": sequence with gates, no copy-paste bash. References orca-cli + orchestration skills
  - Hard Prohibitions: **11 rules** in `references/prohibitions.md` (single source of truth)
  - Codex 5.5 behavioral regression gate (unique role) + brief template in routing.md
  - Qwen Code brief template, Qwen Code vs OpenCode Qwen table, cross-family pairs table
  - Orca JSON parsing table (result.task.id), terminal send prohibition, Qwen Code failure mode
  - Grok circuit-break on 3+ identical tool calls (P15/P18)
  - worker-contract.md: worker_done delivery rule (CLI only, not text)
  - Cost guidance: Qwen Code (high), Grok (unlimited)
  - GPT-5.6 removed (not used)
  - **Note:** SPEC P13/P17 prescribed "atomic bash heredoc" — superseded by steps+gates format (forces validation against live guide instead of blind bash execution). Better solution to same root cause.

### Changed
- **multi-model-orchestration v1.5** (Qwen skill postmortem P0–P2):
  - **P0:** `worker-contract.md` — live Orca `worker_done` flags (`--task-id`, `--dispatch-id`, `--files-modified`, `--report-path`); body = 3-sentence summary; full contract in report file. **written≠persisted** gate for all implement workers (`git status`/`ls` before success `worker_done`). **model-card.md** — launch pins for Codex 5.5 + GPT-5.6 (native Codex CLI) and all OpenCode agents.
  - **P1:** bilingual README layout includes `model-card.md`; SKILL §13 cost table + Codex row; deploy curl canonical only in `routing.md` (SKILL §2b = principle + pointer); heartbeat row in SKILL §5.
- **Routing-fix wave**:
  - multi-model-orchestration/README.md + README.ru.md: sync "7 explicit gates" → "8 states (see wave-spec §Lifecycle Gates)"
  - multi-model-orchestration/SKILL.md: §2c Rule 1 add "two complementary lenses from different model families" guard (MAJOR, ensemble FM2); §2b Deploy add "probe checks existence, not correctness" qualifier (MINOR, ensemble FM3)
  - wave-spec/SKILL.md: §6b version-anchor — frontmatter `version: 1.4.0` (metadata cross-reference); canonical Lifecycle/Fidelity/Deploy sections unchanged
  - wave-spec/assets/templates/NEXT_SESSION.md.tmpl: Orca bypass guard added (production incident; aligns with §3 Role Lock)
  - .agents/scripts/lint-skill.sh: cross-reference drift detector — diff SUMMARY blocks against cited wave-spec sections (ensemble dominant risk mitigation)
  - lint PASS on all 3 skills (wave-spec, multi-model-orchestration, project-bootstrap)
- **Cross-family review (routing-fix wave)**: fallback writer (took over from primary writer after API timeout) ∥ reviewer = valid cross-family. 0 MAJOR, 0 escalation. **Deviation:** single-reviewer fallback (originally planned double review; fallback promoted to writer after primary stuck on retry #10).

### Fixed
- **wave-spec v1.4.1** — NEXT_SESSION template naming fix: the single ambiguous `assets/templates/NEXT_SESSION.md.tmpl` (iteration steps 0–8) is renamed to `NEXT_SESSION_ITER.md.tmpl`; a new `NEXT_SESSION.md.tmpl` is the root pointer (table of iterations + current pointer). SKILL.md §6c now references BOTH templates with MANDATORY both-files wording. Root cause of data-migration T01 writing iteration content into `NEXT_SESSION.md` instead of `NEXT_SESSION_<iter>.md`. Backward compatible — `NEXT_SESSION.md.tmpl` still resolves (now to the pointer).
- README drift source resolved (production-incident reproduction path).
  - **P2:** deploy gate generalized (principle-first); Qwen §2 row marks fidelity writer; Solo Defaults table filled in `routing.md`; SKILL changelog comment → v1.5.
- **multi-model-orchestration:** Qwen agent pin is now **versionless** — default OpenCode agent is `A/agent1st_qwen-3.8` (`~/.config/opencode/agents/A/agent1st_qwen-3.8.md`). Versioned `v5.1` / `v5.2` agent files may remain on disk as history/rollback only; skills always pin the versionless name — protocol content lives inside the agent file, not the skill. Documented in `references/model-card.md` + `routing.md`.
- **wave-spec v1.3** — post-mortem fix-round wave: templates reconciled with reality (SPEC optional review-provenance; PLAN attribute-style tasks as primary idiom, neutral gate wording, `model_hint` clarified; STATUS state enum = lifecycle states). Fidelity dual review generalized from model names to roles (static-parity ∥ behavioral-semantics; example pair GLM∥Codex; writer≠reviewer, Flash excluded, single-reviewer NOT accepted). New `review-synthesis.md.tmpl` + `fix-round-brief.md.tmpl` + `ASSUMPTIONS.md.tmpl`. Worker-brief template aligned to the Orca contract (ROLE/MODE + 3-sentence `worker_done` + SUMMARY/EVIDENCE/CHANGES/RISKS/BLOCKERS). Added wave-closeout checklist, top Positioning block, program-maps quality-bar cross-link + book/fidelity worked walks.
- **wave-spec v1.2** — de-SEO reframe: universal plan-gate for development, content, skill-port, translation, orchestration, and site rebuild. New `references/program-maps.md` with 4 domain-specific menus (skill-port, translation, fidelity port, SEO as optional §4). SPEC/PLAN templates neutral — SEO workstream enum replaced with domain-agnostic placeholders + program-maps pointer. INTENT Sites/URLs→Targets, Stack neutral. Scaling section rewritten: program→waves pattern with worked examples = successive skill-port waves + product-port example; WooCommerce P0–P7 table removed as default. Quality bar, anti-patterns, positioning de-SEO'd. `references/seo-program-map.md` deleted — content migrated to program-maps §4.
### Added
- **multi-model-orchestration v1.3** — new public skill: coordinate 2+ AI models (DeepSeek V4 Flash, Qwen 3.8 Max, GLM 5.2, Codex 5.5) for parallel review, cross-validation, and bulk work via Orca orchestration. Includes production routing table, fidelity port dual review rules, deploy gate with corrected curl probe, lifecycle states with commit→PR→merge chain, and writer replaceability pattern.

### Changed
- **SKILL.md (multi-model-orchestration):** expanded from v1.2 with 4 new subsections (§2b–§2d), deploy gate curl pattern corrected from `-sI -L | head -1` to dual-pattern (no-`-L` for auth-protected, `-sIL -w` for final status).
- **routing.md:** added production routing table section (7 task types, synthesis rules, deploy gate, writer replaceability). Codex naming standardized to "Codex 5.5".

### Fixed
- **Deploy probe (MAJOR):** corrected `curl -sI -L ... | head -1` which read first redirect status, not final. New dual pattern: `-sI` (no `-L`) for auth-gated route existence proof; `-sIL -w '%{http_code} %{url_effective}'` for final status probe.
- **Lifecycle chain (MAJOR):** added explicit commit→PR→merge steps between In Review and Deploy gate in SKILL.md §2d to prevent premature Linear Done before merge/deploy/owner smoke.

 
## [0.8.0] - 2026-07-16

### Added
- **project-bootstrap inspector** - read-only `inspect_project.sh` inventory with `KEEP` / `MOVE` / `REMOVE` / `OPTIONAL` / `UNKNOWN` signals; suspected secrets are reported only by location.
- **project-bootstrap verifier** - deterministic `verify_bootstrap.sh` gate for the universal-min and explicit owner-multicli presets.
- **Compatibility and migration references** - host-vs-model loading boundaries, thin adapter rules, GSD separation, and reversible brownfield examples.
- **Codex metadata** - `agents/openai.yaml` for skill discovery and a default invocation prompt.

### Changed
- **project-bootstrap architecture** - universal core is now one short `AGENTS.md`; the explicit owner-multicli preset adds bounded `SESSION_HANDOFF.md` and curated `.agents/memory/MEMORY.md`.
- **Workflow** - modes are `new`, `inspect`, and `migrate`; existing projects require a read-only manifest and owner-approved proposed diff before writes.
- **Continuity** - handoff is an update-in-place snapshot; memory is curated and bounded rather than an unlimited append-only journal.
- **README EN/RU** - rewritten around minimal bootstrap, safe migration, platform adapters, and selective GSD.

### Removed
- **Mandatory process scaffolding** - Variant E, automatic GRACE/closing anchors, model profiles, root `plan.md`, keyword-selected architecture, always-on cross-audit, and required GSD/memory/rules.
- **Legacy templates and scripts** - classifier, handoff-conformity gate, persona/command/model/rule/script templates, daily notes, and the internal `.plan.md` artifact.

## [0.7.0] - 2026-07-16

### Removed
- **project-orchestra** — no longer published in this repository.
  - Dropped from public git tree (`skills/project-orchestra/` ignored locally if present).
  - Removed from root README EN/RU (table, “which skill when”, install blocks, repo tree).
  - Orchestra-titled GitHub Releases for historical tags retired; see release notes for v0.7.0.

### Notes
- Remaining public skills: **project-bootstrap**, **vs-architect**.
- CHANGELOG entries for 0.5.x–0.6.x kept as history of past monorepo content.

## [0.6.1] - 2026-07-16

### Added
- **project-orchestra 0.6.1** - проверки «можно делать / готово» совпадают с обещаниями скилла, а не только с текстом.
  - **`scripts/verify_stamp_hash.sh`** - перед execute ещё раз хэширует SPEC и PLAN из штампа и сверяет с реальным 64-символьным hash
  - **`scripts/verify_wave_ready.sh`** - зелёный только у **живой** папки волны (SPEC + PLAN + stamp); `waves/_template` - ящик шаблонов, не волна
  - **`assets/templates/waves/SPEC.md.tmpl`** - SPEC волны, если wave-spec не установлен
  - **`assets/templates/bootstrap-lite/`** - свои AGENTS / HANDOFF / MEMORY для старта из четырёх файлов (без вида «полного офиса»)
  - **Installers** - кладут `SPEC.md.tmpl` и `PLAN.md.tmpl` в parent/workstream `_template` как **источники**, не как фейковый live-plan

### Changed
- **`verify_stamp_schema.sh`** - `AGREED=YES` только с настоящим 64-hex hash; заглушки и YES на `_template` - fail
- **`verify_os_gate.sh`** - полная установка: cheatsheets **и** `dispatch-algorithm.md` + `model-shapes.md`
- **Role tables** - в SPEC и Phase 0 появилась колонка формы промпта (shape) по роли
- **`orca-recipes.md`** - pin CLI+модели: **Codex = GPT-5.6**, **OpenCode = GLM 5.2 / DeepSeek V4 Pro**, Claude Code / Grok; ждать `tui-idle`, итог dual - **файлы**; task API по желанию
- **Session policy / production-playbook** - ревью rounds 1..N в одной сессии; execute - новая сессия после проверенного hash
- **`install_bootstrap_lite.sh`** - только lite-шаблоны
- **`install_workstream.sh` / `install_project_os.sh`** - SPEC/PLAN как `*.tmpl`; без «живого» PLAN в `_template`
- **Dispatch pack** - ссылки на соседние файлы в установленном пакете; GPT-5.6 - lean Goal/Success/Stop (OpenAI)
- **README скилла EN+RU** - стек оболочек выровнен; блок «что нового в 0.6.1» человеческим языком
- **VERSION** - 0.6.1

### Fixed
- **`verify_l0_inputs.sh`** - `.grok/` как каталог (`-d`), не файл
- **Stamp / wave UX** - MD и XML равноценны; когда хэшируем; почему execute перепроверяет hash
- **Стек в README** - GPT-5.6 больше не «внутри OpenCode»: **Codex → GPT-5.6**; OpenCode → GLM + DeepSeek

### Notes
- Новый skill name не создавали; wave-spec не поглощали.
- Отложено (не блокер): polish intake/classify, openai.yaml chip, условный `CLAUDE.md` при full install.
- Типичный стек автора: Grok 4.5 (lead) · Claude Code + GLM 5.2 (lead) · OpenCode + GLM/DeepSeek (workers) · **Codex + GPT-5.6** (ревью / dual).

## [0.6.0] - 2026-07-15

### Added
- **project-orchestra 0.6.0** - один вход для «офиса» нескольких агентов: темы подпапками, волны, файл «можно делать», проверка двумя моделями, Orca.
  - Режимы (не больше восьми): `full`, `workstream-new`, `wave`, `bootstrap-lite`, `raeh-review`, `raeh-execute`, `install-dialects`, `extend` (с нормальным описанием шагов)
  - Сначала смотрит папку проекта (git не обязателен), предлагает режим, при нужде задаёт 3-5 вопросов (`references/intake.md`)
  - `scripts/install_workstream.sh` - тема под корнем; **отказывается**, если нет `AGENTS.md` (override: `ALLOW_NO_PARENT=1`)
  - `scripts/install_bootstrap_lite.sh` - ровно четыре файла (без лишнего «полного офиса»)
  - Шаблоны: тема (STATUS/README/INTENT), WAVE_BRIEF, PLAN.md, ROLES, NEXT_SESSION_PROMPT, SESSION_HANDOFF_APPEND
  - Справки: intake, monorepo-workstreams, production-playbook (когда нужны две модели + `DEGRADED_DUAL`), dispatch-iron; **dispatch-algorithm** (роль × семья × форма промпта, в т.ч. GPT-5.6 lean + [OpenAI guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6)); **model-prompt-shapes**; доработаны orca/composition/degraded/cross-audit
  - Phase 0 / dual-review / raeh-execute / install-dialects: обязательный dispatch-algorithm; в `prompts/_dispatch/` ставятся `model-shapes.md` + `dispatch-algorithm.md`
  - План волны: если стоит **wave-spec** - зовём его; иначе шаблоны в пакете; `.md` и `.xml` для hash равноценны
  - README (EN/RU) человеческим языком: когда надо, как папки, когда помогает / нет, откуда идеи
  - Заметки автора: зачем [Orca](https://onorca.dev) ([stablyai/orca](https://github.com/stablyai/orca)), плюсы и минусы, стек (Grok 4.5; Claude Code + GLM 5.2; OpenCode + GLM/DeepSeek; **Codex + GPT-5.6**)

### Changed
- **description** в frontmatter - ловит wave / тему / boot / intake; больше не отшивает черновик волны как «чужой скилл»
- **README** (скилл EN/RU + строка в корневых README) - один вход, версия 0.6.0
- **docs** - humanizer-ru по публичным README: project-bootstrap, vs-architect, корень EN/RU; проза CHANGELOG без длинных тире и канцелярита
- **`.gitignore`** - `research/`, `skills/**/research/` (внутренняя кухня не публикуется)

### Fixed
- **`verify_stamp_schema.sh`** - PLAN не засчитывается по одному SPEC_HASH; при AGREED=YES нужен SPEC_HASH или acceptance.hash (**не** CHECKLIST_VERSION вместо hash)
- **Шаблоны** - убраны дубли готовых `waves/_template/*.md` (источник правды - `.tmpl`)

### Notes
- Полное «поглощение» wave-spec - не в 1.1 (метрики, 1.3). Жёсткая изоляция сессий - 1.2. Новый skill package не создавали.
- Авто-детектор «фейковой двойной проверки» пока нет; если модель одна - пиши `DEGRADED_DUAL`.

## [0.5.1] - 2026-07-13

### Changed
- **Rename:** `skill-work-project-creator` в **`project-orchestra`** (matches multiagent-kit SPEC; aligns with `project-bootstrap` naming).
  - Path: `skills/project-orchestra/`
  - Slash: `/project-orchestra`
  - Install paths: `~/.config/opencode/skills/project-orchestra`, `~/.grok/skills/project-orchestra`
  - Former name kept only as discovery alias in SKILL.md description

## [0.5.0] - 2026-07-13

### Added
- **project-orchestra (первый пакет, monorepo 0.5.0; Multi-Agent Kit)** - bootstrap multi-CLI multi-wave program OS for OpenCode + Grok.
  - Modes: `full`, `roles-only`, `wire-raeh`, `extend`, `cleanup`, `raeh-review`, `raeh-execute`, `install-dialects`
  - Phases 0-4: harness inventory, domain_novelty H-panel (FIRST on / REPEAT off), role matrix, L0 consistency, Stamp Dialogue + R.A.E.H., dispatch dialects, archive hygiene
  - Scripts: `classify_program.sh`, `inventory_harness.sh`, `install_project_os.sh`, `verify_os_gate.sh`, `verify_l0_inputs.sh`, `verify_handoff_gate.sh`, `verify_raeh_ready.sh`, `verify_stamp_schema.sh`, `hash_acceptance.sh`
  - 33 templates (AGENTS/SPEC/STATUS/MEMORY/waves/_template/prompts/_dispatch/profiles) + 19 progressive-disclosure references
  - Bilingual docs: `skills/project-orchestra/README.md` + `README.ru.md`
  - Composition: peer of project-bootstrap (single-CLI) and wave-spec (wave drafting); does not absorb either
- Root README (EN/RU): skill table, install symlinks, “which skill when” matrix

### Notes
- Kit design contract: multiagent-kit-1.0 (Stamp Dialogue authority, no domain-specific hostnames in package)
- Dry-run verified: verify_os_gate / verify_raeh_ready / verify_stamp_schema / verify_handoff_gate / install_project_os - PASS

## [0.4.1] - 2026-06-27

### Fixed
- **Handoff-протокол: устранён конфликт между системными агентами и project-bootstrap.** Системные агентские файлы (v34-pro, v33, v10-glm) велят писать handoff в AGENTS.md (§21/§9.2), но project-bootstrap строит три файла (AGENTS.md - правила, SESSION_HANDOFF.md - оперативное, MEMORY.md - факты). В AGENTS.md.tmpl добавлен явный override §21 в секции §5 + closing anchor `handoff-destination`. SESSION_HANDOFF.md.tmpl и MEMORY.md.tmpl - явный append-only контракт.
- **SESSION_HANDOFF.md.tmpl:** заголовок изменён с «операционное состояние» на «Append-only. Каждая сессия дописывает блок» - чтобы не перезаписывали вместо append.
- **MEMORY.md.tmpl:** ссылка на SESSION_HANDOFF.md дополнена указанием `(append-only)`.

### Added
- **Phase 4c - Handoff-Destination Verification Gate.** Новый скрипт `skills/project-bootstrap/scripts/verify-handoff-gate.sh` с 4 grep-проверками: (1) отсутствие handoff-данных в AGENTS.md, (2) отсутствие секции CONFIRMED_FACTS в AGENTS.md, (3) append-only в заголовке SESSION_HANDOFF.md, (4) ссылка на SESSION_HANDOFF.md с append-only в MEMORY.md. Интегрирован в SKILL.md как Phase 4c.
- **Спека для будущей сессии:** `.agents/specs/agent-neutralization-v2.md` - план нейтрализации хардкод-дестинейшнов в агентских файлах (19 правок в 3 файлах). В этой версии не сделано.

### Changed
- **SKILL.md §5:** «Исторические сессии» на «Handoff между сессиями» с полным протоколом (override §21, append-only, crash-safe, чеклист).
- **Phase 5a check #6:** теперь ссылка на Phase 4c gate (дубль убран).
- **AGENTS.md.tmpl Loaded Context:** SESSION_HANDOFF.md описан как «Журнал сессий (append-only)».
- **opencode-skills собственные AGENTS.md/SESSION_HANDOFF.md/MEMORY.md:** те же фиксы применены к текущему проекту.

## [0.4.0] - 2026-06-26

### Added
- **Variant E - новая структура AGENTS.md.tmpl:** преамбула (primacy) + чеклист + протокол + §1-§5 + CLOSING ANCHORS (recency). Правила стоят и в начале, и в конце - так их труднее пропустить.
- **GRACE-якоря (`<!-- @rule -->`, `<!-- @anchor -->`):** семантическая inline-разметка во всех генерируемых шаблонах (AGENTS.md, MEMORY.md, SESSION_HANDOFF.md, general.md, plan.md). Позволяют `grep '@rule.*priority="critical"'` для мгновенного поиска критических правил.
- **Адаптивная классификация проекта:** `classify_project.sh` - сам определяет тип (ops/code/agent/content/hybrid) и подбирает вариант шаблона (variant-e-full/grace/model/lightweight/base).
- **Модельные профили:** `references/model-profiles.md` - DeepSeek (dual-format closing anchors), GLM (load-order), universal. Closing anchors используют два сосуществующих формата: GRACE-комментарии + XML `<closing_anchors>`.
- **Новые reference-файлы:** `variant-e-structure.md` (архитектура Variant E с универсальными few-shot примерами), `grace-anchors.md` (схема якорей, grep-команды, compliance defence), `model-profiles.md` (DeepSeek и GLM).
- **Workflow: уже 6 фаз:** фаза 0 (классификация), фаза 4 (contradiction check + position analysis), фаза 5 (двойной аудит: auditor + auditor-glm). VS-architect для UNCERTAIN-проектов.
- **Запрет handoff'ов в AGENTS.md:** §5 содержит только ссылки на SESSION_HANDOFF.md и MEMORY.md.
- **Двойной аудит (auditor + auditor-glm) как обязательный шаг проверки.**
- **Новые переменные шаблонов:** `${MODEL_PROFILE}`, `${PREAMBLE_RULES}`, `${CHECKLIST_ITEMS}`, `${GOTCHAS}`, `${FAILURE_PACKET}`, `${INSTRUCTION_HIERARCHY}`, `${CLOSING_ANCHORS}`.

### Changed
- **SKILL.md переписан целиком** (362 строки): новый workflow с progressive disclosure, ссылки на references/, обновлённая таблица переменных.
- **AGENTS.md.tmpl переписан под Variant E:** архитектура в §4 (внизу), преамбула сверху, closing anchors в конце.
- **MEMORY.md.tmpl, SESSION_HANDOFF.md.tmpl, general-rule.md.tmpl, plan.md.tmpl:** GRACE-якоря добавлены (`@rule`, `@anchor`, `@section`) во все секции.
- **10 остальных .tmpl-шаблонов не трогали** (agent-persona, command, nda-anonymization, opencode-agent, rule, script.py/sh, SKILL, YYYY-MM-DD, api-config.example).
- **Примеры преамбул:** вместо одного ops-примера - 4 универсальных few-shot (универсальный/ops/код/контент).
- **Recency-claim:** убрано «DeepSeek V4 recency bias» (не подтверждено исследованиями). Остались anchor-entropy (Diederich 2025) и практическая проверка.

### Fixed
- `classify_project.sh`: баг `grep -rq` (давил stdout, agent-сигнал не срабатывал) - теперь `grep -rl`.
- `classify_project.sh`: баг `[ -f "glob"* ]` (падал, если workflow-файлов два и больше) - теперь `compgen -G`.
- `references/variant-e-structure.md`: имена вариантов (`variant-e-full`, `lightweight`, `base`) и правила, что включать/опускать для каждого.
- Таблица переменных в SKILL.md: добавлен `${MODEL_PROFILE}`; `${CRITICAL_RULES}` приведён к `${PREAMBLE_RULES}`.

### Removed
- Старая раскладка AGENTS.md.tmpl: архитектура в primacy, правила в середине («Lost in the Middle»).
- `${CRITICAL_RULES}` в шаблоне AGENTS.md.tmpl заменён на `${PREAMBLE_RULES}`.

## [0.2.0] - 2026-06-08

### Added
- **Сабагенты `.opencode/agents/`** - новый шаблон `opencode-agent.md.tmpl` с `model`, `temperature`, `permissions` для `task()`-вызова
- **NDA / обезличивание** - новый шаблон `nda-anonymization.md.tmpl` (классификация данных, пайплайн, белый список, верификация)
- **Шаблоны скриптов** - `script.py.tmpl` (argparse, stderr-логгирование) и `script.sh.tmpl` (set -euo pipefail, проверка аргументов)
- **Шаблон API-конфига** - `api-config.example.tmpl` для `.example`-файлов API-сервисов
- **Workflow-паттерны** - `Multi-Model Cross-Validation`, `Review-Fix Loop`, `Data Sanitization Pipeline` (3 новых паттерна)
- **NDA-паттерны в .gitignore** - `*_clean.txt`, `*.anon.*`, `mapping*.json`
- **Decision Framework расширен** - с 4 до 10 строк (разнотемпературные агенты, multi-model, adversarial, NDA, бинарные форматы, внешние методологии)
- **Внешние методологии** - `.agents/memory/<topic>-research.md` для методологий >50 строк
- **Data Discovery** - сканирование `.opencode/agents/` для существующей конфигурации
- **Секция «Итерации»** в SESSION_HANDOFF.md.tmpl - трекер review-fix циклов

### Changed
- **Сабагенты:** путь `.agents/agents/` сменён на `.opencode/agents/` (opencode их видит)
- **Decision Framework перенесён** - ПЕРЕД шагом 2 (определение структуры), а не после шага 4.6
- **`rules/*.md` явный шаг** - в шаге 3d описано создание domain-правил с привязкой к NDA-шаблону
- **agent-persona.md.tmpl** - добавлено примечание о `.opencode/agents/` для model/temperature
- **MEMORY.md.tmpl** - исправлено смешение языков (англ. фраза на рус.)
- **Step 4.5 Capture** - добавлен критерий отклонения альтернатив («почему НЕ выбрали»)

### Fixed
- **Мёртвый код** - удалён `${AGENT_PROVIDER}` из таблицы переменных
- **`${DATE}` scope** - исправлено «Все шаблоны» на «AGENTS.md, MEMORY.md»
- **opencode-agent.md.tmpl** - добавлен `name:` во frontmatter (без него opencode не видит агента)
- **Decision Framework дубликат** - удалён второй экземпляр из конца файла
- **api-config.example.tmpl** - добавлен формат (yaml/env/json/plain)

## [0.1.0] - 2026-06-06

Первый публичный релиз.

### Added
- **Генерация агентской инфраструктуры** - AGENTS.md, SESSION_HANDOFF.md, .gitignore, MEMORY.md, YYYY-MM-DD.md
- **Два режима работы** - создание с нуля и расширение существующего проекта (extend)
- **Closing Anchors** - критические правила в конце AGENTS.md (DeepSeek V4 recency effect)
- **Progressive Context (L1/L2/L3)** - уровневый Loaded Context с триггерами
- **Anti-Rationalization** - таблица отговорок агента с опровержениями
- **Adversarial Verification** - проверка критических артефактов отдельным агентом
- **Capture step** - запись решений, отклонённых альтернатив и отложенных задач в MEMORY.md
- **CSA-grouping** - группировка связанных правил в одном разделе
- **Workflow Patterns** - каталог 6 архитектурных паттернов
- **Обнаружение данных** - `ls` перед генерацией, включение существующих папок в архитектуру
- **Decision Framework** - MCP, CLI, Script или Skill
- **9 шаблонов** - AGENTS.md, SESSION_HANDOFF.md, MEMORY.md, general.md, rule.md, SKILL.md, command.md, agent-persona.md, YYYY-MM-DD.md
- **Таблица переменных** - 52 `${...}` задокументированы
- **Условный webfetch** - не ищет CLI для не-CLI инструментов
- **`.example`-файлы** - заглушки для секретных файлов
- **Правила** - modular rules (general + domain), frontmatter с `applies_to` и `priority`, секция Gotchas
- **Скиллы** - генерация навыков с SKILL.md (workflow + gotchas + верификация), scripts, references, assets, agents
- **Сабагенты** - agent-persona.md с description «КОГДА вызывать»
- **Слеш-команды** - command.md с usage/behavior/output
- Два примера: технический (бекапы серверов) и не-технический (поиск работы)
- `readme.md` - необязательная документация для людей

### Changed
- **description field** - во всех frontmatter: «КОГДА использовать», не «ЧТО делает»
- **Верификация** - общий язык: «Для артефактов», не «Для кода: тесты»
- **MEMORY.md** - «Инструменты и ресурсы» вместо «Инструменты и команды»
- **AGENTS.md** - command-first + closure-defined («Done» - это проверяемый результат)

### Removed
- WORKFLOW.md - workflow теперь в теле SKILL.md (как в оригинальном playbook)
- legacy `agents/openai.yaml`
- Доменные анти-паттерны (XML/Markdown, YAML) - заменены на универсальные

### Fixed
- 52 переменные задокументированы (расхождений с шаблонами нет)
- Кросс-проектный скан автоматизирован
- В MEMORY.md у webfetch обязательны URL и дата
