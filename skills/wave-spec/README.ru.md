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
INTENT → интервью (3–7 ?) → SPEC → PLAN → утверждение → dispatch → lifecycle gates → Done
```

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

На closeout запускается `scripts/verify-spec.sh` — портативный bash-валидатор (exit 0 = PASS).

## Стек моделей по умолчанию

| Роль | Модель | Зачем |
|------|--------|-------|
| Оркестратор + основной writer | **DeepSeek V4 Flash** | быстрый, дешёвый, сильный на 0731 бенчмарках |
| Multi-file writer (3+ файлов) | **GLM 5.2** | 1M state continuity, длинные горизонты |
| Reviewer / архитектор (default) | **Qwen 3.8 Max** | depth, архитектура, бизнес-анализ |
| Security / fidelity gate | **GPT-5.5** | поведенческая семантика, уникальная роль |

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
- **Шаблоны (14):** `INTENT.md.tmpl`, `SPEC.xml.tmpl`, `PLAN.xml.tmpl`, `STATUS.md.tmpl`, `quick-spec.md.tmpl`, `worker-brief.md.tmpl`, `LAUNCH.md.tmpl`, `NEXT_SESSION.md.tmpl`, `NEXT_SESSION_ITER.md.tmpl`, `iteration-handoff.md.tmpl`, `review-synthesis.md.tmpl`, `fix-round-brief.md.tmpl`, `ASSUMPTIONS.md.tmpl`, `linear-workflow.md.tmpl`.
- **Скрипты:** `verify-spec.sh`.

## Роутер

```
новый проект → project-bootstrap · план спринта → wave-spec · 2+ модели → multi-model-orchestration
```

## Лицензия

MIT · часть [opencode-skills](../../README.md)
