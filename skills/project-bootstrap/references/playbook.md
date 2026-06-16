# Agent Playbook — Condensed Reference

Сокращённая версия Agent Playbook v0.0.5 для быстрого доступа при генерации.
Полная версия: https://github.com/PromptPasture/agent.md/blob/main/pages/PLAYBOOK.md

---

## Структура

```
project-root/
├── AGENTS.md                  # Главный манифест + Loaded Context
├── plan.md                     # Стратегический план: фазы, решения, блокеры (без статусов)
├── SESSION_HANDOFF.md         # Операционное состояние: фаза, задачи, окружение (.gitignore)
├── .gitignore                 # Исключения: секреты, SESSION_HANDOFF.md, OS-файлы
└── .agents/
    ├── rules/                 # Модульные правила
    │   └── <name>.md
    ├── skills/                # Workflow-навыки
    │   └── <name>/
    │       ├── SKILL.md       # Обязательно: описание и workflow
    │       ├── scripts/       # Опционально: детерминированные скрипты
    │       ├── references/    # Опционально: документация, cheat sheets
    │       ├── assets/        # Опционально: шаблоны, изображения
    │       └── agents/        # Опционально: сабагенты навыка
    ├── commands/              # Слеш-команды
    │   └── <name>.md
    ├── agents/                # Сабагент-персоны
    │   └── <role>.md
    ├── scripts/               # Опционально: общие утилиты (не привязаны к скиллам)
    └── memory/                # Память агента
        ├── MEMORY.md          # Долговременная (append-only)
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
6. **Session Handoff** — инструкция чтения/обновления SESSION_HANDOFF.md и `.agents/memory/MEMORY.md`

Формат Loaded Context:
```markdown
## Loaded Context

| File | Purpose | Auto-load |
|------|---------|-----------|
| SESSION_HANDOFF.md | Состояние между сессиями | yes (по инструкции) |
| .agents/memory/MEMORY.md | Долговременная память | yes |
| .agents/rules/general.md | Базовые правила | yes |
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
- `applies_to` — glob-маски для авто-загрузки (обязательно)
- `priority`: low | medium | high | critical (обязательно)
- Одно правило = одна тема

---

## Workflow Patterns

См. `references/workflow-patterns.md` — каталог из 6 архитектурных паттернов для выбора правильной структуры сложных skills.

---

## Skills — Workflow-навыки

Директория: `.agents/skills/<name>/`

### SKILL.md (обязательно)
```yaml
---
name: skill-name
description: WHEN to use this skill. Describe trigger context, not what it does. Keep under 1024 chars.
---
```

**description — для модели, не для человека.** Модель сканирует описания всех скиллов при старте и решает, какой вызвать. Пиши триггер-контекст: «Use when пользователь просит X», а не описание действия «Делает Y из Z».

Workflow описывается в теле SKILL.md — конкретные шаги, не общие слова.

### Поддиректории (все опциональны)

| Папка | Назначение |
|-------|-----------|
| `scripts/` | Детерминированные Python/Bash скрипты |
| `references/` | Документация, cheat sheets, языковые гайды |
| `assets/` | Шаблоны, изображения, HTML, примеры |
| `agents/` | Сабагенты, используемые workflow навыка |

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
description: WHEN to use this command. Describe trigger context.
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
description: WHEN to invoke this subagent. Describe trigger context.
---
```

Секции: Identity, Responsibilities, Workflow, Boundaries, Output Format.

---

## Memory — Память агента

### MEMORY.md
```markdown
# Memory

> **Append-only:** старые записи не удалять, только дополнять.

## CONFIRMED_FACTS
- Факт 1 <!-- source: URL, YYYY-MM-DD -->
- Факт 2

## Решения
### [YYYY-MM-DD] Название решения
**Контекст:** ...
**Решение:** ...
**Пересмотреть если:** ...

## Инструменты и ресурсы
- `tool --flag` — описание <!-- source: URL --> <!-- source: URL -->

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

## SESSION_HANDOFF.md — Операционное состояние между сессиями

Файл в корне проекта, **в `.gitignore`**, не коммитится.

```markdown
# Session Handoff — Project Name

## CURRENT_FOCUS      # текущая фаза + активная задача
## TASK_BACKLOG       # очередь задач (из plan.md)
## ENVIRONMENT_NOTES  # ОС, shell, директории, лимиты API
## FILE:LINE_ANCHORS  # ключевые точки входа в код
```

CONFIRMED_FACTS, UNRESOLVED_ISSUES, FAILED_APPROACHES → `.agents/memory/MEMORY.md` (долговременная память, коммитится).

Агент читает при старте (вместе с MEMORY.md), обновляет при завершении сессии.

---

## Security

- **Никаких** паролей, токенов, ключей в `.agents/`
- `.agents/` коммитится в git — это конфигурация, не секреты
- Секретные файлы (`.env`, `.config`) — в `.gitignore`
- Для секретных файлов создавай `.example`-заглушки с форматом (без реальных значений)
- SESSION_HANDOFF.md — в `.gitignore`
- Subagent permissions ≤ parent agent permissions
