# opencode-skills

🇬🇧 [English version](README.md)

Скиллы для [opencode](https://github.com/opencode-ai/opencode) и совместимых CLI.

В каждом - инструкции, паттерны промптов, скрипты и справка: как агенту сделать конкретную работу. Не привязаны к одной модели; часть ставится и в **Grok** (`~/.grok/skills/`).

## Скиллы

| Скилл | Описание |
|-------|----------|
| [project-bootstrap](skills/project-bootstrap/) | «Дом» для одного агента по [Agent Playbook](https://agents.md). **v2**: Variant E (правила в начале и конце файла), GRACE-якоря, классификация проекта (ops / код / агент / контент), closing anchors под DeepSeek и GLM, двойной аудит. Пишет AGENTS.md, SESSION_HANDOFF.md, MEMORY.md, правила, скиллы, персоны, слеш-команды. 14 шаблонов, 50+ переменных, 6 фаз. [Подробнее](skills/project-bootstrap/README.ru.md) |
| [project-orchestra](skills/project-orchestra/) | **v0.6.1 - несколько агентов на одном продукте.** Сначала смотрит папку, при нужде задаёт вопросы, потом общая память, темы-подпапки, волны и файл «можно делать» с реальным hash-gate. Режимы: `full`, `workstream-new`, `wave`, `bootstrap-lite`, review/execute, `extend`. Удобно с [Orca](https://onorca.dev). [Подробнее](skills/project-orchestra/README.ru.md) |
| [vs-architect](skills/vs-architect/) | Verbalized Sampling (arXiv 2510.01171): несколько вариантов решения с оценками вероятности - архитектура, отладка, стратегия, креатив. |

### Какой скилл когда?

| Нужно… | Скилл |
|--------|--------|
| Дом для одного CLI-агента (AGENTS / MEMORY / HANDOFF) | **project-bootstrap** |
| Несколько агентов, темы в одном проекте, волны «план - ревью - сделать» | **project-orchestra** |
| Разные варианты решения с вероятностями | **vs-architect** |

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

После копирования opencode подхватит скилл при следующем запуске.

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
    ├── project-orchestra/  # Несколько агентов на одном продукте (v0.6.1)
    └── vs-architect/                # Verbalized Sampling
```

## Как создать свой скилл

Простое соглашение:

1. Папка с именем скилла
2. `SKILL.md` - главный файл с YAML frontmatter (`name`, `description` - пиши, **когда** вызывать)
3. По желанию `references/` - справка, примеры, теория
4. По желанию `assets/templates/` - шаблоны с `${VARIABLE}`
5. По желанию `scripts/` - вспомогательные скрипты

## Лицензия

MIT
