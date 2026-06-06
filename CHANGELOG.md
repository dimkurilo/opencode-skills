# Changelog

Все значимые изменения в этом проекте документированы здесь.

Формат основан на [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
проект следует [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Fixed

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
