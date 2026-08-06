<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/hero-light.svg">
  <img alt="wave-spec" src="assets/hero-light.svg" width="100%">
</picture>

# wave-spec

🇷🇺 [Русская версия](README.ru.md) · **English** · [← all skills](../../README.md)

**A plan-gate skill for sprints that must not skip planning.**

wave-spec forces a short interview before any code/content gets written, turns the answers into a structured `SPEC` + `PLAN`, and walks the agent through dispatch, review, deploy, and handoff with lifecycle gates between every stage. Portable across OpenCode, ZCode, Qwen Code — no runtime dependency.

---

## When to use

- You're starting a sprint, a wave, or any multi-session work that *must not* skip planning.
- You said *"spec first"*, *"составь спеку/план"*, *"interview then plan"*.
- The work is: development, content production, skill porting, translation, orchestration, or a site rebuild.

**Don't use the full pipeline** for trivial edits (≤1 file, ≤30 min, no deploy) — use `mode=quick` inside the skill instead.

## How it works

```
INTENT → interview (3–7 ?) → [pre-mortem] → SPEC → PLAN → approve → dispatch → lifecycle gates → Done
```

**Pre-mortem triage** (step 2.5, between Interview and SPEC): one review-only dispatch per session that catches failure surfaces in the draft design before SPEC. Trigger (OR — any one): migration, prod, data, security, fidelity/reference port, packages ≥ 6, planned duration ≥ 7 days; `quick` always skips. Verdict: PASS → SPEC/PLAN (not implementation), REVISE → one pass to SPEC/PLAN (no second pre-mortem), BLOCK → stop until owner. The planning review dispatch is the one exception allowed before approve/LAUNCH.

**Review modes** (proportional review depth — see SKILL.md §Review modes): four modes selected by precedence. `Mechanical` = 0 reviewers (review gate skipped, lifecycle still enforced); `Simple` = 1 cross-family reviewer at model-specific low effort; `Ordinary` = 1 cross-family reviewer (default Qwen 3.8 Max); `Strong` = 2 complementary lines — gpt-5.6-luna (OpenAI GPT-5.6; launch: `codex --model gpt-5.6-luna -c model_reasoning_effort="max"`; «Luna Max» — shorthand, НЕ имя модели; `max` = reasoning effort; behavioral / security / fidelity lens, mandatory for those categories) + Qwen 3.8 Max (static / architecture lens; swapped to GLM 5.2 when the writer is Alibaba). Selection = stricter-of (floor, risk result): a user/repo review requirement sets a floor (minimum mode); risk triggers (security / RLS / auth / secrets / permissions, prod deploy / data / schema migration, fidelity port / behavioral parity, abort / cost / state-transition semantics, unknown blast radius) force `Strong` unconditionally — even when the floor is lower; a change with no runtime / control-flow / contract impact and all checks green → `Mechanical`; low-risk → `Simple`; otherwise `Ordinary`. Cross-family (`writer.family ≠ reviewer.family`) is mandatory for every mode that has a reviewer — `Mechanical` is the only mode without one, and the Simple-without-cross-family exception is cancelled. The orchestrator records the selected `review_mode` in the STATUS `## Review gate` block before the first dispatch (`strong_session_used` is an atomic compare-and-set before the first Strong dispatch — a double-Strong guard; on `true` it BLOCKs and surfaces an owner outcome, never a silent skip). Synthesis verdict enum: `APPROVED | NEEDS_CHANGES | BLOCKED`.

**Modes:**
- `mode=quick` — one-file fix, no deploy, single session.
- `mode=wave` — a sprint (2–7 days), one theme, full lifecycle.
- `mode=program` — multi-wave portfolio (rare).
- `mode=task` — atomic task inside a wave.

**Lifecycle gates (8 states, linear):**

```
Implement → In Review → Commit → PR → Merge → Deploy probe → On prod → Done
```

No "Done" or "next product" until the deploy probe returns non-404. If there's no live smoke test, the handoff carries an explicit `RESIDUAL-RISK-OWNER-SMOKE` marker instead of pretending certainty.

## What it produces

```
waves/<date>-<slug>/
├── INTENT.md              # freeform goal + success criteria + scope
├── SPEC.xml / SPEC.md     # structured spec (XML or markdown-with-required-sections)
├── PLAN.xml               # tasks with deps, owners, model hints, artifacts, gates
├── STATUS.md              # task table + lifecycle state
├── worker briefs          # per-task ROLE/SCOPE/MODE/DONE/FORBIDDEN
├── LAUNCH.md              # generated launch commands per model
├── NEXT_SESSION_I{N}.md   # one file per iteration (never overwritten)
├── NEXT_SESSION.md        # pointer to the current iteration
└── iteration-handoff.md   # per-iteration handoff
```

Closeout runs `scripts/verify-spec.sh` — a portable bash validator (exit 0 = PASS; opt-in `--require-launch` also requires `LAUNCH.md` with Prohibited + cross-family). Worker handoffs and iteration closeouts run `scripts/verify-handoff-payload.sh --handoff <file>` — the payload gate enforcing the canonical `## Handoff` block (≤1500 chars, required sections, semantic failure-state values; exit 0–5).

**Hard gate before dispatch:** for `wave`/`program` modes `LAUNCH.md` must exist (cross-family check + Prohibited section) before any worker dispatch — see SKILL.md step 6.0.

## Default model stack

| Role | Model | Why |
|------|-------|-----|
| Orchestrator + primary writer | **DeepSeek V4 Flash** | fast, cheap, strong on 0731 benchmarks |
| Multi-file writer (3+ files) | **GLM 5.2** | 1M state continuity, long-horizon specialty |
| Reviewer / architect (default) | **Qwen 3.8 Max** | depth, architecture, business analysis |
| Strong behavioral lens | **gpt-5.6-luna** (GPT-5.6; `codex --model gpt-5.6-luna -c model_reasoning_effort="max"`; «Luna Max» = shorthand) | behavioral / security / fidelity — default Strong pair with Qwen 3.8 Max; $0.20/$1.20 (−80%); AAII max 51 |
| Security gate (optional) | **GPT-5.5** | opt-in for highly sensitive cases; historical unique role |

Owner can pin any role: *"сейчас writer=GLM"*, *"сейчас orchestrator=Flash"*. **Cross-family rule:** writer.family ≠ reviewer.family — catches blind spots.

## Install

```bash
ln -sfn ~/Projects/opencode-skills/skills/wave-spec \
  ~/.config/opencode/skills/wave-spec
```

## Example session

> **You:** wave-spec — port a skill from Claude Code to opencode + ZCode, 3 tasks.
>
> **Agent** *(loads wave-spec)*: interview asks about target hosts, fidelity requirements, test surface → produces `SPEC.xml` (3 tasks, gates) + `PLAN.xml` (writer=Flash, reviewer=Qwen, deploy=skill-load-check) → waits for approve → generates `LAUNCH.md` + worker briefs → dispatch → review → closeout with `verify-spec.sh` PASS → Done.

## What's inside

- **References:** `worked-examples.md` (3 end-to-end examples), `program-maps.md` (4 domain menus), `glossary.md` (15 terms), `vv-portability.md`.
- **Templates (15):** `INTENT.md.tmpl`, `SPEC.xml.tmpl`, `PLAN.xml.tmpl`, `STATUS.md.tmpl`, `quick-spec.md.tmpl`, `worker-brief.md.tmpl`, `LAUNCH.md.tmpl`, `NEXT_SESSION.md.tmpl`, `NEXT_SESSION_ITER.md.tmpl`, `iteration-handoff.md.tmpl`, `review-synthesis.md.tmpl`, `fix-round-brief.md.tmpl`, `premortem-brief.md.tmpl`, `ASSUMPTIONS.md.tmpl`, `linear-workflow.md.tmpl`.
- **Scripts:** `verify-spec.sh`, `verify-handoff-payload.sh` (payload gate for the canonical `## Handoff` block — length ≤1500, required headings/labels, semantic values; exit 0–5).

## Router

```
новый проект → project-bootstrap · план спринта → wave-spec · 2+ модели → multi-model-orchestration
```

## License

MIT · part of [opencode-skills](../../README.md)
