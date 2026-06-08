---
name: project-bootstrap
description: >
  Use when пользователь начинает новый проект, хочет расширить существующий, говорит "создай структуру",
  "разверни агента", "настрой проект", описывает новую задачу и хочет получить готовую агентскую среду.
  Создаёт агентскую инфраструктуру (.agents/, AGENTS.md, SESSION_HANDOFF.md, .gitignore, memory, rules, skills, scripts)
  по стандарту Agent Playbook. Do NOT use для мелких правок, аудита, или задач внутри уже настроенного проекта.
disable-model-invocation: true
---

# project-bootstrap

Создаёт агентскую инфраструктуру для нового или существующего проекта.
Следует стандарту Agent Playbook v0.0.5 (https://agents.md).

---

## Workflow

### 0. Принять задачу

Прочитай описание задачи пользователя. Это может быть:
- Свободный текст любой степени детализации
- Ссылка на файл со спецификацией

Не требуй формальной спецификации. Работай с тем, что дано.

**Проверь, существует ли проект:** выполни `ls` в корне проекта. Если найден `AGENTS.md` — это **режим расширения** (см. шаг 0.5). Если `AGENTS.md` нет — **режим создания с нуля**.

### 0.5. Режим расширения (если AGENTS.md уже существует)

1. Прочитай существующий `AGENTS.md` и `.agents/memory/MEMORY.md`.
2. Определи текущую структуру — какие модули уже есть.
3. Примени фазу 1 (анализ «тёмных пятен») **только к новым требованиям** пользователя.
4. В фазе 2 определи, какие модули нужно **добавить** (не дублировать существующие).
5. При генерации **сохрани** существующие файлы, дополни AGENTS.md (новые модули в архитектуру и Loaded Context), создай только новые файлы.
6. В сводке укажи: что уже было, что добавлено.

### 1. Анализ: «тёмные пятна»

Определи, что нужно уточнить ИЗВНЕ (не из памяти модели):

**1a. Внешние инструменты, API и технологии**
Если в задаче упоминаются конкретные инструменты, тулы, API, платформы:
- Сделай webfetch/websearch по запросам вида: `"<name> best practices 2025 2026"`, `"<name> common pitfalls"`.
- **Не ищи CLI-синтаксис, если тул не является CLI-утилитой.** Для веб-сервисов и платформ — ищи API, форматы, ограничения.
- Собери актуальные данные и **обязательно укажи источник:** URL и дату получения. Формат: `<!-- source: https://..., YYYY-MM-DD -->`
- Занеси в MEMORY.md раздел «Инструменты и ресурсы».

**1b. Существующие проекты**
Просканируй соседние проекты на наличие `.agents/memory/MEMORY.md`:
- `glob ../**/.agents/memory/MEMORY.md` от текущей директории.
- Прочитай найденные MEMORY.md — известные грабли, процедуры, инструменты (имена/пути, не пароли).
- Переиспользуй релевантное.

**1b-extra. Существующая opencode-конфигурация**
Если в проекте есть `.opencode/` — просканируй:
- `.opencode/agents/` — существующие сабагенты с model/temperature
- `glob .opencode/agents/*.md` — не дублируй, дополни при необходимости

**1c. API и протоколы**
Если задача касается API (REST, GraphQL, S3, Telegram Bot API, SDK):
- Сделай webfetch документации: эндпоинты, аутентификация, лимиты.
- Занеси в MEMORY.md с источником.

### Decision Framework — выбери архитектурные решения ПЕРЕД шагом 2

| Ситуация | Решение | Пример |
|----------|---------|--------|
| Частая/защищённая операция | MCP (упомянуть в AGENTS.md) | Confluence, Jira, GitHub API |
| Редкая/сложная операция | CLI-команда (в commands/) | `gh pr create`, `aws s3 sync` |
| Цепочка действий | Скрипт в `skills/*/scripts/` | обработка → сохранение → отчёт |
| Повторяемый workflow | Skill с алгоритмом в SKILL.md | «бекап сервера» = 5 шагов |
| Нужны разнотемпературные/разномодельные агенты | `.opencode/agents/` с model+temp | analyze (t=0.25) + review (t=0.25) |
| Аналитический проект с неоднозначными выводами | Multi-model cross-validation | 2-3 модели → синтез |
| Adversarial-проверка результатов | review-агент + цикл review→fix | review → fix → re-review |
| Чувствительные данные (NDA/PII) | `rules/nda-anonymization.md` + пайплайн | anonymize → nda-check → process → deanon |
| Обработка бинарных форматов (DOCX, PDF, XML) | `scripts/` для экстракции текста | pandoc, wxml2txt.py |
| Ключевая внешняя методология (>50 строк) | `.agents/memory/<topic>-research.md` | performia-research.md |

### 2. Анализ: определение структуры

На основе задачи определи, какие модули `.agents/` нужны:

| Модуль | Когда нужен | Признаки в задаче |
|--------|-----------|-------------------|
| `memory/MEMORY.md` | **Всегда** | — |
| `rules/general.md` | **Всегда** | — |
| `rules/*.md` | Есть повторяемые операции | «всегда проверяй», «формат такой-то», «безопасность» |
| `.opencode/agents/` | Нужны сабагенты с разными моделями/temperature | «разные модели», «один анализирует, другой проверяет», «нужен review-агент» |
| `agents/` | Нужны role-play персоны (без model/temperature) | «@роль», «один делает X, другой Y» |
| `commands/` | Есть повторяемые команды | «/status», «/deploy», «/check» |
| `skills/` | Есть workflow из нескольких шагов | «сначала A, потом B, затем C» |
| `skills/*/scripts/` | Нужны детерминированные операции | повторяемые цепочки действий |
| `.agents/scripts/` | Общие утилиты для нескольких скиллов | скрипт используется >1 скиллом |
| `docs/` | Нужна формальная спецификация | Пользователь передал SPEC/PRD/бриф |

**Правило DeepSeek:** модель сама определяет, какие модули создавать. Таблица выше — ориентир, не жёсткая инструкция. DeepSeek Pro достаточно умён, чтобы понять задачу и предложить правильную структуру.

### 3. Генерация: создание файлов

#### 3a. Корневые файлы

**`AGENTS.md`** — шаблон `assets/templates/AGENTS.md.tmpl`. Обязательные секции:
- Описание проекта (1 абзац)
- Архитектура — древовидная схема + существующие папки с данными (обнаруженные `ls`)
- **Loaded Context — Progressive Disclosure:** Level 1 (всегда), Level 2 (по триггеру), Level 3 (on-demand). Группируй связанные файлы вместе (CSA-бюджет ~4000 токенов).
- Протокол работы — **command-first**: конкретные команды, не описания
- Session Handoff — инструкция чтения/обновления SESSION_HANDOFF.md
- **Критические правила — В КОНЦЕ (Closing Anchors).** DeepSeek V4 даёт максимальный вес последним строкам документа (recency effect). Критические правила должны быть в конце, сгруппированы в одном разделе.

**`SESSION_HANDOFF.md`** — шаблон `assets/templates/SESSION_HANDOFF.md.tmpl`.

**`.gitignore`** — создай обязательно:
```
# Secrets
*.env
# но НЕ .example

# Session state
SESSION_HANDOFF.md

# NDA / обезличенные данные
*_clean.txt
*.anon.*
mapping*.json

# OS files
.DS_Store
Thumbs.db
*.swp
*~
```

**`.example`-заглушки:** если проект использует секреты — создай `.example`-файлы с форматом без значений.

**Обнаружение данных:** перед генерацией выполни `ls` корня проекта. Найди существующие папки с данными (interview/, sources/, profile/). Включи их в архитектуру AGENTS.md, даже если они не часть `.agents/`.

#### 3b. `.agents/memory/MEMORY.md`

Шаблон `assets/templates/MEMORY.md.tmpl`. Секции:
- **CONFIRMED_FACTS** — каждый факт с источником
- **Решения** — шаблон для будущих записей
- **Инструменты и ресурсы** — CLI, API, платформы, сервисы (из фазы 1). Каждый с источником.
- **Известные ограничения** — лимиты, грабли

**ВАЖНО:** append-only. Никаких паролей/токенов. Только имена и пути.

**Внешние методологии:** если методология/концепция занимает >50 строк (например, исследование методики оценки) — создай отдельный файл `.agents/memory/<topic>-research.md` и укажи ссылку из MEMORY.md. Не пытайся уместить всё в MEMORY.md.

#### 3c. `.agents/rules/general.md`

Шаблон `assets/templates/general-rule.md.tmpl`. Базовые правила: язык, протокол, данные, верификация + ошибки (CSA-grouped), безопасность, **Common Rationalizations** (таблица отговорок агента), анти-паттерны, gotchas.

#### 3d. Дополнительные модули

**`rules/*.md`** — `.agents/rules/<name>.md` (шаблон `rule.md.tmpl`).
Создавай для повторяемых операций и ограничений. Если задача содержит чувствительные данные — создай `rules/nda-anonymization.md` по шаблону `nda-anonymization.md.tmpl`. Правило с priority:critical автоматически попадает в Critical Rules AGENTS.md.

**`.opencode/agents/`** — `.opencode/agents/<role>.md` (шаблон `opencode-agent.md.tmpl`).
Сабагенты, вызываемые через `task()` с указанием model, provider, temperature, permissions.

**agents/** — `.agents/agents/<role>.md` (шаблон `agent-persona.md.tmpl`).
Role-play персоны без привязки к конкретной модели.
**description в frontmatter — для модели:** описывай КОГДА вызывать агента, не ЧТО он делает.

**commands/** — `.agents/commands/<name>.md` (шаблон `command.md.tmpl`).
**description — КОГДА применять команду.**

**skills/** — `.agents/skills/<name>/`:
- `SKILL.md` — **обязательно**: шаблон `assets/templates/SKILL.md.tmpl`. Frontmatter + workflow + gotchas + верификация.
- `scripts/`, `references/`, `assets/`, `agents/` — опционально.

**`.agents/scripts/`** — общие утилиты для нескольких скиллов. Отрази в архитектуре. Используй шаблоны `script.py.tmpl` или `script.sh.tmpl`.

**docs/** — `docs/YYYY-MM-DD-task-name/` на основе спецификации.

#### 3e. `readme.md` (опционально)

Человекочитаемая документация. Включи: статус, быстрый старт, ключевые сценарии. Не дублируй AGENTS.md.

#### 3f. `.agents/memory/YYYY-MM-DD.md` (опционально)

Если проект долгосрочный (10+ сессий) — создай первую ежедневную заметку по шаблону `assets/templates/YYYY-MM-DD.md.tmpl`. Включи контекст создания и первые наблюдения.

### 4. Верификация

После генерации:
1. `read` каждого созданного файла — проверь, что читается.
2. AGENTS.md содержит Loaded Context для всех модулей.
3. Валидность YAML frontmatter.
4. `.gitignore` включает SESSION_HANDOFF.md и секреты.
5. `.example`-заглушки созданы для секретных файлов.

### 4.5. Capture — запись решений

После верификации запиши в MEMORY.md нового проекта:
- **Принятые решения** — что выбрано и почему (например: «Restic вместо tar.gz: дедупликация 4-6x»)
- **Отклонённые альтернативы** — что рассматривалось и почему отклонено. Указывай КОНКРЕТНЫЙ критерий отклонения: «pandoc вместо wxml2txt: pandoc сохраняет структуру таблиц, wxml2txt — нет»
- **Отложенное** — что решено не делать сейчас и почему (чтобы не забыть и не перерешивать)
- Формат: `### [${DATE}] Решения при создании проекта`

Это критически важно для следующей сессии: агент должен понимать не только ЧТО создано, но и ПОЧЕМУ и почему НЕ выбраны альтернативы.

### 4.6. Сводка

Выведи: что создано, какие решения приняты, что можно добавить позже, какие альтернативы отклонены.

---

## Переменные шаблонов

| Переменная | Шаблон | Что подставить | Откуда взять |
|-----------|--------|---------------|-------------|
| `${PROJECT_NAME}` | AGENTS.md, MEMORY.md, SESSION_HANDOFF | Название проекта (1-3 слова) | Извлеки из задачи |
| `${PROJECT_DESCRIPTION}` | AGENTS.md | Краткое описание (1 строка) | Извлеки из задачи |
| `${DATE}` | AGENTS.md, MEMORY.md | Текущая дата ISO | Системная дата |
| `${PROJECT_FULL_DESCRIPTION}` | AGENTS.md | Полное описание (1 абзац) | Извлеки из задачи |
| `${PROJECT_DIR}` | AGENTS.md | Имя директории проекта | Текущая директория |
| `${ARCHITECTURE_TREE}` | AGENTS.md | Древовидная схема `.agents/` + папок данных | Сгенерируй из созданной структуры + `ls` |
| `${ARCHITECTURE_NOTES}` | AGENTS.md | Пояснения к архитектуре | Опиши неочевидные решения |
| `${LOADED_CONTEXT_L1}` | AGENTS.md | Level 1: всегда загружаемые файлы | MEMORY.md + general.md + SESSION_HANDOFF.md |
| `${LOADED_CONTEXT_L2}` | AGENTS.md | Level 2: по триггеру | Rules и данные с триггер-словами |
| `${LOADED_CONTEXT_L3}` | AGENTS.md | Level 3: on-demand | Skills, commands, agents — только когда нужны |
| `${CRITICAL_RULES}` | AGENTS.md | 3-5 критических правил (в конце!) | Извлеки из задачи + best practices |
| `${WORK_PROTOCOL}` | AGENTS.md | Основные сценарии работы | Опиши command-first: конкретные команды |
| `${SETUP_COMMANDS}` | AGENTS.md | Команды настройки (опционально) | Если нужны |
| `${INIT_NOTE}` | AGENTS.md | Заметка о начальной версии | «Агентская инфраструктура, модули: ...» |
| `${FACTS}` | MEMORY.md | Подтверждённые факты (с источниками) | Из фазы 1 (webfetch, задача) |
| `${INIT_CONTEXT}` | MEMORY.md | Контекст создания проекта | Из задачи пользователя |
| `${INIT_DECISIONS}` | MEMORY.md | Принятые решения | Опиши ключевые выборы |
| `${TOOLS_AND_RESOURCES}` | MEMORY.md | Инструменты и ресурсы | Из фазы 1a с источниками |
| `${LIMITATIONS}` | MEMORY.md | Известные ограничения | Из webfetch |
| `${ANTIPATTERNS}` | MEMORY.md | Чего не делать | Из webfetch + общие |
| `${INIT_EVENT}` | MEMORY.md | Событие создания | Описание созданной структуры |
| `${RULE_FRONTMATTER_EXTRA}` | rule.md | Доп. поля frontmatter | Опционально: `license`, `metadata` |
| `${RULE_NAME}` | rule.md | Имя правила (kebab-case) | Из задачи |
| `${RULE_DESCRIPTION}` | rule.md | **Когда** применять правило | Из задачи: триггер-контекст |
| `${RULE_APPLIES_TO}` | rule.md | Glob-маски | `["**/*"]` для общих, `["scripts/*.sh"]` для специфичных |
| `${RULE_PRIORITY}` | rule.md | low/medium/high/critical | critical для безопасности, high для процедур |
| `${RULE_TITLE}` | rule.md | Заголовок правила | Человекочитаемое название |
| `${RULE_CONTENT}` | rule.md | Тело правила | Из задачи + webfetch |
| `${COMMAND_NAME}` | command.md | Имя команды | Из задачи (kebab-case) |
| `${COMMAND_DESCRIPTION}` | command.md | **Когда** применять | Триггер-контекст |
| `${COMMAND_ARG_HINT}` | command.md | Подсказка аргументов | `"[target]"` или пусто |
| `${COMMAND_ARGUMENTS}` | command.md | Список аргументов | `[target]` или пусто |
| `${COMMAND_USAGE_EXAMPLES}` | command.md | Примеры использования | Из задачи |
| `${COMMAND_BEHAVIOR}` | command.md | Поведение команды | Из задачи: что делает |
| `${COMMAND_OUTPUT}` | command.md | Формат вывода | Из задачи: что возвращает |
| `${AGENT_NAME}` | agent-persona.md | Имя сабагента | Из задачи |
| `${AGENT_INVOKE}` | agent-persona.md | Триггер (`@role`) | Из задачи |
| `${AGENT_DESCRIPTION}` | agent-persona.md | **Когда** вызывать | Триггер-контекст |
| `${AGENT_ROLE}` | agent-persona.md | Название роли | Из задачи |
| `${AGENT_ROLE_DESCRIPTION}` | agent-persona.md | Описание роли | Из задачи |
| `${AGENT_WHEN_TO_INVOKE}` | agent-persona.md | Когда вызывать | Из задачи: триггер |
| `${AGENT_RESPONSIBILITIES}` | agent-persona.md | Обязанности | Из задачи |
| `${AGENT_WORKFLOW}` | agent-persona.md | Протокол работы | Из задачи |
| `${AGENT_OUTPUT_FORMAT}` | agent-persona.md | Формат вывода | Из задачи |
| `${AGENT_EXAMPLE}` | agent-persona.md | Пример использования | Из задачи |

| Переменная | Шаблон | Что подставить | Откуда взять |
|-----------|--------|---------------|-------------|
| `${SKILL_NAME}` | SKILL.md | Имя навыка (kebab-case) | Из задачи |
| `${SKILL_DESCRIPTION}` | SKILL.md | **Когда** использовать навык | Из задачи: триггер-контекст |
| `${SKILL_PURPOSE}` | SKILL.md | Назначение навыка | Из задачи |
| `${SKILL_WHEN}` | SKILL.md | Когда применять | Из задачи |
| `${SKILL_WORKFLOW}` | SKILL.md | Пошаговый алгоритм | Из задачи |
| `${SKILL_VERIFICATION}` | SKILL.md | Как проверить результат | Из задачи |
| `${YYYY_MM_DD}` | YYYY-MM-DD.md | Дата ISO | Системная дата |
| `${NEXT_STEP_1}` | YYYY-MM-DD.md | Следующий шаг | Из контекста сессии |

| Переменная | Шаблон | Что подставить | Откуда взять |
|-----------|--------|---------------|-------------|
| `${AGENT_MODEL}` | opencode-agent.md | Модель (напр. `neuraldeep/gpt-oss-120b`) | Из задачи: какая модель нужна |
| `${AGENT_TEMPERATURE}` | opencode-agent.md | Temperature (0.0-1.0) | Из задачи: нужная креативность |
| `${NDA_WHITELIST}` | nda-anonymization.md | Белый список (markdown-список) | Из задачи: ключевые лица, которые НЕ обезличивать |
| `${SCRIPT_PURPOSE}` | script.py/sh | Назначение скрипта (1 строка) | Из задачи |
| `${SCRIPT_NAME}` | script.py/sh | Имя файла скрипта | Из задачи |
| `${SCRIPT_ENV_VARS}` | script.py | Переменные окружения | Из задачи |
| `${SCRIPT_ARGPARSE}` | script.py | argparse-аргументы | Из задачи |
| `${SCRIPT_MAIN_BODY}` | script.py/sh | Тело скрипта | Из задачи |
| `${SCRIPT_MIN_ARGS}` | script.sh | Минимальное число аргументов | Из задачи |
| `${SCRIPT_USAGE}` | script.sh | Строка использования | Из задачи |
| `${API_SERVICE_NAME}` | api-config.example | Название API-сервиса | Из задачи |
| `${API_CONFIG_FILE}` | api-config.example | Имя конфиг-файла (без .example) | Из задачи |
| `${API_CONFIG_CONTENT}` | api-config.example | Содержимое конфига | Из задачи |

---

## Что НЕ делать

- **НЕ** задавать больше 2 уточняющих вопросов. Создай минимальную структуру и отметь, что добавить позже.
- **НЕ** спрашивать «нужны ли тебе agents/?» — определи по задаче.
- **НЕ** галлюцинировать факты. Не знаешь → `<!-- TODO -->` в MEMORY.md.
- **НЕ** создавать избыточные модули.
- **НЕ** полагаться на память модели для синтаксиса — проверяй через webfetch.
- **НЕ** хранить пароли/токены в `.agents/`.
- **НЕ** требовать формальной спецификации.
- **НЕ** коммитить SESSION_HANDOFF.md.
- **НЕ** вписывать доменные паттерны в скилл — модель сама определит структуру под задачу.

---

## Примеры

### Технический проект: бекапы серверов

**Пользователь:** «Надо бекапить 3 сервера на Backblaze B2. SSH-ключи в ~/.ssh/config.»

**Скилл:** webfetch b2/restic CLI → glob соседних MEMORY.md → создаёт AGENTS.md, SESSION_HANDOFF.md, .gitignore, b2.env.example, MEMORY.md, rules/backup-procedures.md, rules/restore-procedures.md, commands/backup-status.md, skills/backup-goclaw-regular/ + scripts/.

### НЕ-технический проект: поиск работы

**Пользователь:** «Хочу проект для поиска работы: обработка вакансий, резюме под разные роли, отклики. Есть данные в interview/ и profile/.»

**Скилл:** `ls` → видит существующие данные → webfetch hh.ru API, LinkedIn → создаёт AGENTS.md (включает interview/, profile/ в архитектуру), SESSION_HANDOFF.md, .gitignore, MEMORY.md («Инструменты и ресурсы» — hh.ru, LinkedIn, профили), rules/resume-formatting.md, rules/vacancy-analysis.md, skills/match-vacancy/, skills/compile-resume/, skills/analyze-gaps/, agents/hr-auditor.md, agents/vacancy-analyst.md.

---

## Ссылки

- Полная спецификация: `references/playbook.md`
- Каталог workflow-паттернов: `references/workflow-patterns.md`
- Шаблоны генерации: `assets/templates/`
