<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/hero-light.svg">
  <img alt="multi-model-orchestration" src="assets/hero-light.svg" width="100%">
</picture>

# multi-model-orchestration

🇬🇧 [English version](README.md) · **Русский** · [← все скиллы](../../README.md)

**Координация 2+ AI-моделей для ревью, кросс-валидации или массовой работы.**

Dispatch/review движок. Координатор маршрутизирует задачу N воркерам-моделям через [Orca](https://onorca.dev), ждёт результаты и синтезирует — с жёстким правилом: writer и reviewer никогда не из одного семейства моделей.

---

## Когда использовать

- Нужны **независимые перспективы** — «обсудите с 2 моделями», «cross-validate», «parallel review».
- **Fidelity-порт** (генератор, векторизатор, reference→платформа) — двойной ревью обязателен.
- **Security / RLS / auth** ревью — никогда одной моделью.
- **Массовая работа**, выходящая за одно контекстное окно.

**Не используйте** для задач одной модели, тривиальных правок или когда прямого промпта достаточно. Сначала solo, multi — только когда второе семейство реально добавляет сигнал.

## Таблица роутинга

| Работа | Куда | Зачем |
|--------|------|-------|
| Оркестратор + основной writer | **DeepSeek V4 Flash** | role lock: dispatch → wait → gate → synthesize + основной кодер |
| Multi-file реализация (3+) | **GLM 5.2** | 1M state continuity, длинные горизонты |
| Review / архитектура (default reviewer) | **Qwen 3.8 Max** | depth, архитектура, бизнес-анализ |
| Security / behavioral gate | **GPT-5.5** | уникальная роль — ловил регрессии, которые другие пропускали |

**Cross-family rule:** `writer.family ≠ reviewer.family`. Qwen-writer → reviewer должен быть DeepSeek/Zhipu/OpenAI, не другая модель Alibaba. Разные семейства ловят разные слепые пятна.

## Как идёт волна

```
1. КЛАССИФИКАЦИЯ  solo или multi? (§1 decision tree)
2. ВЫБОР моделей   сначала назвать их человеку
3. СОЗДАНИЕ        один терминал на воркера, тот же worktree
4. БРИФЫ           модель-специфичные (references/routing.md)
5. PRE-DISPATCH    проверка model-card → --agent флаг → variant/effort → sleep 3
6. DISPATCH        task-create → dispatch --inject (НЕ terminal send)
7. WAIT            check --wait --types worker_done,escalation,decision_gate
8. SYNTHESIZE      consensus / contradictions / gaps — побеждает строже
```

Координатор **не пишет код** в той же задаче — это role lock. Review-only `worker_done` сообщает находки; он не даёт координатору права редактировать. Реализация = новая задача.

## Контракт воркера

Каждый бриф воркера несёт `ROLE / SCOPE / MODE / DONE / FORBIDDEN` и заканчивается:

```
SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS
```

`worker_done` — это CLI-сигнал с обязательным `--to <coordinator-handle>` — без него сообщение уходит в void (продакшен-инцидент). `heartbeat` = жив, **не** готов. Один таймаут = liveness check, не провал.

## Установка

```bash
ln -sfn ~/Projects/opencode-skills/skills/multi-model-orchestration \
  ~/.config/opencode/skills/multi-model-orchestration
```

Требует загруженных скиллов `orchestration` и `orca-cli` рядом + запущенный Orca-рантайм (`orca status --json`).

## Пример волны

> **Вы:** обсудите эту архитектуру с 2 моделями — нужны независимые взгляды.
>
> **Координатор** *(загружает скилл)*: классифицирует multi → маршрутизит архитектурный ревью в Qwen 3.8 (default reviewer) + GPT-5.5 (security/behavioral lens) → строит брифы → dispatch через Orca `--inject` → wait → Qwen находит race condition, GPT-5.5 находит abort-edge-case → синтез: 2 MAJOR находки, обе фиксить перед merge → маршрутизит fix-round в Flash (writer, другое семейство).

## Что внутри

- **References:**
  - `routing.md` — полная таблица роутинга, шаблоны брифов по моделям, cross-family пары.
  - `model-card.md` — роли, поле family, launch-пины, заметки «не путать с».
  - `worker-contract.md` — контракт вывода, inject-preamble, правило доставки `worker_done`.
  - `failure-handling.md` — политика таймаутов, failure ledger (fingerprint / count / правило 5-го фейла), non-counting категории, writer-swap rule.
  - `prohibitions.md` — 11 жёстких запретов с правильными альтернативами.
- **Lifecycle gates, fidelity dual review, deploy probe:** канон в `wave-spec`.

## Роутер

```
новый проект → project-bootstrap · план спринта → wave-spec · 2+ модели → multi-model-orchestration
```

## Лицензия

MIT · часть [opencode-skills](../../README.md)
