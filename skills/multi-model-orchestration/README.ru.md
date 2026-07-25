# Multi-Model Orchestration

🇬🇧 [English version](README.md)

Скилл для [opencode](https://github.com/opencode-ai/opencode): координация 2+ AI-моделей через [Orca](https://onorca.dev) для параллельного ревью, кросс-валидации и массовой работы. Координатор маршрутизирует, диспатчит, ждёт, синтезирует и гейтит — никогда не пишет код.

## Когда звать

- «Обсудите этот вопрос с 2 моделями», «multi-model review», «cross-validate with N models»
- Fidelity-порты (reference→platform): один writer (Qwen/GLM) + dual review (GLM ∥ Codex)
- Ревью безопасности/RLS/auth: параллельный Codex + Qwen (никогда не single-model gate)
- Архитектурные решения, где нужны независимые взгляды
- Массовая работа, не влезающая в одно контекстное окно

## Когда не звать

- Одна модель, тривиальные правки или §1 decision tree сказал «solo»
- Задачи, где независимые перспективы моделей не дают выигрыша
- Реализация координатором (координатор никогда не пишет код)

## Модели

| Модель | Лучшая роль | Стоимость |
|--------|-------------|-----------|
| GLM 5.2 | Многофайловая реализация, архитектурный синтез | Средняя |
| Qwen 3.8 Max | Fidelity-порт writer, сложные рассуждения, multimodal | Высокая |
| DeepSeek V4 Pro | Глубокий анализ, кросс-аудит, race conditions | Средняя |
| DeepSeek V4 Flash | Массовая механика, инвентаризация, хотфиксы | Низкая |
| Grok 4.5 | Оркестрация, быстрый поиск, speed loops | Низкая-средняя |
| Codex 5.5 | Ревью безопасности/RLS, behavioural regression gate | Высокая |
| GPT-5.6 | Lean outcome-focused кодинг | Высокая |

Маршрутизация зависит от типа задачи, а не от предпочтений модели. Полная таблица с evidence-якорями — в `references/routing.md`.

## [platform] highlights

- **Таблица маршрутизации:** 7 типов задач → модели с evidence из волн I3–[TICKET]
- **Dual review обязателен:** fidelity-порты требуют GLM 5.2 (static parity) ∥ Codex 5.5 (hosted semantics) — комплементарны, не избыточны
- **Deploy / smoke gate:** доказать, что поставленная поверхность существует перед handoff (принцип + curl-примеры в `references/routing.md`)
- **Жизненный цикл:** 7 явных гейтов: implement → review → commit → PR → merge → deploy → done. Не схлопывать в «writer Done»
- **Writer replaceable:** фраза владельца «сейчас writer=X» мгновенно назначает писателя — без переписывания скилла

## Установка

```bash
# Клонировать репозиторий со скиллами
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

# Симлинк в конфиг opencode
ln -sfn ~/Projects/opencode-skills/skills/multi-model-orchestration ~/.config/opencode/skills/multi-model-orchestration
```

Или скопировать папку:

```bash
cp -r ~/Projects/opencode-skills/skills/multi-model-orchestration ~/.config/opencode/skills/multi-model-orchestration
```

Требует установленных скиллов `orca-cli` и `orchestration`. Воркеры используют терминалы Orca или ручной fallback.

## Структура

```
multi-model-orchestration/
├── SKILL.md              # Инструкции для агента (загружает opencode)
├── README.md             # Английская версия
├── README.ru.md          # Этот файл — русское описание
└── references/
    ├── routing.md         # Таблица маршрутизации, брифы, deploy/smoke gate
    ├── worker-contract.md # Output contract, live worker_done CLI, written≠persisted
    ├── failure-handling.md # Таймауты, эскалация, circuit-breaker
    └── model-card.md      # Роли, «не путать с», evidence, owner pin, launch pins
```

## Лицензия

MIT — часть [opencode-skills](https://github.com/dimkurilo/opencode-skills).
