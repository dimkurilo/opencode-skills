# vv-opencode → wave-spec portability

> Точка сверки: **vv-opencode v1.2.1 (2026-07-27)** — re-diff выполнен 2026-08-03.
> vv 1.x после 1.0 растёт почти entirely инфраструктурой (TUI /context, web-tools, релизы);
> скилл-методология стабильна с 0.35.31. Методологический разрыв меньше, чем номер версии.

| vv-opencode | wave-spec |
|-------------|-----------|
| `vv-spec` mode | this skill steps 0–3 → `SPEC.xml` |
| `vv-plan` mode | this skill step 4 → `PLAN.xml` |
| `.vvoc/specs/<date>-<slug>/spec.xml` | `waves/<date>-<slug>/SPEC.xml` or `roadmap/PROGRAM_SPEC.xml` |
| `.vvoc/specs/.../plan.xml` | `PLAN.xml` beside SPEC |
| approve in framework | user message `approve` + status fields |
| execution in same harness | worker briefs + any CLI / Orca |
| design-context.xml | optional; use MEMORY.md + ASSUMPTIONS.md + research files instead |
| XML runtime validation in vv | soft validation by skill quality bar |

## Keep from vv

- Spec before plan
- Measurable success criteria
- Explicit out of scope
- Wave/task dependency order
- Nested structured fields (XML)
- Interview guardrails (vv 0.35.13) — recommendation-first, мини-roadmap, recap; lean-форма в §2 Interview
- Per-task verification (vv-plan `<verification><command>`) — у нас: `done_when` = исполняемая команда где возможно
- Bounded review rounds (vv WorkflowPlugin, MAX_REVIEW_ROUNDS=2) — у нас строкой: 2 fix-rounds + эскалация владельцу (§Fidelity Dual Review)

## Drop from vv (сознательно, по итогам re-diff v1.2.1)

- design-context.xml (vv 0.35.20) — заменён MEMORY.md + ASSUMPTIONS.md + research-файлы
- vv-reflect как отдельный механизм — есть MEMORY.md + post-mortem→skill-update + reflect-вопрос в closeout
- WorkflowPlugin state machine (work_item_*, persistence, launch enforcement) — рантайм; у нас STATUS.md + lifecycle gates + human-supervision
- Рантайм-плагины (guardian, hashline-edit, web-tools, /context TUI, secrets-redaction engine), vvoc CLI, strict schema-v3 — несовместимо с portable files-only; secret redaction у нас = grep-гейт в closeout
- GRACE 4 governance (.grace/, C-* bundles, V-M-* entries) — бюрократия для нашего масштаба; принцип FreshEvidence уже есть (deploy probe, evidence-first)
- Orchestration profiles (single-session/balanced/orchestrated) как config — покрыто owner-pin «сейчас orchestrator=X»
- classic/inline execution mode selection — наш путь: dispatch/manual через Orca
- English-docs default — владелец работает по-русски
- Запрет fast mode («Do NOT offer a fast mode») — противоречит нашему `mode=quick`

Примечание: ранние версии vv (до ~0.35) требовали multi-thousand-line architecture dump на каждую волну; в 1.2.1 шаблоны компактные contract-level (T-NNN + CDATA-сниппеты + `<verification>`). Это устаревшее основание для drop больше не актуально.

## Why XML here

Structured nested contracts reduce ambiguity for agents (required sections, ids, depends_on).
You get the **document shape** of vv without requiring the **vv-opencode runtime**.
INTENT stays Markdown for humans.
