# opencode-skills

🇬🇧 [English version](README.md)

Коллекция скиллов для агентов [opencode](https://github.com/opencode-ai/opencode) (и совместимых CLI).

Каждый скилл — набор инструкций, промпт-паттернов, скриптов и справочных материалов, которые обучают AI-агента эффективно выполнять конкретную задачу. Скиллы модель-независимы и работают с любым LLM-бекендом opencode; часть также ставится в **Grok** (`~/.grok/skills/`).

## Скиллы

| Скилл | Описание |
|-------|----------|
| [project-bootstrap](skills/project-bootstrap/) | Генератор агентской инфраструктуры по [Agent Playbook](https://agents.md). **v2**: архитектура Variant E (правила в primacy + recency = неизбежны), GRACE-семантические якоря, адаптивная классификация (ops/код/агентский/контент), модельно-специфичные closing anchors (DeepSeek/GLM/universal), двойной аудит. Создаёт AGENTS.md, SESSION_HANDOFF.md, MEMORY.md (append-only), правила с Gotchas, скиллы, персоны агентов, слеш-команды. 14 шаблонов, 50+ переменных, 6 фаз workflow. [Подробнее →](skills/project-bootstrap/README.ru.md) |
| [project-orchestra](skills/project-orchestra/) | **Multi-Agent Kit 1.0** — bootstrap multi-CLI multi-wave program OS: harness inventory, domain-novelty H-panel, матрица ролей, L0 consistency, Stamp Dialogue + R.A.E.H., dispatch dialects, evidence plane. Modes: `full`, `roles-only`, `wire-raeh`, `extend`, `cleanup`, `raeh-review`, `raeh-execute`, `install-dialects`. 9 gate-скриптов, 33 шаблона, 19 references. OpenCode + Grok. Peer project-bootstrap (single-CLI) и wave-spec (черновик волны). [Подробнее →](skills/project-orchestra/README.ru.md) |
| [vs-architect](skills/vs-architect/) | Distribution-level промптинг через Verbalized Sampling (arXiv 2510.01171). Генерирует варианты решений с вероятностными оценками для архитектуры, отладки, стратегии и креативных задач. |

### Какой скилл когда?

| Нужно… | Скилл |
|--------|--------|
| Single-CLI агентский дом (AGENTS / MEMORY / HANDOFF) | **project-bootstrap** |
| Multi-CLI роли, stamps, wave OS | **project-orchestra** |
| Разнообразные варианты решений с вероятностями | **vs-architect** |

## Установка

### Быстрая

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

ln -sfn ~/Projects/opencode-skills/skills/project-bootstrap \
  ~/.config/opencode/skills/project-bootstrap
ln -sfn ~/Projects/opencode-skills/skills/project-orchestra \
  ~/.config/opencode/skills/project-orchestra
ln -sfn ~/Projects/opencode-skills/skills/vs-architect \
  ~/.config/opencode/skills/vs-architect

# Опционально: Grok
ln -sfn ~/Projects/opencode-skills/skills/project-orchestra \
  ~/.grok/skills/project-orchestra
```

### Ручная

```bash
cp -R skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
cp -R skills/project-orchestra ~/.config/opencode/skills/project-orchestra
cp -R skills/vs-architect ~/.config/opencode/skills/vs-architect
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
    ├── project-bootstrap/           # Single-CLI Agent Playbook
    ├── project-orchestra/  # Multi-agent program OS kit (v1.0)
    └── vs-architect/                # Verbalized Sampling
```

## Как создать свой скилл

Скиллы следуют простому соглашению:

1. Директория с именем скилла
2. `SKILL.md` — главный файл инструкций с YAML frontmatter (`name`, `description` — описывай КОГДА использовать)
3. Опционально `references/` — справочные материалы, примеры, теория
4. Опционально `assets/templates/` — шаблоны генерации с `${VARIABLE}`-плейсхолдерами
5. Опционально `scripts/` — вспомогательные скрипты

## Лицензия

MIT
