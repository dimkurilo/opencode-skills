# opencode-skills

🇬🇧 [English version](README.md)

Коллекция скиллов для агентов [opencode](https://github.com/opencode-ai/opencode).

Каждый скилл — это набор инструкций, промпт-паттернов и справочных материалов, которые обучают AI-агента эффективно выполнять конкретную задачу. Скиллы не привязаны к конкретной модели и работают с любым LLM-бекендом, который поддерживает opencode (OpenAI-совместимый API).

## Скиллы

| Скилл | Описание |
|-------|----------|
| [vs-architect](skills/vs-architect/) | Distribution-level промптинг через Verbalized Sampling (arXiv 2510.01171). Генерирует разнообразные варианты решений с оценкой вероятности для архитектурных решений, отладки, стратегии, креативной работы и генерации данных. |

## Установка

### Быстрая установка

```bash
# Клонировать репозиторий
git clone git@github.com:YOUR_USERNAME/opencode-skills.git ~/Projects/opencode-skills

# Симлинк скилла в конфиг opencode
ln -sf ~/Projects/opencode-skills/skills/vs-architect ~/.config/opencode/skills/vs-architect
```

### Ручная установка

Просто скопировать папку скилла:

```bash
cp -r skills/vs-architect ~/.config/opencode/skills/vs-architect
```

После копирования opencode автоматически подхватит скилл при следующем запуске.

### Установка для конкретного проекта

```bash
# В корне проекта
mkdir -p .opencode/skills
cp -r skills/vs-architect .opencode/skills/vs-architect
```

## Структура репозитория

```
opencode-skills/
├── README.md               # Английская версия
├── README.ru.md            # Этот файл (русский)
├── LICENSE                 # MIT
├── .gitignore
└── skills/
    └── vs-architect/       # Конкретный скилл
        ├── SKILL.md
        ├── references/
        │   ├── vs-theory.md
        │   └── examples.md
        └── .gitignore
```

## Как создать свой скилл

Скиллы в этом репозитории следуют простому соглашению:

1. Директория, названная по имени скилла
2. `SKILL.md` — главный файл инструкций с YAML frontmatter (`name`, `description`)
3. Опционально `references/` — справочные материалы, примеры, теория
4. Опционально `scripts/` — вспомогательные shell/Python скрипты
5. Опционально `config/` — шаблоны конфигурации

Если хотите внести свой скилл или сделать форк — придерживайтесь той же структуры.

## Лицензия

MIT
