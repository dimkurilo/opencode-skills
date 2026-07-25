---
name: wave-spec
description: >
  Portable plan-gate skill (vv-method, multi-CLI): INTENT → interview → structured SPEC.xml
  + PLAN.xml → human approve → worker briefs → STATUS/handoff. Use when the user starts a
  sprint/wave, says "wave-spec", "spec first", "составь спеку/план", "interview then plan",
  or begins multi-session SEO/engineering work that must not skip planning. Works in Grok,
  Claude Code, OpenCode, ZCode — writes files in the project, does not require vv-opencode
  runtime. Do NOT use for trivial one-line edits already approved by the user.
---

# wave-spec

**Method:** same as vv-opencode (`vv-spec` → `vv-plan` → approve → exec), but **portable**:
structured XML artifacts in the repo, any orchestrator CLI.

**You (the agent) execute this skill.** The user does not need to invent the pipeline.

## Modes

| Mode | Trigger | Output |
|------|---------|--------|
| `program` | Big multi-week project (full SEO, site rebuild) | `roadmap/PROGRAM_SPEC.xml` + `roadmap/PROGRAM_PLAN.xml` |
| `wave` (default) | One sprint 2–7 days / one theme | `waves/<date>-<slug>/…` |
| `task` | Single atomic task inside approved wave | `waves/.../tasks/TNN-*.xml` + worker brief |

Default: if unclear, start **wave**. If user describes a whole site/SEO program with no roadmap yet → **program** first, then first **wave**.

## Installation / SoT

**Source of Truth:** `skills/wave-spec/` in the opencode-skills repo — git-tracked, canonical. All edits go here.

**Host symlinks** (replace real directories with `ln -s` to SoT):
- `~/.grok/skills/wave-spec` → `<repo>/skills/wave-spec`
- `~/.config/opencode/skills/wave-spec` → `<repo>/skills/wave-spec`
- `~/.claude/skills/wave-spec` → `<repo>/skills/wave-spec`

If the repo moves, recreate symlinks:
```bash
ln -sf <new-repo-path>/skills/wave-spec ~/.grok/skills/wave-spec
ln -sf <new-repo-path>/skills/wave-spec ~/.config/opencode/skills/wave-spec
ln -sf <new-repo-path>/skills/wave-spec ~/.claude/skills/wave-spec
```
## Hard gate

Until user says **approve / approved / proceed / dig / делай / утверждаю**:

- **Do** write planning artifacts (INTENT/SPEC/PLAN/STATUS templates).
- **Do not** implement site changes, bulk content, deploy, or dispatch workers for execution.
- **Do** research/read repo, AGENTS.md, SESSION_HANDOFF, diagnostics (read-only).

After approve: produce worker briefs and optionally Orca dispatch commands; still do not expand scope beyond PLAN.

> **Lifecycle gates:** before claiming Done or handing off to NEXT product, follow the contract in [Lifecycle Gates](#lifecycle-gates-production-lessons).

---

## Pipeline (run in order)

### 0. Locate workspace

1. Find project root (AGENTS.md or git root).
2. Read if present: `AGENTS.md`, last block of `SESSION_HANDOFF.md`, `plan.md`, `.agents/memory/MEMORY.md`.
3. Detect existing `roadmap/` and `waves/` — never overwrite approved artifacts without asking; version with new date slug instead.

### 1. INTENT (human or draft-for-human)

Path:

- program: `roadmap/INTENT.md`
- wave: `waves/<YYYY-MM-DD>-<slug>/INTENT.md`

If user already pasted free text → save it as INTENT.md (light edit for structure only).

If missing → write a draft INTENT from conversation and ask user to correct:

```markdown
# INTENT
## What I want (freeform)
## Sites / URLs
## Constraints (budget, no-deploy, region, language)
## Success in my words
## Out of scope (if known)
## Links to existing research
```

**Stop if INTENT is empty or contradictory** — ask 1–2 clarifying questions only.

### 2. Interview (3–7 questions)

After INTENT + context read:

1. List open issues: ambiguity / contradiction / blocker / risk / assumption.
2. Ask **only** questions that unblock SPEC (max 7). Each question: options + recommended default.
3. Do **not** interview for things already answered in AGENTS/handoff/research.

If user says «решай сам / use defaults» → mark assumptions explicitly in SPEC.

### 3. SPEC.xml (structured — agent-facing)

**Prefer XML** for SPEC/PLAN (schema-like nesting; easier for agents to parse than free MD).
Human narrative stays in INTENT.md.

Use template: `assets/templates/SPEC.xml.tmpl`  
Write to: `…/SPEC.xml`

Required sections:

| Tag | Content |
|-----|---------|
| `status` | `draft` until user approves → then `approved` |
| `goal` | 1–2 paragraphs + measurable success criteria |
| `scope/in` `scope/out` | explicit |
| `constraints` | tech, legal, deploy gates, model roles |
| `sources` | existing files/URLs with dates — no invented metrics |
| `architecture` or `workstreams` | for SEO: tech / content / on-page / off-page / geo-aeo / analytics |
| `risks` | with mitigation |
| `acceptance` | checklist that proves wave/program done |

**Evidence rule:** every number needs `source` attribute or child `<source>`. Unknown → `<todo>…</todo>`, never invent.

### 4. PLAN.xml (waves, deps, owners)

Template: `assets/templates/PLAN.xml.tmpl`  
Write to: `…/PLAN.xml`

Required:

- `waves` or for single wave: `tasks` with `id`, `title`, `depends_on`, `owner` (orchestrator|claude|opencode|grok|human), `model_hint`, `artifact` path, `done_when`
- Parallel groups: tasks with empty/non-overlapping `depends_on` and different `artifact` paths
- `gates`: human approval points (deploy, purchase, CMS production)

For **program** PLAN: only high-level phases (Phase 0…N) and what the **first wave** will be.  
For **wave** PLAN: atomic tasks (3–12), not 50.

### 5. Human approve

Present short summary:

1. Goal + success  
2. Out of scope  
3. Task table (id / owner / artifact / depends)  
4. Open risks  
5. Exact phrase: «Ответь **approve**, если можно исполнять; или правки к SPEC/PLAN.»

On approve: set `<status>approved</status>` in SPEC.xml and PLAN.xml, append line to STATUS.md.

### 6. Dispatch prep (after approve only)

For each ready task (`depends_on` satisfied):

1. Write `tasks/<id>.xml` (optional if task fully in PLAN)  
2. Write `tasks/<id>.brief.md` — **worker-facing**, 20–40 lines:

```markdown
# Task <id>
## Role
You are EXECUTOR, not strategist.
## Read first
- AGENTS.md
- <SPEC path>
- <only relevant PLAN task + sources>
## Do only
...
## Write only
<path(s)>
## Done when
...
## Forbidden
- invent metrics
- expand scope
- edit plan/SPEC
```

3. If Orca available, print (do not force) commands:

```bash
orca terminal create --worktree active --title <id> --command "claude" --json
# or opencode / grok
orca terminal send --terminal <handle> --text "$(cat tasks/<id>.brief.md)" --enter --json
```

Orchestrator tracks progress in STATUS.md.

### 7. STATUS + HANDOFF

Maintain `…/STATUS.md`:

```markdown
# STATUS
| id | owner | state | artifact | notes |
|----|-------|-------|----------|-------|
| T01 | claude | done | research/... | |
```

End of session: append `SESSION_HANDOFF.md` block (project protocol). Facts → MEMORY.md.

> **Lifecycle gates:** before closing wave as Done, verify all gates passed — see [Lifecycle Gates](#lifecycle-gates-production-lessons).

---

## XML vs Markdown (policy)

| Artifact | Format | Why |
|----------|--------|-----|
| INTENT | Markdown | human freeform |
| SPEC / PLAN / task cards | **XML** | nested structure, required fields, agent-parseable (vv-method without vv runtime) |
| Worker brief | Markdown | easy to paste into any terminal |
| STATUS / HANDOFF | Markdown | human + append-only |

You do **not** need `vv-opencode` installed. XML is just the **on-disk contract**.  
If the harness cannot write XML cleanly, fall back to the same tags as Markdown headings — but prefer XML.

GRACE anchors: optional in INTENT/STATUS; for XML use attributes `id="…"` on elements instead of HTML comments.

---

## Scaling: tens of sessions (e.g. full WooCommerce SEO)

Do **not** put the entire project into one wave.

1. **Program** once: workstreams + phase order + definition of done for the site.  
2. **Waves** repeatedly: each wave = one theme that fits 1–5 sessions.  
3. Example SEO program phases (adapt to evidence, do not invent site state):

| Phase | Theme | Typical artifacts |
|-------|--------|-------------------|
| P0 | Inventory + access + baseline | crawl notes, GSC/Metrika baseline, plugin list |
| P1 | Technical SEO foundations | robots, sitemap, indexation, canonical, redirects |
| P2 | Performance / CWV | PSI report, theme/plugin plan, caching |
| P3 | On-page templates | product/category/home schema + title patterns |
| P4 | Content system | briefs, category texts, blog/GEO policy |
| P5 | GEO/AEO | AI bot access, FAQ/schema, citation pages |
| P6 | Internal links + nav | silo map, hub pages |
| P7 | Measurement cadence | dashboards, monthly checklist |

**First session after skill install:** program SPEC/PLAN **or** one wave if program already exists in `plan.md`.

Never force «10 GEO prompts» — only tasks that appear in INTENT + evidence.

---

## Orchestrator vs executor

| Role | Default | Allowed |
|------|---------|---------|
| Orchestrator (runs this skill) | Grok or Claude | SPEC/PLAN, interview, STATUS, dispatch briefs |
| Executor | Claude+GLM / OpenCode / Grok | only approved task brief + artifacts |

Executors **do not** rewrite SPEC/PLAN. They may append STATUS notes.

---

## Quality bar

- SPEC success criteria are **checkable** without vibes.  
- Every task has **one primary artifact path**.  
- Parallel tasks **do not share write paths**.  
- Deploy / paid tools / production CMS = `owner=human` gate.  
- No fabricated SEO metrics (positions, traffic) without source.

## References

- `assets/templates/` — INTENT, SPEC.xml, PLAN.xml, STATUS, brief  
- `references/seo-program-map.md` — optional workstream checklist for full-site SEO  
- `references/vv-portability.md` — mapping to vv-opencode tags  

## Anti-patterns

- Implementing during interview.  
- One PLAN with 40 tasks and no phases.  
- Freeform-only plan with no SPEC.  
- XML for INTENT (wrong layer).  
- Requiring vv-opencode CLI to use this skill.  
- Assuming the site goal is «GEO prompts» without INTENT.

---

## Lifecycle Gates ([TICKET] → [TICKET] lessons)

**Context:** [TICKET] root cause — agent marked "In Review" / "next product" while code not on prod. No hard states: implement ≠ In Review ≠ merged ≠ deployed ≠ owner smoke ≠ Done. This section encodes the lifecycle contract for waves built with this skill.

### Lifecycle States

| State | Definition | Gate |
|-------|-----------|------|
| **Implement done** | Writer finished, own verification green (build/lint/tests per project), implement notes written | `worker_done` or executor signals completion |
| **In Review** | Dual review passed: static parity (GLM) ∥ behavioral semantics (Codex/equivalents). 0 MAJOR or all MAJOR fixed. Writer ≠ reviewer | Synthesis: stricter wins, all MAJOR closed |
| **Commit** | Public paths committed to branch. Only project-tracked files staged — no dev files (AGENTS.md, SESSION_HANDOFF, .agents/) | `git status` clean of dev files. No merge yet |
| **PR** | Pull request opened, reviewable by orchestrator/team. All gates below merge verified independently | PR gate: description complete, reviewers assigned |
| **Merge** | PR approved, merged to main. CI green, no unresolved review threads | Merge gate: CI green |
| **Deploy gate passed** | Deploy probe passed: new routes/paths return ≠ 404 (see Deploy Probe below). 307/302 redirect = OK (route exists) | `curl` probes confirm route existence |
| **On prod (owner residual)** | Deployed. Smoke-tested by orchestrator OR owner | No live smoke = **RESIDUAL-RISK-OWNER-SMOKE**. Owner or next session handles production smoke |
| **Done (complete)** | All gates above passed, handoff written, project tracker updated | Orchestrator signs off |

**Explicit ordering:** Implement done → In Review → Commit → PR → Merge → Deploy gate → On prod (owner smoke OR RESIDUAL-RISK-OWNER-SMOKE) → Done.

Do **not** equate "writer claims Done" with "In Review passed" or "prod-ready". Do **not** collapse commit/PR/merge into "writer Done" — each gate (Commit, PR, Merge) is independent and verified. Do **not** handoff to "NEXT product" until Deploy gate passed.

**Ban:** «NEXT product» handoff while Deploy gate not passed. Handoff with residual risk must say **RESIDUAL-RISK-OWNER-SMOKE** explicitly — never claim Done without deploy proof.

---

## Fidelity Dual Review

For fidelity ports, reference→platform migrations, or behavioral parity waves:

1. **Dual review mandatory:** GLM (static parity, file:line matrix) ∥ Codex or equivalent behavioral reviewer (hosted semantics, cost/state regressions). Single-reviewer fidelity ports are NOT accepted.
2. **Writer ≠ reviewer.** Flash = explicitly excluded from fidelity reviews (simplifies, [TICKET] post-mortem).
3. **MAJOR from any reviewer → fix round before In Review.** Stricter severity wins on contradictions.
4. **No live smoke = RESIDUAL-RISK-OWNER-SMOKE** in handoff. Document explicitly. Do not claim Done — claim Done-with-residual.
5. **Deploy gate:** curl new routes before handoff (see below).

For non-fidelity waves: dual review is recommended but not mandatory. At minimum, writer ≠ reviewer.

---

## Deploy Probe (Universal Pattern)

Before handoff after merge: prove that new/affected routes or artifacts exist at the deploy surface. The probe checks existence, not correctness — correctness is verified at In Review.

```bash
# Existence check — no -L so redirect is the proof (auth-protected routes):
curl -sI https://<deploy-url>/<new-route> | head -1
# Expected: HTTP/... 307 or 302 (redirect = route exists).
# 404 = route missing → fix before handoff.

# OR probe final status (follow redirects, get final HTTP code + effective URL):
curl -sIL -o /dev/null -w '%{http_code} %{url_effective}\n' https://<deploy-url>/<new-route>
# Interpret: final 200/307/401/403 ≠ 404 = route exists.
# final 404 = route missing.
```

Adapt the probe to your deploy surface:
- **Web app:** curl route/path endpoints
- **Static site:** curl page URLs after deploy
- **Package/skill:** verify file existence + size at install path
- **API:** curl API endpoints

Principle: one observable command that proves the artifact reached production. No probe = RESIDUAL-RISK-OWNER-SMOKE.

Evidence: [TICKET] had untracked route files — if deployed without tracking, 404. This gate catches missing artifacts before signoff.

---

## Positioning

wave-spec is a **light plan-gate + lifecycle skill for 1–3 week product/SEO waves**. It is NOT gsd-core, gsd-coordinator, or vv-opencode runtime — no agentic dispatch, no worktree groups, no structured handoff beyond project-local SESSION_HANDOFF. The lifecycle gates above are the contract; everything else is project protocol.

For multi-model orchestration (parallel review, dispatch, fidelity port routing): see `skills/multi-model-orchestration/` — a separate skill for [platform]-level coordination. wave-spec delegates to it when multi-model review is needed; multi-model does NOT own the plan-gate pipeline.

---

## Changelog

- **v1.0** — initial portable wave-spec from vv-method
- **v1.1 ([TICKET])** — lifecycle gates (Implement→In Review→Commit→PR→Merge→Deploy Probe→On Prod→Done), fidelity dual review, deploy probe curl pattern, RESIDUAL-RISK-OWNER-SMOKE, NEXT product ban, Installation/SoT section, discoverability pointers, positioning, README bilingual + residual
