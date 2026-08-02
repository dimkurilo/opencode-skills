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

| Модель | Family | Лучшая роль | Стоимость |
|--------|--------|-------------|-----------|
| Qwen Code | Alibaba | Основной кодер (implement), нативная оркестрация | Высокая |
| GLM 5.2 | Zhipu | Многофайловая реализация, архитектурный синтез, static parity review | Средняя |
| Qwen 3.8 Max | Alibaba | Fidelity-порт writer, сложные рассуждения, multimodal | Высокая |
| DeepSeek V4 Pro | DeepSeek | Глубокий анализ, кросс-аудит, race conditions | Средняя |
| DeepSeek V4 Flash | DeepSeek | Массовая механика, инвентаризация, хотфиксы | Низкая |
| Grok 4.5 | xAI | Оркестрация, быстрый поиск, speed loops | Безлимит |
| Codex 5.5 | OpenAI | Ревью безопасности/RLS, behavioural regression gate (уникальная роль) | Высокая |

Маршрутизация зависит от типа задачи, а не от предпочтений модели. **Cross-family правило:** writer.family ≠ reviewer.family. Полная таблица с evidence-якорями и cross-family парами — в `references/routing.md`.

## [platform] highlights

- **Qwen Code first-class:** отдельный CLI (`qwen --approval-mode yolo`), `/effort` вместо `/variants`, нативный worker_done. Не OpenCode-агент
- **Family field + cross-family маршрутизация:** у каждой модели family (Alibaba, Zhipu, DeepSeek, OpenAI, xAI). Writer ≠ reviewer на уровне family, не только модели
- **PRE-DISPATCH GATE (§3):** обязательный 6-пунктный чеклист перед каждым dispatch (model-card, --agent, variant/effort + sleep 3, dispatch --inject, cross-family, полнота брифа)
- **POST-WORKER_DONE последовательность:** verify files → Linear comment → dispatch reviewer → wait → synthesis → ТОЛЬКО ПОТОМ In Review. Без сокращений
- **Hard Prohibitions:** 11 запретов с правильными альтернативами в `references/prohibitions.md`
- **Codex 5.5 behavioral gate:** уникальная роль — нашёл abort/cost MAJOR, который GLM пропустил. НЕ «ещё один ревьювер»
- **Таблица маршрутизации:** 7+ типов задач → модели с evidence из production waves
- **Dual review обязателен:** fidelity-порты требуют GLM 5.2 (static parity) ∥ Codex 5.5 (hosted semantics) — комплементарны, не избыточны
- **Deploy / smoke gate:** доказать, что поставленная поверхность существует перед handoff (принцип + curl-примеры в `references/routing.md`)
- **Жизненный цикл:** 8 состояний (см. wave-spec §Lifecycle Gates). Не схлопывать в «writer Done»
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
    ├── routing.md         # Таблица маршрутизации, брифы, cross-family pairs, deploy/smoke gate
    ├── worker-contract.md # Output contract, live worker_done CLI, written≠persisted, парсинг Orca JSON
    ├── failure-handling.md # Таймауты, эскалация, circuit-breaker, model-specific failure modes
    ├── model-card.md      # Роли, family field, «не путать с», evidence, owner pin, launch pins, Qwen Code
    └── prohibitions.md    # 11 жёстких запретов с правильными альтернативами
```

## Лицензия

MIT — часть [opencode-skills](https://github.com/dimkurilo/opencode-skills).
