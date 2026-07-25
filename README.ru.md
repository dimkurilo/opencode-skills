# opencode-skills

🇬🇧 [English version](README.md)

Скиллы для [opencode](https://github.com/opencode-ai/opencode) и совместимых CLI.

В каждом - инструкции, паттерны промптов, скрипты и справка: как агенту сделать конкретную работу. Не привязаны к одной модели; часть ставится и в **Grok** (`~/.grok/skills/`).

## Скиллы

| Скилл | Описание |
|-------|----------|
| [project-bootstrap](skills/project-bootstrap/) | Минимальная кросс-платформенная настройка проекта для Codex, Grok, OpenCode, ZCode и хостов GLM/DeepSeek. Универсальное ядро — короткий `AGENTS.md`; bounded handoff/memory, адаптеры и selective GSD подключаются осознанно. Есть read-only inspection, обратимая миграция и детерминированная проверка. [Подробнее](skills/project-bootstrap/README.ru.md) |
| [vs-architect](skills/vs-architect/) | Verbalized Sampling (arXiv 2510.01171): несколько вариантов решения с оценками вероятности - архитектура, отладка, стратегия, креатив. |
| [multi-model-orchestration](skills/multi-model-orchestration/) | Координация 2+ AI-моделей (GLM 5.2, DeepSeek V4 Pro/Flash, Qwen 3.8 Max, Grok 4.5, GPT-5.6) для параллельного ревью, кросс-валидации и массовой работы через Orca. Таблица маршрутизации, правила dual review, deploy gate, жизненный цикл. [Подробнее](skills/multi-model-orchestration/README.ru.md) |

### Какой скилл когда?

| Нужно… | Скилл |
|--------|--------|
| Минимальный агентский контракт проекта или безопасная миграция legacy | **project-bootstrap** |
| Разные варианты решения с вероятностями | **vs-architect** |
| Координация 2+ AI-моделей для параллельного ревью, кросс-валидации, массовой работы | **multi-model-orchestration** |

## Установка

### Быстрая

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

ln -sfn ~/Projects/opencode-skills/skills/project-bootstrap \
  ~/.config/opencode/skills/project-bootstrap
ln -sfn ~/Projects/opencode-skills/skills/vs-architect \
  ~/.config/opencode/skills/vs-architect
ln -sfn ~/Projects/opencode-skills/skills/multi-model-orchestration \
  ~/.config/opencode/skills/multi-model-orchestration
```

### Ручная

```bash
cp -R skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
cp -R skills/vs-architect ~/.config/opencode/skills/vs-architect
cp -R skills/multi-model-orchestration ~/.config/opencode/skills/multi-model-orchestration
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
    ├── project-bootstrap/  # Минимальный кросс-платформенный bootstrap
    └── vs-architect/       # Verbalized Sampling
    └── multi-model-orchestration/  # Координация нескольких моделей через Orca
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
