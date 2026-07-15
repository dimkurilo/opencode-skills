# Project Bootstrap v2 - генератор агентской инфраструктуры

🇬🇧 [English version](README.md)

Скилл для [opencode](https://github.com/opencode-ai/opencode): за одну сессию собирает «дом» агента в проекте по стандарту [Agent Playbook](https://agents.md).

**v2** добавляет архитектуру Variant E (правила в начале и в конце файла - их труднее пропустить), GRACE-якоря (правила ищутся через `grep`) и подбор шаблона под тип проекта.

## Зачем он

Новый проект с AI-агентом часто начинается с изобретения структуры: куда правила, как не терять контекст между сессиями, где скрипты. Project-bootstrap делает это за одну сессию - описываешь задачу потоком мыслей, на выходе `.agents/` с AGENTS.md, памятью, правилами и скиллами.

Работает на техпроекте (бекапы, серверы, интеграции), на бизнесе (оцифровка маркетинга) и на личном (поиск работы, резюме). Шаблоны подстраиваются под модель: DeepSeek V4, GLM 5+, universal.

## Для каких проектов

| Тип | Примеры | Вариант | Что получишь |
|-----|---------|---------|--------------|
| Ops / сервер | Docker, бекапы, CI/CD, мониторинг | `variant-e-full` | Полная преамбула, чеклист, gotchas, failure packet, иерархия, closing anchors |
| Код | JS/TS/Python, тесты, интеграции | `variant-e-grace` | Variant E и GRACE-якоря в файлах |
| Агентский | Скиллы, промпты, конфиги моделей | `variant-e-model` | Closing anchors под DeepSeek или GLM |
| Контент / бизнес | Статьи, аналитика, брифы | `lightweight` | Преамбула без техправил |
| Неясно | меньше трёх файлов, новый проект | `base` | Минимум и намёк, что можно докрутить |

## С какими LLM удобнее

Заточен под **DeepSeek V4** (Pro на основную работу, Flash на субагентов). Что под это завязано:

- **Closing Anchors** - важные правила в конце AGENTS.md (recency effect DeepSeek V4)
- **CSA-aware grouping** - связанные правила в одном разделе (бюджет точного контекста около 4000 токенов)
- **Progressive Context (Level 1/2/3)** - контекст слоями, не одной плоской таблицей
- **Anti-Rationalization** - типичные отговорки агента и ответы на них
- **Adversarial Verification** - критические артефакты проверяет отдельный агент

При этом шаблоны обычный Markdown с YAML frontmatter. Бэкенд может быть OpenAI, Anthropic, Qwen - не обязательно DeepSeek.

## Что создаёт

| Модуль | Зачем |
|--------|-------|
| `plan.md` | План для человека: фазы (без статусов), решения, блокеры |
| `AGENTS.md` | Манифест: описание, архитектура, Progressive Context (L1/L2/L3), Closing Anchors |
| `SESSION_HANDOFF.md` | Текущее: фаза, задачи, окружение (в `.gitignore`) |
| `.gitignore` | Секреты и SESSION_HANDOFF.md |
| `.agents/memory/MEMORY.md` | Долгая память (append-only): факты, открытые вопросы, провалы, решения |
| `.agents/memory/YYYY-MM-DD.md` | Дневные заметки (если проект длинный) |
| `.agents/rules/general.md` | База: Anti-Rationalization, Adversarial Verification, Gotchas |
| `.agents/rules/*.md` | Доменные правила с frontmatter (`applies_to`, `priority`) |
| `.agents/skills/*/SKILL.md` | Workflow-скиллы с gotchas и проверкой |
| `.agents/agents/*.md` | Персоны субагентов (`@role`) |
| `.agents/commands/*.md` | Слеш-команды (`/command`) |
| `.agents/scripts/` | Общие утилиты |
| `readme.md` | Документация для людей (по желанию) |

Создаётся только то, что задача реально просит. Лишнего нет.

## Что важно в v3

### Два режима

- **С нуля** - новый проект
- **Extend** - AGENTS.md уже есть: читает и дописывает только новые модули

### Capture step

После генерации в MEMORY.md пишется, **что** создали и **почему**: решения, отклонённые варианты, отложенные задачи. Следующая сессия не гадает.

### Обнаружение данных

Перед генерацией смотрит корень (`ls`) и втаскивает уже существующие папки с данными в архитектуру AGENTS.md.

### Каталог workflow-паттернов

Шесть архитектур (Classify-and-Act, Fan-out-and-Synthesize, Adversarial Verification, Generate-and-Filter, Tournament, Loop Until Done) - подсказка, какую схему взять для сложного скилла.

## Откуда идеи

- **[Agent Playbook v0.0.5](https://github.com/PromptPasture/agent.md)** - стандарт структуры `.agents/`
- **[Cursor Rules](https://cursor.com/docs/rules)** и **[OpenCode Rules](https://opencode.ai/docs/rules/)** - как грузить контекст
- **[Thariq @ Anthropic](https://x.com/trq212/status/2061907337154367865)** - «A harness for every task»: 6 workflow-паттернов, adversarial verification, progressive disclosure
- **Владимир Иванов [@turboproject](https://t.me/turboproject)** - GRACE, семантические якоря, knowledge graph
- **[vv-opencode (GRACE)](https://github.com/osovv/vv-opencode)** - delegation packet, трёхслойная spec-to-code, модульные контракты
- **[AGENTS.md Patterns (Blake Crosley)](https://blakecrosley.com/blog/agents-md-patterns)** - command-first, closure-defined, лимит ~150 строк
- **Agent1st Protocol v30 (DeepSeek)** - CSA citation budget, Closing Anchors, Cascade Breaker, Failure Packet (внутренний протокол)

## Установка

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills
ln -sf ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
```

## Использование

Опиши задачу как удобно (поток мыслей, ссылка на файл, голосовая заметка) и скажи «создай структуру» или «разверни агента». Скилл сам определит тип проекта и соберёт нужные файлы.

## Структура скилла

```
project-bootstrap/
├── SKILL.md                         # Инструкции для агента (6 фаз)
├── README.md / README.ru.md
├── references/
│   ├── playbook.md                  # Спецификация Agent Playbook
│   ├── workflow-patterns.md         # 9 архитектурных паттернов
│   ├── variant-e-structure.md       # Variant E + few-shot примеры
│   ├── grace-anchors.md             # GRACE-якоря + grep-команды
│   └── model-profiles.md            # DeepSeek, GLM, universal
├── scripts/
│   ├── classify_project.sh          # Тип проекта + выбор варианта
│   └── verify-handoff-gate.sh       # Фаза 4c: handoff-destination
└── assets/templates/                # 15 шаблонов
    ├── plan.md.tmpl
    ├── AGENTS.md.tmpl               # Variant E: преамбула + closing anchors
    ├── SESSION_HANDOFF.md.tmpl
    ├── MEMORY.md.tmpl
    ├── general-rule.md.tmpl
    ├── rule.md.tmpl
    ├── SKILL.md.tmpl
    ├── command.md.tmpl
    ├── agent-persona.md.tmpl
    ├── opencode-agent.md.tmpl
    ├── nda-anonymization.md.tmpl
    ├── script.py.tmpl
    ├── script.sh.tmpl
    ├── api-config.example.tmpl
    └── YYYY-MM-DD.md.tmpl
```

## Лицензия

MIT - часть [opencode-skills](https://github.com/dimkurilo/opencode-skills).
