# Changelog

Все значимые изменения в этом проекте документированы здесь.

Формат основан на [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
проект следует [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Fixed

## [3.0.0] — 2026-06-06

### Added
- **Extend-режим** — скилл теперь умеет расширять существующий проект (шаг 0.5: проверка AGENTS.md → чтение → добавление новых модулей)
- **Closing Anchors** — критические правила размещаются в конце AGENTS.md (DeepSeek V4 recency effect)
- **Progressive Context (Level 1/2/3)** — уровневый Loaded Context вместо плоской таблицы
- **Anti-Rationalization** — таблица типичных отговорок агента с опровержениями в general-rule.md.tmpl
- **Adversarial Verification** — правило проверки критических артефактов отдельным агентом
- **Capture step** — запись принятых решений, отклонённых альтернатив и отложенных задач в MEMORY.md
- **CSA-grouping** — связанные правила группируются в одном разделе (бюджет ~4000 токенов)
- **Workflow Patterns catalog** — 6 архитектурных паттернов в `references/workflow-patterns.md`
- **Обнаружение данных** — `ls` перед генерацией, включение существующих папок в архитектуру
- **SESSION_HANDOFF.md** — отдельный файл для динамического контекста между сессиями (.gitignore)
- **Шаблон SKILL.md.tmpl** — для генерации навыков
- **Шаблон YYYY-MM-DD.md.tmpl** — для ежедневных заметок
- **Таблица переменных** — 52 переменные `${...}` задокументированы в SKILL.md
- **Условный webfetch** — не ищет CLI-синтаксис для не-CLI инструментов
- **`.example`-файлы** — опциональные заглушки для секретных файлов
- Два примера: технический (бекапы) и не-технический (поиск работы)

### Changed
- **description field** — во всех frontmatter теперь «КОГДА использовать», а не «ЧТО делает» (Thariq tip #6)
- **general-rule.md.tmpl** — универсальный язык верификации («Для артефактов» вместо «Для кода: тесты»)
- **MEMORY.md.tmpl** — «Инструменты и ресурсы» вместо «Инструменты и команды»
- **AGENTS.md.tmpl** — command-first + closure-defined, CSA-бюджет предупреждение
- **rule.md.tmpl** — добавлены `applies_to` и `priority` как обязательные поля, секция Gotchas
- **playbook.md** — обновлённая структура: `.agents/scripts/`, опциональные `references/`/`assets/`/`agents/` в skills
- **SKILL.md** — полный rewrite workflow: 17 шагов (0 → 4.6), таблица переменных, два примера

### Removed
- **WORKFLOW.md** — workflow теперь в теле SKILL.md (как в оригинальном playbook)
- **legacy `agents/openai.yaml`** — не используется, удалён
- Доменные анти-паттерны (XML/Markdown, YAML) — заменены на универсальные

### Fixed
- 52 переменные `${...}` задокументированы (0 расхождений с шаблонами)
- Кросс-проектный скан автоматизирован (`glob ../**/.agents/memory/MEMORY.md`)
- Источники webfetch обязательны (URL + дата) в MEMORY.md

---

## [2.0.0] — 2026-06-05

### Added
- Первая версия скилла: AGENTS.md, MEMORY.md, rules (general + domain), commands, skills, agents, docs
- Decision Framework: MCP vs CLI vs Script
- Шаблоны: AGENTS.md.tmpl, MEMORY.md.tmpl, general-rule.md.tmpl, rule.md.tmpl, command.md.tmpl, agent-persona.md.tmpl

---

## [1.0.0] — 2026-05-31

### Added
- Начальная версия: базовая генерация AGENTS.md + MEMORY.md + general.md

[3.0.0]: https://github.com/dimkurilo/opencode-skills/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/dimkurilo/opencode-skills/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/dimkurilo/opencode-skills/releases/tag/v1.0.0
