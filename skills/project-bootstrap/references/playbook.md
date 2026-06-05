# Agent Playbook — Condensed Reference

Сокращённая версия Agent Playbook v0.0.5 для быстрого доступа при генерации.
Полная версия: https://github.com/PromptPasture/agent.md/blob/main/pages/PLAYBOOK.md

---

## Структура

```
project-root/
├── AGENTS.md                  # Главный манифест + Loaded Context
└── .agents/
    ├── rules/                 # Модульные правила
    │   └── <name>.md
    ├── skills/                # Workflow-навыки
    │   └── <name>/
    │       ├── SKILL.md
    │       ├── WORKFLOW.md
    │       ├── scripts/
    │       └── references/
    ├── commands/              # Слеш-команды
    │   └── <name>.md
    ├── agents/                # Сабагент-персоны
    │   └── <role>.md
    └── memory/                # Память агента
        ├── MEMORY.md          # Долговременная
        └── YYYY-MM-DD.md      # Ежедневные заметки (UTC)
```

---

## AGENTS.md — Главный манифест

Обязательные секции:
1. **Описание проекта** — что это, зачем
2. **Архитектура** — древовидная схема папок
3. **Loaded Context** — таблица файлов с Auto-load/on-demand
4. **Критические правила** — 3-5 самых важных
5. **Протокол работы** — основные сценарии (если есть)

Формат Loaded Context:
```markdown
## Loaded Context

| File | Purpose | Auto-load |
|------|---------|-----------|
| .agents/memory/MEMORY.md | Долговременная память | yes |
| .agents/rules/general.md | Базовые правила | yes |
| .agents/rules/backup.md | Процедуры бекапа | yes |
| .agents/commands/status.md | /status команда | on-demand |
```

---

## Rules — Модульные правила

Файл: `.agents/rules/<name>.md`

Front matter:
```yaml
---
name: Rule Name
description: What this rule governs
applies_to: ["**/*.py", "**/*.sh"]
priority: high
---
```

Правила:
- Пиши императивами, не предложениями
- `applies_to` — glob-маски для авто-загрузки
- `priority`: low | medium | high | critical
- Одно правило = одна тема

---

## Skills — Workflow-навыки

Директория: `.agents/skills/<name>/`

### SKILL.md (обязательно)
```yaml
---
name: skill-name
description: What and when. Keep under 1024 chars.
---
```

### WORKFLOW.md (рекомендуется)
Пошаговый алгоритм. Конкретные шаги, не общие слова.

### scripts/ (опционально)
Детерминированные Python/Bash скрипты.

Правила для скриптов:
- Без интерактивных prompt'ов — только флаги/env/stdin
- `--help` обязателен
- Структурированный вывод (JSON/CSV) в stdout, диагностика в stderr
- Идемпотентность где возможно
- `--dry-run` для деструктивных операций
- Осмысленные exit codes

---

## Commands — Слеш-команды

Файл: `.agents/commands/<name>.md`

```yaml
---
name: command-name
description: What it does
argument-hint: "[target]"
arguments: [target]
disable-model-invocation: true
---
```

Секции: Usage, Behavior, Output Format.

---

## Agents — Сабагент-персоны

Файл: `.agents/agents/<role>.md`

```yaml
---
name: Role Name
invoke: "@role"
description: What this subagent does
---
```

Секции: Identity, Responsibilities, Workflow, Boundaries, Output Format.

---

## Memory — Память агента

### MEMORY.md
```markdown
# Memory

## CONFIRMED_FACTS
- Факт 1
- Факт 2

## Решения
### [YYYY-MM-DD] Название решения
**Контекст:** ...
**Решение:** ...
**Пересмотреть если:** ...

## Инструменты и команды
- `tool --flag` — описание

## Известные ограничения
- Ограничение 1

## Анти-паттерны
- Что не делать 1
```

### YYYY-MM-DD.md (UTC)
```markdown
# YYYY-MM-DD

## Контекст
...

## Наблюдения
...

## Следующие шаги
- [ ] ...
```

---

## Security

- **Никаких** паролей, токенов, ключей в `.agents/`
- `.agents/` коммитится в git — это конфигурация, не секреты
- Subagent permissions ≤ parent agent permissions
