# opencode-skills

🇬🇧 [English version](README.md)

Коллекция скиллов для агентов [opencode](https://github.com/opencode-ai/opencode).

Каждый скилл — это набор инструкций, промпт-паттернов и справочных материалов, которые обучают AI-агента эффективно выполнять конкретную задачу. Скиллы модель-независимы и работают с любым LLM-бекендом opencode.

## Скиллы

| Скилл | Описание |
|-------|----------|
| [project-bootstrap](skills/project-bootstrap/) | Генератор агентской инфраструктуры по [Agent Playbook](https://agents.md). **v2**: архитектура Variant E (правила в primacy + recency = неизбежны), GRACE-семантические якоря, адаптивная классификация (ops/код/агентский/контент), модельно-специфичные closing anchors (DeepSeek/GLM/universal), двойной аудит. Создаёт AGENTS.md, SESSION_HANDOFF.md, MEMORY.md (append-only), правила с Gotchas, скиллы, персоны агентов, слеш-команды. 14 шаблонов, 50+ переменных, 6 фаз workflow. [Подробнее →](skills/project-bootstrap/README.ru.md) |
| [vs-architect](skills/vs-architect/) | Distribution-level промптинг через Verbalized Sampling (arXiv 2510.01171). Генерирует варианты решений с вероятностными оценками для архитектуры, отладки, стратегии и креативных задач. |

## Установка

### Быстрая

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills
ln -sf ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
ln -sf ~/Projects/opencode-skills/skills/vs-architect ~/.config/opencode/skills/vs-architect
```

### Ручная

```bash
cp -r skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
cp -r skills/vs-architect ~/.config/opencode/skills/vs-architect
```

После копирования opencode автоматически подхватит скилл при следующем запуске.

## Структура репозитория

```
opencode-skills/
├── README.md               # Английская версия
├── README.ru.md            # Русская версия
├── CHANGELOG.md            # История релизов
├── LICENSE                 # MIT
├── .gitignore
└── skills/
    ├── project-bootstrap/  # Генератор инфраструктуры (v2)
    │   ├── SKILL.md
    │   ├── README.md / README.ru.md
    │   ├── references/
    │   │   ├── playbook.md
    │   │   └── workflow-patterns.md
    │   └── assets/templates/   # 9 шаблонов
    └── vs-architect/       # Verbalized Sampling промптинг
        ├── SKILL.md
        ├── README.md / README.ru.md
        └── references/
            ├── vs-theory.md
            └── examples.md
```

## Как создать свой скилл

Скиллы следуют простому соглашению:

1. Директория с именем скилла
2. `SKILL.md` — главный файл инструкций с YAML frontmatter (`name`, `description` — описывай КОГДА использовать, а не ЧТО делает)
3. Опционально `references/` — справочные материалы, примеры, теория
4. Опционально `assets/templates/` — шаблоны генерации с `${VARIABLE}`-плейсхолдерами
5. Опционально `scripts/` — вспомогательные скрипты

## Лицензия

MIT
