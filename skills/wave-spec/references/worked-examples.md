# Worked examples — wave-spec (3 энд-ту-энд примера)

> Реальные формы волн владельца. Учись по ним, не по абстрактным меню. Каждый пример = какой mode + какие артефакты + какой lifecycle.

---

## Пример 1. `mode=quick` — мелкая правка / пет-проект (≤1 файл, ≤30 мин, no deploy)

**Сценарий:** поправить опечатку в лендинге или добавить одну секцию в пет-проекте.

**Артефакт (1 файл, всё в одном):** `waves/YYYY-MM-DD-fix-typo/quick-spec.md`:

```markdown
# INTENT (5 строк)
Хочу: исправить опечатку «[price]» → «[price].» в hero-блоке.
Успех: на странице «[price].», grep не находит «[currency]».
Out of scope: другие блоки, цены.

# SPEC (10 строк)
goal: заменить «[price]» на «[price].» в src/sections/Hero.tsx
success:
  - S1: grep -rn "[currency]" src/ → 0 совпадений
  - S2: npm run build зелёный
constraints: не трогать другие цены; токен --background не менять
risks: нет (локальная правка, no deploy)

# approve → apply → archive
```

**Lifecycle:** Implement done (build зелёный) → Done. Без LAUNCH/NEXT_SESSION/Linear, без dual review (но written≠persisted + secret-redaction — всегда).

---

## Пример 2. `wave` на 1 итерацию — правка с деплоем на прод (production-incident pattern)

**Сценарий:** добавить новый маршрут/страницу и выкатить на прод. 1 итерация, но есть deploy → полный lifecycle.

**Артефакты:** `waves/YYYY-MM-DD-new-route/`:
- `INTENT.md` — что/успех/out of scope.
- `SPEC.xml` — goal + success criteria (S1: маршрут отдаёт 200/307; S2: build зелёный) + constraints (C-deploy: no prod without human gate) + sources + risks.
- `PLAN.xml` — 3 задачи (T01 компонент, T02 роут, T03 deploy-probe), owner/model_hint, gates (G1: human перед deploy).
- `STATUS.md` — таблица задач, state = lifecycle enum.
- `NEXT_SESSION.md` (pointer) + `NEXT_SESSION_I1.md` (компакт: шаги 0/3/8 + gates, т.к. ≤2 итераций).

**Lifecycle (полный):** Implement done (written≠persisted: `git status` доказал файлы) → In Review (writer≠reviewer, cross-family) → Commit (без dev-файлов) → PR → Merge → **Deploy gate** (curl: 307/302 ≠ 404) → On prod (owner smoke ИЛИ RESIDUAL-RISK-OWNER-SMOKE) → Done.

**Урок (production-incident pattern):** нельзя метить Done/«next product» пока deploy probe не прошёл — агент пометил In Review, а файл маршрута не был на проде (404).

---

## Пример 3. `wave` на 3 задачи — пет-проект без fidelity (доработка лендинга)

**Сценарий:** доработать лендинг пет-проекта ([project]): добавить блок отзывов, поправить квиз, обновить FAQ. 3 задачи, без fidelity-порта → dual review рекомендован, но не обязателен (writer≠reviewer минимум).

**Артефакты:** `waves/YYYY-MM-DD-landing-polish/`:
- `INTENT.md`, `SPEC.xml` (success criteria по каждому блоку), `PLAN.xml`:
  - T01: блок отзывов (UI-компонент фронтенда), owner=writer (Qwen 3.8 Max), artifact=src/sections/reviews-block.tsx
  - T02: фикс квиз-формы, depends_on=T01 (общий UI-контекст), artifact=src/islands/quiz-form.tsx
  - T03: FAQ-секция + JSON-LD, artifact=src/sections/faq.tsx
  - gates: G1 human перед деплоем на прод
- `STATUS.md`, `NEXT_SESSION.md` + `NEXT_SESSION_I1.md` (≤2 итераций → компакт).

**Особенности:** T01/T03 параллельны (разные artifact-пути), T02 зависит от T01. Квиз — ОДИН React island (общий UI-контекст Dialog/Combobox не разбивается). Все абсолютные ссылки → `import.meta.env.BASE_URL` (базовый путь фреймворка).

**Lifecycle:** Implement done → In Review (writer≠reviewer; для UI — визуальная QA на 3 вьюпортах 375/430/1440) → Commit → PR → Merge → Deploy gate (curl страниц) → On prod → Done → **archive** (`mv waves/YYYY-MM-DD-landing-polish waves/archive/`).

---

## Как выбирать mode (decision)

```
Правка ≤1 файл, ≤30 мин, no deploy?  → mode=quick (пример 1)
Спринт 2–7 дней, одна тема?          → mode=wave (пример 2/3)
  └ есть deploy/прод?                → полный lifecycle + deploy probe (пример 2)
  └ нет deploy?                      → lifecycle без deploy gate (пример 3)
Атомарная задача внутри волны?       → mode=task
Много-волновой портфель?             → mode=program (редко; references/program-maps.md)
```

**Лестница обучения:** начни с примера 1 (quick, 1 сессия) → пример 3 (wave без deploy) → пример 2 (wave с deploy + review) → подключи `multi-model-orchestration` для кросс-ревью.
