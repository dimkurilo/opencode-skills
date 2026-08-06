<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/hero-light.svg">
  <img alt="wave-spec" src="assets/hero-light.svg" width="100%">
</picture>

# wave-spec

🇬🇧 [English version](README.md) · **Русский** · [← все скиллы](../../README.md)

**Plan-gate скилл для спринтов, где нельзя пропускать планирование.**

wave-spec проводит короткое интервью перед тем, как писать код или контент, превращает ответы в структурированные `SPEC` + `PLAN` и ведёт агента через dispatch, review, deploy и handoff с lifecycle-гейтами между каждой стадией. Портативный между OpenCode, ZCode, Qwen Code — без рантайма.

---

## Когда использовать

- Запускаете спринт, волну или любую многосессионную работу, где нельзя пропускать планирование.
- Сказали «составь спеку/план», «spec first», «interview then plan».
- Работа: разработка, контент, порт скиллов, перевод, оркестрация, перестройка сайта.

**Не используйте полный пайплайн** для тривиальных правок (≤1 файл, ≤30 мин, no deploy) — внутри скилла есть `mode=quick`.

## Как работает

```
INTENT → интервью (3–7 ?) → [pre-mortem] → SPEC → PLAN → утверждение → dispatch → lifecycle gates → Done
```

**Pre-mortem triage** (шаг 2.5, между интервью и SPEC): один review-only dispatch на сессию — ловит failure surfaces в draft дизайне до формирования SPEC. Trigger (OR — любого одного условия достаточно): migration, prod, data, security, fidelity/reference port, packages ≥ 6, planned duration ≥ 7 days; `quick` всегда skip. Verdict: PASS → SPEC/PLAN (НЕ implementation), REVISE → один проход к SPEC/PLAN (без второго pre-mortem), BLOCK → стоп до owner. Planning review dispatch — единственное исключение, разрешённое до approve/LAUNCH.

**Review modes** (пропорциональная глубина ревью — см. SKILL.md §Review modes): четыре режима выбираются по precedence. `Mechanical` = 0 ревьюеров (gate ревью пропускается, lifecycle всё равно соблюдается); `Simple` = 1 cross-family ревьюер на model-specific low effort; `Ordinary` = 1 cross-family ревьюер (default Qwen 3.8 Max); `Strong` = 2 complementary линии — gpt-5.6-luna (OpenAI GPT-5.6; launch: `codex --model gpt-5.6-luna -c model_reasoning_effort="max"`; «Luna Max» — shorthand, НЕ имя модели; `max` = reasoning effort; behavioral / security / fidelity lens, обязательно для этих категорий) + Qwen 3.8 Max (static / architecture lens; меняется на GLM 5.2 когда writer = Alibaba). Выбор = stricter-of (floor, risk result): user/repo review requirement задаёт floor (минимальный режим); risk triggers (security / RLS / auth / secrets / permissions, prod deploy / data / schema migration, fidelity port / behavioral parity, abort / cost / state-transition semantics, unknown blast radius) принудительно дают `Strong` — даже при низком floor; изменение без runtime / control-flow / contract impact и с зелёными checks → `Mechanical`; low-risk → `Simple`; иначе `Ordinary`. Cross-family (`writer.family ≠ reviewer.family`) обязательно для каждого режима с ревьюером — `Mechanical` единственный без ревьюера, исключение Simple-without-cross-family отменено. Оркестратор записывает выбранный `review_mode` в STATUS `## Review gate` блок до первого dispatch (`strong_session_used` — atomic compare-and-set до первого Strong dispatch — double-Strong guard; при `true` BLOCKирует и выдаёт owner outcome, без тихого пропуска). Enum verdict синтеза: `APPROVED | NEEDS_CHANGES | BLOCKED`.

**Режимы:**
- `mode=quick` — однофайловая правка, no deploy, одна сессия.
- `mode=wave` — спринт (2–7 дней), одна тема, полный lifecycle.
- `mode=program` — мульти-волновой портфель (редко).
- `mode=task` — атомарная задача внутри волны.

**Lifecycle gates (8 состояний, линейно):**

```
Implement → In Review → Commit → PR → Merge → Deploy probe → On prod → Done
```

Никаких «Done» или «next product», пока deploy probe не вернёт не-404. Если live smoke нет — handoff несёт явный маркер `RESIDUAL-RISK-OWNER-SMOKE` вместо иллюзии определённости.

## Что производит

```
waves/<date>-<slug>/
├── INTENT.md              # свободная цель + критерии успеха + scope
├── SPEC.xml / SPEC.md     # структурированная спека (XML или markdown-with-required-sections)
├── PLAN.xml               # задачи с deps, owner, model hint, artifact, gates
├── STATUS.md              # таблица задач + lifecycle state
├── worker briefs          # на задачу: ROLE/SCOPE/MODE/DONE/FORBIDDEN
├── LAUNCH.md              # сгенерированные команды запуска по моделям
├── NEXT_SESSION_I{N}.md   # один файл на итерацию (не перезаписывать)
├── NEXT_SESSION.md        # указатель на текущую итерацию
└── iteration-handoff.md   # handoff на итерацию
```

На closeout запускается `scripts/verify-spec.sh` — портативный bash-валидатор (exit 0 = PASS; опция `--require-launch` дополнительно требует `LAUNCH.md` с Prohibited + cross-family). Worker-handoff'ы и iteration closeout запускают `scripts/verify-handoff-payload.sh --handoff <file>` — payload-гейт канонического блока `## Handoff` (≤1500 символов, обязательные секции, семантические failure-state значения; exit 0–5).

**Hard gate перед диспатчем:** для mode=wave/program `LAUNCH.md` обязан существовать (cross-family check + секция «Prohibited») до любого диспатча воркеров — см. SKILL.md шаг 6.0.

## Стек моделей по умолчанию

| Роль | Модель | Зачем |
|------|--------|-------|
| Оркестратор + основной writer | **DeepSeek V4 Flash** | быстрый, дешёвый, сильный на 0731 бенчмарках |
| Multi-file writer (3+ файлов) | **GLM 5.2** | 1M state continuity, длинные горизонты |
| Reviewer / архитектор (default) | **Qwen 3.8 Max** | depth, архитектура, бизнес-анализ |
| Strong behavioral lens | **gpt-5.6-luna** (GPT-5.6; `codex --model gpt-5.6-luna -c model_reasoning_effort="max"`; «Luna Max» = shorthand) | behavioral / security / fidelity — default Strong-пара с Qwen 3.8 Max; $0.20/$1.20 (−80%); AAII max 51 |
| Security gate (опц.) | **GPT-5.5** | opt-in для особо чувствительных кейсов; историческая уникальная роль |

Owner может пинить любую роль: «сейчас writer=GLM», «сейчас orchestrator=Flash». **Cross-family rule:** writer.family ≠ reviewer.family — ловит слепые пятна.

## Установка

```bash
ln -sfn ~/Projects/opencode-skills/skills/wave-spec \
  ~/.config/opencode/skills/wave-spec
```

## Пример сессии

> **Вы:** wave-spec — порт скилла из Claude Code в opencode + ZCode, 3 задачи.
>
> **Агент** *(загружает wave-spec)*: интервью спрашивает про целевые хосты, fidelity-требования, тестовую поверхность → produce `SPEC.xml` (3 задачи, gates) + `PLAN.xml` (writer=Flash, reviewer=Qwen, deploy=skill-load-check) → ждёт утверждения → генерирует `LAUNCH.md` + worker briefs → dispatch → review → closeout с `verify-spec.sh` PASS → Done.

## Что внутри

- **References:** `worked-examples.md` (3 сквозных примера), `program-maps.md` (4 доменных меню), `glossary.md` (15 терминов), `vv-portability.md`.
- **Шаблоны (15):** `INTENT.md.tmpl`, `SPEC.xml.tmpl`, `PLAN.xml.tmpl`, `STATUS.md.tmpl`, `quick-spec.md.tmpl`, `worker-brief.md.tmpl`, `LAUNCH.md.tmpl`, `NEXT_SESSION.md.tmpl`, `NEXT_SESSION_ITER.md.tmpl`, `iteration-handoff.md.tmpl`, `review-synthesis.md.tmpl`, `fix-round-brief.md.tmpl`, `premortem-brief.md.tmpl`, `ASSUMPTIONS.md.tmpl`, `linear-workflow.md.tmpl`.
- **Скрипты:** `verify-spec.sh`, `verify-handoff-payload.sh` (payload-гейт канонического блока `## Handoff` — длина ≤1500, обязательные headings/labels, семантические значения; exit 0–5).

## Роутер

```
новый проект → project-bootstrap · план спринта → wave-spec · 2+ модели → multi-model-orchestration
```

## Лицензия

MIT · часть [opencode-skills](../../README.md)
