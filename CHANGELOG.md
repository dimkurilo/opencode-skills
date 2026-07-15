# Changelog

Заметные изменения по релизам.

Формат - [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
версии - [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
