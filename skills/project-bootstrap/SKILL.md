---
name: project-bootstrap
description: >
  Use when пользователь начинает новый проект, хочет расширить существующий, говорит "создай структуру",
  "разверни агента", "настрой проект", описывает новую задачу и хочет получить готовую агентскую среду.
  Создаёт агентскую инфраструктуру (plan.md, AGENTS.md, SESSION_HANDOFF.md, .gitignore, .agents/memory, rules, skills, scripts)
  с адаптацией под тип проекта (ops/код/агентский/контент) и модель (DeepSeek/GLM/универсал).
  Do NOT use для мелких правок, аудита, или задач внутри уже настроенного проекта.
disable-model-invocation: true
---

# project-bootstrap v2

Создаёт агентскую инфраструктуру с адаптацией под тип проекта, модель и сложность.
**Variant E + GRACE-якоря** — правила неизбежны: в преамбуле (primacy) и closing anchors (recency).

**Быстрый старт:** `bash scripts/classify_project.sh` → классификация → выбор шаблона → генерация → contradiction check → двойной аудит.

---

## Workflow

### Фаза 0: Классификация проекта

1. **Запусти классификатор:**
   ```bash
   bash scripts/classify_project.sh <project_dir>
   ```
2. **Прочитай вывод** — JSON с полями: `type`, `complexity`, `variant`, `model_profile`.
3. **Проверь существующий AGENTS.md:** `ls AGENTS.md 2>/dev/null` — если найден → **режим расширения** (не перезаписывать, дополнять).

**Типы проектов и приоритет гибридов** (ops > code > agent > content):

| Тип | Сигналы | Шаблон |
|-----|---------|--------|
| `ops` / `ops-code` | Docker, SSH, .env, nginx, продакшен-риски | Variant E полный (преамбула + чеклист + IF-THEN) |
| `code` / `code-content` | Исходники (py/ts/js), тесты, CI/CD | Variant E + GRACE-якоря |
| `agent` | Скиллы, агенты, промпты, модели | Variant E + модельно-специфичные CLOSING ANCHORS |
| `content` | Статьи, briefs, Excel, интеграции | Облегчённый: преамбула без тех. правил |
| `undetermined` | <3 файлов, нет AGENTS.md | Базовый шаблон с предложением доработать |

**Шкала сложности:**
- `TRIVIAL` — <3 файлов, нет AGENTS.md → простой шаблон, без VS-architect.
- `MODERATE` — 3-20 файлов или есть AGENTS.md → стандартный workflow.
- `UNCERTAIN` — >20 файлов, нестандартная структура → полный анализ + VS-architect.

**Режим расширения** (AGENTS.md существует):
1. Прочитай существующий AGENTS.md и MEMORY.md.
2. Определи текущую структуру — какие модули уже есть.
3. Примени Фазу 1 только к новым требованиям.
4. В Фазе 2 определи, что добавить (не дублировать).
5. При генерации сохрани существующие файлы, дополни AGENTS.md, создай только новое.
6. В сводке: что было, что добавлено.

---

### Фаза 1: Анализ «тёмных пятен»

Определи, что нужно уточнить ИЗВНЕ (не из памяти модели):

**1a. Внешние инструменты, API и технологии**
- webfetch/websearch: `"<name> best practices 2025 2026"`, `"<name> common pitfalls"`.
- **Не ищи CLI-синтаксис** для не-CLI-инструментов.
- Собери данные с источником: `<!-- source: https://..., YYYY-MM-DD -->`.
- Занеси в MEMORY.md → «Инструменты и ресурсы».

**1b. Существующие проекты**
- `glob ../**/.agents/memory/MEMORY.md` — известные грабли, процедуры.
- Если есть `.opencode/` — просканируй `.opencode/agents/` (не дублируй).

**1c. API и протоколы**
- webfetch документации: эндпоинты, аутентификация, лимиты.
- Занеси в MEMORY.md с источником.

**Decision Framework** — выбери архитектурные решения:

| Ситуация | Решение |
|----------|---------|
| Частая/защищённая операция | MCP (упомянуть в AGENTS.md) |
| Редкая/сложная операция | CLI-команда (commands/) |
| Цепочка действий | Скрипт в skills/*/scripts/ |
| Повторяемый workflow | Skill с SKILL.md |
| Разнотемпературные агенты | `.opencode/agents/` с model+temp |
| Аналитический проект | Multi-model cross-validation |
| Adversarial-проверка | review-агент + цикл review→fix |
| NDA/PII | rules/nda-anonymization.md |
| Бинарные форматы (DOCX, PDF) | scripts/ для экстракции |
| Методология >50 строк | `.agents/memory/<topic>-research.md` |

---

### Фаза 2: Определение структуры

На основе classified-типа и задачи определи модули `.agents/`:

| Модуль | Когда нужен |
|--------|-----------|
| `memory/MEMORY.md` | **Всегда** |
| `rules/general.md` | **Всегда** |
| `rules/*.md` | Повторяемые операции, безопасность |
| `.opencode/agents/` | Сабагенты с model/temperature |
| `agents/` | Role-play персоны |
| `commands/` | Повторяемые /-команды |
| `skills/` | Workflow из нескольких шагов |
| `skills/*/scripts/` | Детерминированные операции |
| `.agents/scripts/` | Утилиты для >1 скилла |
| `docs/` | Формальная спецификация (SPEC/PRD) |

**Выбор варианта AGENTS.md** — см. `references/variant-e-structure.md`:
- `variant-e-full` → полная преамбула + чеклист + closing anchors (DeepSeek).
- `variant-e-grace` → Variant E + GRACE-якоря в кодовых файлах.
- `variant-e-model` → модельно-специфичные closing anchors.
- `lightweight` → облегчённая преамбула без технических правил.
- `base` → базовый шаблон.

**Для UNCERTAIN-проектов:** запусти VS-architect для генерации альтернатив структуры.

---

### Фаза 3: Генерация файлов

#### 3a. Корневые файлы

**`plan.md`** — шаблон `assets/templates/plan.md.tmpl`. Стратегический план: фазы, решения, блокеры. **БЕЗ статусов** (статусы → SESSION_HANDOFF.md).

**`AGENTS.md`** — шаблон `assets/templates/AGENTS.md.tmpl`. Структура Variant E:
```
┌─ ЗАГОЛОВОК + описание проекта
├─ 🔴 ПРЕАМБУЛА: N ЖЕЛЕЗНЫХ ПРАВИЛ (IF-THEN)
├─ 📋 ЧЕКЛИСТ ПЕРЕД ДЕЙСТВИЕМ
├─ 📐 ПРОТОКОЛ (command-first)
├─ §1 Известные проблемы / Gotcha's
├─ §2 Failure Packet
├─ §3 Иерархия инструкций
├─ §4 Архитектура + Loaded Context (Progressive Disclosure)
├─ §5 Исторические сессии (ТОЛЬКО ссылки на SESSION_HANDOFF.md и MEMORY.md)
└─ CLOSING ANCHORS (recency-зона, модельно-специфичные)
```

**Критические правила размещаются дважды:** в преамбуле (primacy) и в closing anchors (recency). Правила неизбежны.

**GRACE-якоря** — во всех генерируемых файлах (спецификация: `references/grace-anchors.md`):
```markdown
<!-- @rule id="F-01" priority="critical" -->
➡ Правило
<!-- @rule-end -->
```

**`SESSION_HANDOFF.md`** — шаблон `assets/templates/SESSION_HANDOFF.md.tmpl`. Только операционное состояние. CONFIRMED_FACTS, UNRESOLVED_ISSUES, FAILED_APPROACHES → MEMORY.md.

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

**Обнаружение данных:** `ls` корня → найди существующие папки (interview/, profile/). Включи в архитектуру AGENTS.md.

#### 3b. `.agents/memory/MEMORY.md`

Шаблон `assets/templates/MEMORY.md.tmpl`. Append-only. Секции:
- CONFIRMED_FACTS (с источниками)
- UNRESOLVED_ISSUES (severity: low/medium/high/critical)
- FAILED_APPROACHES
- Решения + отклонённые альтернативы
- Инструменты и ресурсы
- Известные ограничения
- Анти-паттерны

**GRACE-якоря:** `<!-- @anchor id="..." triggers="..." -->` на ключевых фактах.

#### 3c. `.agents/rules/general.md`

Шаблон `assets/templates/general-rule.md.tmpl`. GRACE-якоря на правилах и анти-паттернах.

#### 3d. Дополнительные модули

Создавай по необходимости (rules, agents, commands, skills, scripts, docs). Шаблоны — в `assets/templates/`.

---

### Фаза 4: Contradiction Check + Position Analysis

**4a. Cross-document contradiction check** (ВСЕГДА):

1. Прочитай все Level 1 файлы (AGENTS.md, MEMORY.md, general.md, SESSION_HANDOFF.md).
2. Ищи противоречия:
   - Правило в одном файле противоречит правилу в другом.
   - Команда в одном файле запрещена в другом.
   - Разные значения для одного параметра.
3. Классифицируй: MAJOR (нарушение = отказ) / MINOR (стилистика) / FALSE (разрешённое различие).
4. Исправь MAJOR-противоречия. Запиши в MEMORY.md.

**4b. Position analysis** (AGENTS.md > 200 строк):

1. Измерь позиции критических правил: строки относительно общей длины.
2. Если правила в зоне 30-80% (Lost in the Middle) → перемести в преамбулу или closing anchors.
3. Проверь, что @rule-якоря есть в начале И в конце.

---

### Фаза 5: Верификация + Двойной аудит

**5a. Базовая верификация:**
1. `read` каждого созданного файла — проверь, что читается.
2. AGENTS.md содержит Loaded Context для всех модулей.
3. Валидность YAML frontmatter.
4. `.gitignore` включает SESSION_HANDOFF.md и секреты.
5. `grep -c '@rule' AGENTS.md` > 0 и `grep -c '@anchor' MEMORY.md` > 0.
6. `grep -i 'handoff' AGENTS.md` — ТОЛЬКО ссылки на SESSION_HANDOFF.md (не сами handoff-данные).

**5b. Двойной аудит** (ВСЕГДА):

Запусти двух аудиторов параллельно:
```
task(auditor) + task(auditor-glm)
```

Каждый проверяет:
- 0 MAJOR-противоречий между Level 1 файлами.
- AGENTS.md начинается с преамбулы (не архитектуры).
- Все шаблоны содержат GRACE-якоря.
- Handoff'ы не в AGENTS.md.
- CLOSING ANCHORS присутствуют (если модель DeepSeek).
- Правила неизбежны (primacy + recency).

Если любой аудитор нашёл MAJOR-блокер → назад в Фазу 3 (исправить и перегенерировать).

---

### Фаза 6: Capture + Сводка

**6a. Запись решений в MEMORY.md:**
- Принятые решения — что выбрано и почему.
- Отклонённые альтернативы — что рассматривалось и КОНКРЕТНЫЙ критерий отказа.
- Отложенное — что решено не делать сейчас и почему.

**6b. Сводка:** что создано, какие решения приняты, что добавить позже, какие альтернативы отклонены.

---

## Progressive Disclosure

Основной workflow — в этом файле. Детали — в references/:

| Файл | Когда читать |
|------|-------------|
| `references/variant-e-structure.md` | При генерации AGENTS.md — выбор структуры Variant E |
| `references/grace-anchors.md` | При вставке @rule/@anchor — схема и grep-команды |
| `references/model-profiles.md` | При выборе модельного профиля — DeepSeek vs GLM vs универсал |
| `references/playbook.md` | При создании модулей — condensed Agent Playbook |
| `references/workflow-patterns.md` | При выборе архитектуры skills — каталог паттернов |

---

## Переменные шаблонов

| Переменная | Шаблон | Что подставить | Откуда взять |
|-----------|--------|---------------|-------------|
| `${PROJECT_NAME}` | AGENTS.md, MEMORY.md, SESSION_HANDOFF, plan.md | Название проекта (1-3 слова) | Извлеки из задачи |
| `${PROJECT_DESCRIPTION}` | AGENTS.md | Краткое описание (1 строка) | Извлеки из задачи |
| `${DATE}` | AGENTS.md, MEMORY.md, plan.md | Текущая дата ISO | Системная дата |
| `${MODEL_PROFILE}` | AGENTS.md | Модельный профиль (deepseek/glm/universal) | Из classify_project.sh |
| `${PROJECT_FULL_DESCRIPTION}` | AGENTS.md | Полное описание (1 абзац) | Извлеки из задачи |
| `${PROJECT_DIR}` | AGENTS.md | Имя директории проекта | Текущая директория |
| `${ARCHITECTURE_TREE}` | AGENTS.md | Древовидная схема | Сгенерируй из структуры + `ls` |
| `${ARCHITECTURE_NOTES}` | AGENTS.md | Пояснения к архитектуре | Опиши неочевидные решения |
| `${LOADED_CONTEXT_L1}` | AGENTS.md | Level 1: всегда | MEMORY.md + general.md + SESSION_HANDOFF.md |
| `${LOADED_CONTEXT_L2}` | AGENTS.md | Level 2: по триггеру | Rules с триггер-словами |
| `${LOADED_CONTEXT_L3}` | AGENTS.md | Level 3: on-demand | Skills, commands, agents |
| `${PREAMBLE_RULES}` | AGENTS.md | N железных правил IF-THEN (преамбула) | Извлеки из задачи |
| `${CLOSING_ANCHORS}` | AGENTS.md | Правила в recency-зоне | Дубликат PREAMBLE_RULES + модельные якоря |
| `${WORK_PROTOCOL}` | AGENTS.md | Command-first протокол | Конкретные команды |
| `${SETUP_COMMANDS}` | AGENTS.md | Команды настройки | Если нужны |
| `${INIT_NOTE}` | AGENTS.md | Заметка о создании | «Агентская инфраструктура v2, модули: ...» |
| `${CHECKLIST_ITEMS}` | AGENTS.md | Чеклист перед действием | Извлеки из задачи |
| `${GOTCHAS}` | AGENTS.md | Известные проблемы | Из фазы 1 |
| `${FAILURE_PACKET}` | AGENTS.md | Формат failure packet | Стандартный |
| `${INSTRUCTION_HIERARCHY}` | AGENTS.md | Иерархия инструкций | AGENTS.md > HANDBOOK > правила |
| `${FACTS}` | MEMORY.md | Подтверждённые факты | Из фазы 1 (webfetch) |
| `${INIT_CONTEXT}` | MEMORY.md | Контекст создания | Из задачи |
| `${INIT_DECISIONS}` | MEMORY.md | Принятые решения | Ключевые выборы |
| `${TOOLS_AND_RESOURCES}` | MEMORY.md | Инструменты | Из фазы 1a с источниками |
| `${LIMITATIONS}` | MEMORY.md | Ограничения | Из webfetch |
| `${ANTIPATTERNS}` | MEMORY.md | Чего не делать | Из webfetch + общие |
| `${INIT_EVENT}` | MEMORY.md | Событие создания | Описание структуры |
| `${RULE_FRONTMATTER_EXTRA}` | rule.md | Доп. поля frontmatter | Опционально |
| `${RULE_NAME}` | rule.md | Имя (kebab-case) | Из задачи |
| `${RULE_DESCRIPTION}` | rule.md | **Когда** применять | Триггер-контекст |
| `${RULE_APPLIES_TO}` | rule.md | Glob-маски | `["**/*"]` или специфичные |
| `${RULE_PRIORITY}` | rule.md | low/medium/high/critical | critical для безопасности |
| `${RULE_TITLE}` | rule.md | Заголовок | Человекочитаемое |
| `${RULE_CONTENT}` | rule.md | Тело правила | Из задачи + webfetch |
| `${COMMAND_NAME}` | command.md | Имя команды | kebab-case |
| `${COMMAND_DESCRIPTION}` | command.md | **Когда** применять | Триггер-контекст |
| `${AGENT_NAME}` | agent-persona.md | Имя сабагента | Из задачи |
| `${AGENT_INVOKE}` | agent-persona.md | Триггер (`@role`) | Из задачи |
| `${AGENT_DESCRIPTION}` | agent-persona.md | **Когда** вызывать | Триггер-контекст |
| `${SKILL_NAME}` | SKILL.md | Имя (kebab-case) | Из задачи |
| `${SKILL_DESCRIPTION}` | SKILL.md | **Когда** использовать | Триггер-контекст |
| `${AGENT_MODEL}` | opencode-agent.md | Модель | Из задачи |
| `${AGENT_TEMPERATURE}` | opencode-agent.md | Temperature | Из задачи |
| `${NDA_WHITELIST}` | nda-anonymization.md | Белый список | Из задачи |

---

## Что НЕ делать

- **НЕ** задавать больше 2 уточняющих вопросов.
- **НЕ** спрашивать «нужны ли тебе agents/?» — определи по задаче.
- **НЕ** галлюцинировать факты. Не знаешь → `<!-- TODO -->` в MEMORY.md.
- **НЕ** создавать избыточные модули.
- **НЕ** полагаться на память модели для синтаксиса — проверяй через webfetch.
- **НЕ** хранить пароли/токены в `.agents/`.
- **НЕ** требовать формальной спецификации.
- **НЕ** коммитить SESSION_HANDOFF.md.
- **НЕ** размещать handoff-данные в AGENTS.md — только ссылки.
- **НЕ** пропускать contradiction check — он обязателен.
- **НЕ** пропускать двойной аудит — он обязателен.
- **НЕ** вписывать доменные паттерны в скилл — модель сама определит структуру.

---

## Примеры

### Технический проект: бекапы серверов

**Пользователь:** «Надо бекапить 3 сервера на Backblaze B2. SSH-ключи в ~/.ssh/config.»

**Скилл:** classify → ops → Variant E полный → webfetch b2/restic CLI → создаёт AGENTS.md (преамбула: backup перед каждым действием), SESSION_HANDOFF.md, .gitignore, b2.env.example, MEMORY.md, rules/backup-procedures.md, rules/restore-procedures.md, commands/backup-status.md → contradiction check → двойной аудит.

### Контент-проект: поиск работы

**Пользователь:** «Хочу проект для поиска работы: обработка вакансий, резюме под разные роли. Есть данные в interview/ и profile/.»

**Скилл:** classify → content → lightweight → `ls` → видит данные → webfetch hh.ru API → создаёт AGENTS.md (облегчённая преамбула), SESSION_HANDOFF.md, .gitignore, MEMORY.md, skills/match-vacancy/, skills/compile-resume/ → contradiction check → двойной аудит.

---

## Ссылки

- `references/variant-e-structure.md` — структура Variant E
- `references/grace-anchors.md` — спецификация GRACE-якорей
- `references/model-profiles.md` — DeepSeek vs GLM vs универсал
- `references/playbook.md` — Agent Playbook condensed
- `references/workflow-patterns.md` — каталог паттернов
- `scripts/classify_project.sh` — авто-классификация проекта
