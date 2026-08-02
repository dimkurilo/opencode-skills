# Multi-Model Orchestration

🇬🇧 [English version](README.md)

Скилл для [opencode](https://github.com/opencode-ai/opencode): координация 2+ AI-моделей через [Orca](https://onorca.dev) для параллельного ревью, кросс-валидации и массовой работы. Координатор маршрутизирует, диспатчит, ждёт, синтезирует и гейтит — не совмещает оркестрацию с написанием кода в одной задаче.

## Когда звать

- «Обсудите этот вопрос с 2 моделями», «multi-model review», «cross-validate with N models»
- Fidelity-порты (reference→platform): один writer (Flash/GLM) + dual review (Qwen/GLM ∥ GPT-5.5)
- Ревью безопасности/RLS/auth: параллельный GPT-5.5 + Qwen (никогда не single-model gate)
- Архитектурные решения, где нужны независимые взгляды
- Массовая работа, не влезающая в одно контекстное окно

## Когда не звать

- Одна модель, тривиальные правки или §1 decision tree сказал «solo»
- Задачи, где независимые перспективы моделей не дают выигрыша
- Реализация координатором (координатор не совмещает оркестрацию с написанием кода в одной задаче)

## Модели

| Модель | Family | Лучшая роль | Стоимость |
|--------|--------|-------------|-----------|
| DeepSeek V4 Flash | DeepSeek | **Оркестратор (по умолчанию) + основной writer/кодер/тестер** — dispatch, routing, синтез; single-file, bulk code, тесты | Низкая |
| Qwen 3.8 Max | Alibaba | **Reviewer / архитектор / бизнес-аналитик (default reviewer)** — architecture spec, cross-audit, business analysis, RLS review. НЕ основной кодер (медленная) | Высокая |
| GLM 5.2 | Zhipu | **Multi-file writer (default для 3+ файлов)** + second-line reviewer (architecture-heavy волны) | Средняя |
| GPT-5.5 | OpenAI | Ревью безопасности/RLS, behavioral regression gate (уникальная роль) | Высокая |

Маршрутизация зависит от типа задачи, а не от предпочтений модели. **Cross-family правило:** writer.family ≠ reviewer.family. Полная таблица с evidence-якорями и cross-family парами — в `references/routing.md`.

## Orchestration Platform highlights

- **DeepSeek V4 Flash = orchestrator (default) + primary writer/coder:** full orchestrator role (dispatch → wait → gate → synthesize) + основной writer/coder (single-file, bulk code, тесты). Не «mechanics only». Fast ($0.14/$0.28 per 1M), strong on 0731 benchmarks
- **Qwen 3.8 Max = reviewer / архитектор / бизнес-аналитик (default reviewer):** NE основной кодер (медленная). Owner empirical: level ~ Kimi K3, **сильнее GLM 5.2 в architecture и depth of thought**; 2.4T weights; owner subscription confirmed. Public benchmarks: none. Pinned via OpenCode agent `A/agent1st_qwen-3.8` (versionless)
- **GLM 5.2 = multi-file writer + second-line reviewer:** default writer для 3+ файлов (1M state continuity, ~15 min implement, ~10 min fix-round); second-line reviewer когда Qwen недоступен. `A/agent1st_glm` (v14+). AAII 51, GPQA-D 91.2, LiveBench 73.2 (indep)
- **GPT-5.5 = behavioral regression gate:** уникальная роль — нашёл abort/cost MAJOR, который GLM пропустил. НЕ «ещё один ревьювер». Security/RLS gate. Запуск через `codex` CLI
- **Family field + cross-family маршрутизация:** у каждой модели family (Alibaba, Zhipu, DeepSeek, OpenAI). Writer ≠ reviewer на уровне family, не только модели
- **PRE-DISPATCH GATE (§3):** обязательный 6-пунктный чеклист перед каждым dispatch (model-card, --agent, variant/effort + sleep 3, dispatch --inject, cross-family, полнота брифа)
- **POST-WORKER_DONE последовательность:** verify files → Linear comment → dispatch reviewer → wait → synthesis → ТОЛЬКО ПОТОМ In Review. Без сокращений
- **Hard Prohibitions:** 12 запретов с правильными альтернативами в `references/prohibitions.md`
- **Таблица маршрутизации:** 7+ типов задач → модели с evidence из production waves
- **Dual review обязателен:** fidelity-порты требуют Qwen 3.8 Max (architect/reviewer) ∥ GPT-5.5 (hosted semantics) — комплементарны, не избыточны
- **Deploy / smoke gate:** доказать, что поставленная поверхность существует перед handoff (принцип + curl-примеры в `references/routing.md`)
- **Жизненный цикл:** 8 состояний (см. wave-spec §Lifecycle Gates). Не схлопывать в «writer Done»
- **Writer replaceable:** фраза владельца «сейчас writer=X» (Flash или GLM) мгновенно назначает писателя — без переписывания скилла. Qwen 3.8 Max = reviewer по умолчанию (NE writer)

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
