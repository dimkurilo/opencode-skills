# wave-spec

Портабельный plan-gate skill (vv-метод, мульти-CLI). INTENT → интервью → SPEC.xml + PLAN.xml → утверждение → брифинги воркеров → LAUNCH.md → STATUS/handoff → NEXT_SESSION. Универсальный: разработка, контент, порт скиллов, перевод, оркестрация, перестройка сайтов.

## Когда использовать

Используй при запуске спринта/волны или когда мультисессионная разработка/контент/порт скиллов/перевод не должна пропускать планирование. Работает в OpenCode, ZCode, Qwen Code — пишет файлы в проекте, не требует vv-opencode.

**НЕ используй** для тривиальных однострочных правок, уже одобренных пользователем.

## Ключевые возможности

- **Стек по умолчанию:** DeepSeek V4 Flash (оркестратор по умолчанию + основной writer/coder/тестер; полная роль — dispatch → wait → gate → synthesize; single-file, bulk code, тесты) · Qwen 3.8 Max (reviewer / архитектор / бизнес-аналитик; NE основной кодер — медленная; owner empirical: level ~ Kimi K3, сильнее GLM в architecture) · GLM 5.2 (multi-file writer для 3+ файлов + second-line reviewer; AAII 51, GPQA-D 91.2) · GPT-5.5 (security/fidelity gate, `codex` CLI)
- **TL;DR + minimum path + лестница обучения:** `mode=quick` (≤1 файл, ≤30 мин, no deploy) → `wave` (спринт 2–7 дней) → `multi-model-orchestration` (2+ модели). Учись деланием, не чтением
- **Роутер скиллов:** новый проект → `project-bootstrap` · план спринта → `wave-spec` · 2+ модели → `multi-model-orchestration`
- **Автогенерация LAUNCH.md (шаг 6b):** команды запуска воркеров из model-card.md + PLAN.xml roles, cross-family check (writer.family ≠ reviewer.family), шаблоны review brief из `multi-model-orchestration/references/routing.md`, секция запретов, версионирование при смене ролей
- **Паттерн NEXT_SESSION (шаг 6c):** уникальные файлы `NEXT_SESSION_I{N}.md` на итерацию (никогда не перезаписывать), copy-paste блок с полным путём (формат по модели оркестратора), корневой указатель `NEXT_SESSION.md`, 9 шагов с verification gates (без дублирования SKILL.md)
- **Итерационный handoff (шаг 7):** уникальные файлы `iterations/I{N}-<slug>.handoff.md`, корневой SESSION_HANDOFF.md только как указатель
- **Генерация linear-workflow (шаг 6d):** параметрический `.agents/rules/linear-workflow.md` из параметров волны, APPEND при новой волне в том же проекте
- **PLAN.xml `<roles>`:** оркестратор + экзекуторы с tool/agent/flags/effort/family + `<family_rule>`
- **Lifecycle gates (8 состояний):** Implement → In Review → Commit → PR → Merge → Deploy → On Prod → Done. RESIDUAL-RISK-OWNER-SMOKE если live smoke отсутствует
- **Fidelity dual review:** static-parity reviewer ∥ behavioral-semantics reviewer из разных семейств; writer ≠ reviewer; Flash не назначается fidelity-ревьюером (judgment-роль)
- **Post-mortem → skill update:** closeout checklist включает создание INTENT.md для улучшений скиллов

## SoT + Symlink Layout

**Source of Truth (SoT):** `<repo>/skills/wave-spec/` — git-tracked.

**Install into OpenCode** (active CLI):

- `~/.config/opencode/skills/wave-spec` → `<repo>/skills/wave-spec`

## Жизненный цикл (одной строкой)

Implement done → In Review (dual review) → Commit → PR → Merge → Deploy probe (curl ≠ 404) → On prod (owner smoke OR RESIDUAL-RISK-OWNER-SMOKE) → Done. Никакой передачи «NEXT product», пока Deploy gate не пройден.

## Политика форматов (SPEC/PLAN)

**Markdown с required-sections — по умолчанию** (Goal, Done_when, Verifier, Scope, Risks). XML — опционален (format triage 2026-08: свежий агент извлекает required-поля из MD и XML одинаково, 5/5; XML имеет смысл только если под него есть реальный парсер/валидатор). Канон: SKILL.md `## XML vs Markdown (policy)`. Портативный валидатор (bash + grep, без рантайма): `bash skills/wave-spec/scripts/verify-spec.sh waves/<date>-<slug>/` — запускается в wave closeout (exit 0 = PASS).

## Ссылки

- `references/program-maps.md` — domain-specific program maps (4 меню: skill-port, перевод, fidelity port, SEO)
- `references/vv-portability.md` — маппинг на тэги vv-opencode
- `assets/templates/` — шаблоны INTENT, SPEC, PLAN, STATUS, брифа воркера, review synthesis, fix-round, ASSUMPTIONS, **LAUNCH.md**, **iteration-handoff.md**, **NEXT_SESSION.md** (указатель), **NEXT_SESSION_ITER.md** (итерация), **linear-workflow.md**
