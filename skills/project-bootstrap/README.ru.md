# Project Bootstrap — Генератор агентской инфраструктуры

🇬🇧 [English version](README.md)

Скилл для [opencode](https://github.com/opencode-ai/opencode)-агентов, создающий полную агентскую инфраструктуру для проектов любого типа по стандарту [Agent Playbook](https://agents.md) (v0.0.5).

## Почему этот скилл существует

Когда начинаешь новый проект с AI-агентом, первые несколько сессий уходят на изобретение структуры: где хранить правила, как не терять контекст между сессиями, куда класть скрипты. Project-bootstrap делает это за одну сессию — ты описываешь задачу потоком мыслей, а на выходе получаешь готовую структуру `.agents/` с AGENTS.md, памятью, правилами и скиллами.

Скилл **универсален**: работает для технических проектов (бекапы, серверы, интеграции), бизнес-проектов (оцифровка отдела маркетинга) и персональных (поиск работы, резюме, анализ рынка).

## Для каких проектов подходит

| Тип проекта | Примеры | Что создаст |
|------------|---------|-------------|
| Технический | Бекапы серверов, CI/CD, мониторинг | AGENTS.md, rules для процедур, skills со скриптами, commands |
| Бизнес | Оцифровка маркетинга, CRM-интеграция | AGENTS.md, MEMORY.md с ресурсами, rules для процессов, agents-роли |
| Персональный | Поиск работы, резюме, анализ рынка | AGENTS.md + профиль, rules для форматов, agents-помощники |

## Для каких LLM лучше работает

Скилл оптимизирован под **DeepSeek V4** (Pro для основной работы, Flash для субагентов). Ключевые особенности, заточенные под DeepSeek:

- **Closing Anchors** — критические правила размещаются в конце AGENTS.md (recency effect DeepSeek V4)
- **CSA-aware grouping** — связанные правила группируются в одном разделе (бюджет точного контекста ~4000 токенов)
- **Progressive Context (Level 1/2/3)** — уровневый контекст вместо плоской таблицы
- **Anti-Rationalization** — таблица типичных отговорок агента с опровержениями
- **Adversarial Verification** — проверка критических артефактов отдельным агентом

При этом скилл **модель-независим**: все шаблоны и правила — на стандартном Markdown с YAML frontmatter, работает с любым LLM-бекендом (OpenAI, Anthropic, Qwen).

## Что создаёт

| Модуль | Назначение |
|--------|-----------|
| `AGENTS.md` | Главный манифест: описание, архитектура, Progressive Context (L1/L2/L3), Closing Anchors |
| `SESSION_HANDOFF.md` | Динамический контекст между сессиями (.gitignore) |
| `.gitignore` | Исключения для секретов и SESSION_HANDOFF.md |
| `.agents/memory/MEMORY.md` | Персистентная память (append-only) с источниками |
| `.agents/memory/YYYY-MM-DD.md` | Ежедневные заметки (для долгосрочных проектов) |
| `.agents/rules/general.md` | Базовые правила: Anti-Rationalization, Adversarial Verification, Gotchas |
| `.agents/rules/*.md` | Доменные правила с frontmatter (applies_to, priority) |
| `.agents/skills/*/SKILL.md` | Workflow-навыки с gotchas и верификацией |
| `.agents/agents/*.md` | Сабагент-персоны (@role) |
| `.agents/commands/*.md` | Слеш-команды (/command) |
| `.agents/scripts/` | Общие утилиты |
| `readme.md` | Человекочитаемая документация (опционально) |

**Ключевой принцип:** создаётся только то, что задача реально требует. Не раздувается.

## Ключевые особенности v3

### Два режима работы
- **Создание с нуля** — для нового проекта
- **Расширение (extend)** — если AGENTS.md уже существует, скилл читает его и добавляет только новые модули

### Capture step
После генерации скилл записывает в MEMORY.md не только ЧТО создано, но и ПОЧЕМУ: принятые решения, отклонённые альтернативы, отложенные задачи. Это критически важно для следующей сессии.

### Обнаружение данных
Перед генерацией скилл сканирует корень проекта (`ls`) и включает существующие папки с данными в архитектуру AGENTS.md.

### Каталог workflow-паттернов
6 архитектурных паттернов (Classify-and-Act, Fan-out-and-Synthesize, Adversarial Verification, Generate-and-Filter, Tournament, Loop Until Done) — помощь в выборе правильной архитектуры для сложных skills.

## Откуда взялись идеи

- **[Agent Playbook v0.0.5](https://github.com/PromptPasture/agent.md)** — стандарт структуры `.agents/`
- **[Cursor Rules](https://cursor.com/docs/rules)** и **[OpenCode Rules](https://opencode.ai/docs/rules/)** — лучшие практики загрузки контекста
- **[Thariq @ Anthropic](https://x.com/trq212/status/2061907337154367865)** — «A harness for every task: dynamic workflows in Claude Code» — 6 паттернов workflow, adversarial verification, progressive disclosure
- **Владимир Иванов [@turboproject](https://t.me/turboproject)** — популяризация GRACE-подхода, семантические якоря, knowledge graph
- **[vv-opencode (GRACE)](https://github.com/osovv/vv-opencode)** — делегирование через delegation packet, трёхслойная spec-to-code, модульные контракты
- **[AGENTS.md Patterns (Blake Crosley)](https://blakecrosley.com/blog/agents-md-patterns)** — command-first, closure-defined, 150-line limit
- **[Agent1st Protocol v30 (DeepSeek)](https://agents.md)** — CSA citation budget, Closing Anchors, Cascade Breaker, Failure Packet

## Установка

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills
ln -sf ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
```

## Использование

Опиши задачу в любом формате (поток мыслей, ссылка на файл, голосовая заметка) и скажи «создай структуру» или «разверни агента». Скилл сам определит тип проекта и создаст нужную инфраструктуру.

## Структура скилла

```
project-bootstrap/
├── SKILL.md                         # Инструкции для агента
├── references/
│   ├── playbook.md                  # Спецификация Agent Playbook v0.0.5
│   └── workflow-patterns.md         # Каталог 6 архитектурных паттернов
└── assets/templates/
    ├── AGENTS.md.tmpl               # Шаблон манифеста (Closing Anchors + L1/L2/L3)
    ├── SESSION_HANDOFF.md.tmpl      # Межсессионный контекст
    ├── MEMORY.md.tmpl               # Персистентная память (append-only)
    ├── general-rule.md.tmpl         # Базовые правила + Anti-Rationalization
    ├── rule.md.tmpl                 # Доменные правила + Gotchas
    ├── SKILL.md.tmpl                # Шаблон навыка
    ├── command.md.tmpl              # Слеш-команды
    ├── agent-persona.md.tmpl        # Сабагенты
    └── YYYY-MM-DD.md.tmpl          # Ежедневные заметки
```

## Лицензия

MIT — часть [opencode-skills](https://github.com/dimkurilo/opencode-skills).
