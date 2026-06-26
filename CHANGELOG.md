# Changelog

Все значимые изменения в этом проекте документированы здесь.

Формат основан на [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
проект следует [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] — 2026-06-26

### Added
- **Variant E — новая структура AGENTS.md.tmpl:** преамбула (primacy) + чеклист + протокол + §1-§5 + CLOSING ANCHORS (recency). Правила неизбежны — дублируются в начале и конце файла.
- **GRACE-якоря (`<!-- @rule -->`, `<!-- @anchor -->`):** семантическая inline-разметка во всех генерируемых шаблонах (AGENTS.md, MEMORY.md, SESSION_HANDOFF.md, general.md, plan.md). Позволяют `grep '@rule.*priority="critical"'` для мгновенного поиска критических правил.
- **Адаптивная классификация проекта:** `classify_project.sh` — авто-определение типа (ops/code/agent/content/hybrid) и выбор варианта шаблона (variant-e-full/grace/model/lightweight/base).
- **Модельные профили:** `references/model-profiles.md` — DeepSeek (dual-format closing anchors), GLM (load-order), universal. Closing anchors используют два сосуществующих формата: GRACE-комментарии + XML `<closing_anchors>`.
- **Новые reference-файлы:** `variant-e-structure.md` (архитектура Variant E с универсальными few-shot примерами), `grace-anchors.md` (схема якорей, grep-команды, compliance defence), `model-profiles.md` (DeepSeek vs GLM).
- **Workflow расширен до 6 фаз:** Фаза 0 (классификация) → Фаза 4 (contradiction check + position analysis) → Фаза 5 (двойной аудит: auditor + auditor-glm). VS-architect для UNCERTAIN-проектов.
- **Запрет handoff'ов в AGENTS.md:** §5 содержит только ссылки на SESSION_HANDOFF.md и MEMORY.md.
- **Двойной аудит (auditor + auditor-glm) как обязательный шаг верификации.**
- **Новые переменные шаблонов:** `${MODEL_PROFILE}`, `${PREAMBLE_RULES}`, `${CHECKLIST_ITEMS}`, `${GOTCHAS}`, `${FAILURE_PACKET}`, `${INSTRUCTION_HIERARCHY}`, `${CLOSING_ANCHORS}`.

### Changed
- **SKILL.md полностью переписан** (362 строки): новый workflow с progressive disclosure, ссылки на references/, обновлённая таблица переменных.
- **AGENTS.md.tmpl переписан под Variant E:** архитектура перенесена в §4 (дно), преамбула наверху, closing anchors в конце.
- **MEMORY.md.tmpl, SESSION_HANDOFF.md.tmpl, general-rule.md.tmpl, plan.md.tmpl:** добавлены GRACE-якоря (`@rule`, `@anchor`, `@section`) во все секции.
- **10 остальных .tmpl-шаблонов без изменений** (agent-persona, command, nda-anonymization, opencode-agent, rule, script.py/sh, SKILL, YYYY-MM-DD, api-config.example).
- **Примеры преамбул заменены** с одного ops-специфичного на 4 универсальных few-shot (универсальный/ops/код/контент).
- **Recency-claim скорректирован:** убрано утверждение «DeepSeek V4 recency bias» (не подтверждено исследованиями). Заменено на anchor-entropy механизм (Diederich 2025) + практическую валидацию.

### Fixed
- `classify_project.sh`: исправлен баг `grep -rq` (подавлял stdout → agent-сигнал никогда не срабатывал) — заменён на `grep -rl`.
- `classify_project.sh`: исправлен баг `[ -f "glob"* ]` (падал с ≥2 workflow-файлами) — заменён на `compgen -G`.
- `references/variant-e-structure.md`: добавлены имена вариантов (`variant-e-full`, `lightweight`, `base`) и конкретные правила что включать/опускать для каждого.
- Таблица переменных в SKILL.md: добавлен `${MODEL_PROFILE}`, синхронизированы `${CRITICAL_RULES}` → `${PREAMBLE_RULES}`.

### Removed
- Старая структура AGENTS.md.tmpl (архитектура в primacy, правила в середине — «Lost in the Middle»).
- `${CRITICAL_RULES}` заменён на `${PREAMBLE_RULES}` в шаблоне AGENTS.md.tmpl.

## [0.2.0] — 2026-06-08

### Added
- **Сабагенты `.opencode/agents/`** — новый шаблон `opencode-agent.md.tmpl` с `model`, `temperature`, `permissions` для `task()`-вызова
- **NDA / обезличивание** — новый шаблон `nda-anonymization.md.tmpl` (классификация данных, пайплайн, белый список, верификация)
- **Шаблоны скриптов** — `script.py.tmpl` (argparse, stderr-логгирование) и `script.sh.tmpl` (set -euo pipefail, проверка аргументов)
- **Шаблон API-конфига** — `api-config.example.tmpl` для `.example`-файлов API-сервисов
- **Workflow-паттерны** — `Multi-Model Cross-Validation`, `Review→Fix Loop`, `Data Sanitization Pipeline` (3 новых паттерна)
- **NDA-паттерны в .gitignore** — `*_clean.txt`, `*.anon.*`, `mapping*.json`
- **Decision Framework расширен** — с 4 до 10 строк (разнотемпературные агенты, multi-model, adversarial, NDA, бинарные форматы, внешние методологии)
- **Внешние методологии** — `.agents/memory/<topic>-research.md` для методологий >50 строк
- **Data Discovery** — сканирование `.opencode/agents/` для существующей конфигурации
- **Секция «Итерации»** в SESSION_HANDOFF.md.tmpl — трекер review→fix циклов

### Changed
- **`.agents/agents/` → `.opencode/agents/`** — сабагенты теперь создаются в правильной папке (opencode их видит)
- **Decision Framework перенесён** — ПЕРЕД шагом 2 (определение структуры), а не после шага 4.6
- **`rules/*.md` явный шаг** — в шаге 3d описано создание domain-правил с привязкой к NDA-шаблону
- **agent-persona.md.tmpl** — добавлено примечание о `.opencode/agents/` для model/temperature
- **MEMORY.md.tmpl** — исправлено смешение языков (англ. фраза → рус.)
- **Step 4.5 Capture** — добавлен критерий отклонения альтернатив («почему НЕ выбрали»)

### Fixed
- **Мёртвый код** — удалён `${AGENT_PROVIDER}` из таблицы переменных
- **`${DATE}` scope** — исправлено «Все шаблоны» → «AGENTS.md, MEMORY.md»
- **opencode-agent.md.tmpl** — добавлен `name:` во frontmatter (без него opencode не видит агента)
- **Decision Framework дубликат** — удалён второй экземпляр из конца файла
- **api-config.example.tmpl** — добавлен формат (yaml/env/json/plain)

## [0.1.0] — 2026-06-06

Первый публичный релиз.

### Added
- **Генерация агентской инфраструктуры** — AGENTS.md, SESSION_HANDOFF.md, .gitignore, MEMORY.md, YYYY-MM-DD.md
- **Два режима работы** — создание с нуля и расширение существующего проекта (extend)
- **Closing Anchors** — критические правила в конце AGENTS.md (DeepSeek V4 recency effect)
- **Progressive Context (L1/L2/L3)** — уровневый Loaded Context с триггерами
- **Anti-Rationalization** — таблица отговорок агента с опровержениями
- **Adversarial Verification** — проверка критических артефактов отдельным агентом
- **Capture step** — запись решений, отклонённых альтернатив и отложенных задач в MEMORY.md
- **CSA-grouping** — группировка связанных правил в одном разделе
- **Workflow Patterns** — каталог 6 архитектурных паттернов
- **Обнаружение данных** — `ls` перед генерацией, включение существующих папок в архитектуру
- **Decision Framework** — MCP vs CLI vs Script vs Skill
- **9 шаблонов** — AGENTS.md, SESSION_HANDOFF.md, MEMORY.md, general.md, rule.md, SKILL.md, command.md, agent-persona.md, YYYY-MM-DD.md
- **Таблица переменных** — 52 `${...}` задокументированы
- **Условный webfetch** — не ищет CLI для не-CLI инструментов
- **`.example`-файлы** — заглушки для секретных файлов
- **Правила** — modular rules (general + domain), frontmatter с `applies_to` и `priority`, секция Gotchas
- **Скиллы** — генерация навыков с SKILL.md (workflow + gotchas + верификация), scripts, references, assets, agents
- **Сабагенты** — agent-persona.md с description «КОГДА вызывать»
- **Слеш-команды** — command.md с usage/behavior/output
- Два примера: технический (бекапы серверов) и не-технический (поиск работы)
- `readme.md` — опциональная человекочитаемая документация

### Changed
- **description field** — во всех frontmatter «КОГДА использовать» вместо «ЧТО делает»
- **Верификация** — универсальный язык («Для артефактов» вместо «Для кода: тесты»)
- **MEMORY.md** — «Инструменты и ресурсы» вместо «Инструменты и команды»
- **AGENTS.md** — command-first + closure-defined («Done» = проверяемый результат)

### Removed
- WORKFLOW.md — workflow теперь в теле SKILL.md (как в оригинальном playbook)
- legacy `agents/openai.yaml`
- Доменные анти-паттерны (XML/Markdown, YAML) — заменены на универсальные

### Fixed
- 52 переменные задокументированы (0 расхождений с шаблонами)
- Кросс-проектный скан автоматизирован
- Источники webfetch обязательны (URL + дата) в MEMORY.md
