---
name: project-orchestra
description: >
  Use when bootstrapping a multi-CLI multi-wave program OS, opening a monorepo
  workstream, planning a wave (SPEC/PLAN), running R.A.E.H. stamp/execute, dual-review
  gates, or Orca dual-worker dispatch — one door: /project-orchestra. Starts with
  intake: study the project folder (git optional), propose a mode, ask 3–5 questions
  if ambiguous. Modes: full, workstream-new, wave, bootstrap-lite, raeh-review,
  raeh-execute, install-dialects, extend. Also: who should orchestrate, harness
  inventory, domain-novelty H-panel, L0, Stamp Dialogue, dispatch dialects
  (formerly skill-work-project-creator). Do NOT use for one-line edits already
  approved, pure domain SEO methodology (use external domain skills after OS is
  ready), or creating a new skill package.
metadata:
  short-description: One-door multi-agent program OS (workstream + wave + R.A.E.H.)
  version: "0.6.1"
  kit: multiagent-kit-1.1
---

# project-orchestra — Multi-Agent Program OS Kit 1.1

**One-line:** One door (`/project-orchestra`) for program OS, monorepo workstreams, wave planning (peer wave-spec or in-package templates), Stamp Dialogue + R.A.E.H., dual-review gates, and Orca dual-worker recipes.

**You (the agent) execute this skill.** Copy templates from this skill dir; run scripts with absolute path to this skill.

```
SKILL_DIR = directory containing this SKILL.md
# Grok:     ~/.grok/skills/project-orchestra
# OpenCode: ~/.config/opencode/skills/project-orchestra
```

---

## 0. Intake (always first — study, then ask)

**Do not materialize files until intake is done** (unless the user already named an exact mode + paths).

### Step A — Study the project (silent scan, no git required)

Look at the **current working directory** (and obvious parents if cwd is a subfolder). Git is optional — files alone are enough.

| Signal | Look for |
|--------|----------|
| Already multi-agent OS? | `AGENTS.md` + `SPEC.md` + `waves/` or `STATUS.md` with gates |
| Minimal agent home? | `AGENTS.md` + `SESSION_HANDOFF.md` + `.agents/memory/` without waves |
| Existing workstream? | Subdirs with own `STATUS.md` + `waves/` |
| Active wave? | `waves/<slug>/` with SPEC/PLAN/REVIEW-STAMP |
| Empty / code-only repo? | No agent files, or only README/src |
| Large / multi-theme? | Many top-level domains, monorepo packages, several products |

Cap deep-read: top-level listing + key marker files. If the tree is huge, **do not invent a plan** — ask what subtree matters.

### Step B — Propose + ask (3–5 questions max)

After the scan, output a short **proposal** (what you think is going on + recommended mode), then ask only what is still ambiguous.

**Always useful questions (pick 3–5, skip what scan already answered):**

1. **Goal now:** full multi-agent OS, only minimal agent home (4 files), new **workstream** (theme under parent), or **wave** (plan/stamp/execute)?
2. **Parent root:** is this folder the program root, or a workstream/subdir of something larger?
3. **Who runs agents:** one CLI/model or multi (orchestrator / executor / auditor families)?
4. **Horizon:** one short task, multi-session wave, or long multi-theme program?
5. **Risk:** anything production / money / public ship this session? (dual-review yes/no)
6. If large repo: **which path/theme** is in scope this session?
7. If multi-model: **default roster** (who leads, who executes, who audits - families e.g. Grok / GLM / DeepSeek / GPT-5.6)?

**Ambiguity rules:**
- workstream vs wave unclear → ask that **one** question first.
- full vs bootstrap-lite unclear → prefer **proposing bootstrap-lite** for small needs; offer full only if multi-CLI multi-wave is explicit.
- OS already complete + user said “bootstrap” → refuse re-`full`; propose workstream / wave / extend.

### Step C — Confirm mode, then act

State: `Mode: <name>` + paths you will touch → wait for user OK if destructive/FORCE or first install on a non-empty tree → then run the mode section below.

Details: `references/intake.md`.

---

## Modes (≤8)

| Mode | Scope | When |
|------|-------|------|
| `full` | Phases 0→4 | New multi-agent program OS at a parent root |
| `workstream-new` | Workstream under parent | Theme folder (STATUS + waves/) inside monorepo parent |
| `wave` | Wave plan draft | New/next wave: peer-call **wave-spec** if installed, else in-package templates |
| `bootstrap-lite` | Exactly 4 files | Minimal agent home when full OS is not needed yet |
| `raeh-review` | Stamp Dialogue REVIEW | Wave SPEC/PLAN ready for stamp |
| `raeh-execute` | EXECUTE after stamp YES | Stamp `AGREED: YES` + hash match |
| `install-dialects` | `prompts/_dispatch` only | Cheatsheets without full boot |
| `extend` | Delta on existing OS | Add roles/CLI, wire-raeh, roles-only, cleanup/archive |

**Intent → mode map**

| User says… | Mode |
|------------|------|
| New multi-agent program / program OS / who orchestrates (full boot) | `full` |
| New workstream / theme under parent / monorepo subfolder | `workstream-new` |
| New wave / plan this wave / SPEC+PLAN | `wave` |
| Only AGENTS + HANDOFF + MEMORY (+ gitignore) | `bootstrap-lite` |
| Review / stamp / AGREED | `raeh-review` |
| Execute stamped wave | `raeh-execute` |
| Dispatch cheatsheets only | `install-dialects` |
| Add role/CLI, wire stamps only, cleanup museum AGENTS | `extend` |

**Route rules (after intake):**
- Simple single-CLI home with no multi-wave need → prefer `bootstrap-lite` (script below), or peer `project-bootstrap` for full Variant-E homes.
- Wave drafting: **peer-call wave-spec if installed**; else use in-package wave templates (see `references/composition.md`). Not a refuse.
- OS already complete + user wants `full` → refuse re-bootstrap; offer `wave` / `workstream-new` / `raeh-review` / `extend`.
- Domain methodology (SEO etc.) → external domain skills after OS ready; never embed hostnames or domain doctrine in this package.
- Do not invent a ninth mode.

## Hard gates

| Gate | Rule |
|------|------|
| L0 | Always before architecture fast-path / G0 (`full`) |
| G0 | Human approve program SPEC.md |
| Dual-review | When table says required — two families; else mark `DEGRADED_DUAL` (see production-playbook) |
| Stamp | EXECUTE only if `REVIEW-STAMP.md` has `AGREED: YES` + hash matches SPEC+PLAN |
| G1 | Human before heavy/prod-bound execute (or pre-approved policy) |
| G-deploy | Human + domain safety ritual for production mutate |
| F-04 | Cross-audit important synthesis with **different model family** |
| Dispatch | Every worker brief: **role + model family + prompt shape** (`references/dispatch-algorithm.md`). Missing shape = invalid dual claim |

**Forbidden:** chat/subject “AGREED” when stamp file ≠ YES. Stamp file wins.

**MD = XML policy:** `SPEC.md`/`PLAN.md` and `SPEC.xml`/`PLAN.xml` are equal for stamp + hash. Prefer format already used in the wave dir; do not convert without need. `hash_acceptance.sh` accepts either pair.

---

## Mode: `workstream-new`

Monorepo layout: **one parent folder** (product/site) → **workstream subfolders** (themes of work) → **waves** inside a workstream.

**Prerequisite:** parent has `AGENTS.md` (full OS or bootstrap-lite). Script **refuses** otherwise unless `ALLOW_NO_PARENT=1`.

```bash
bash "$SKILL_DIR/scripts/install_workstream.sh" "$PARENT_DIR" "<slug>"
# override only when intentional:
# ALLOW_NO_PARENT=1 bash "$SKILL_DIR/scripts/install_workstream.sh" "$PARENT_DIR" "<slug>"
```

Creates under `$PARENT_DIR/<slug>/`:
- `STATUS.md`, `README.md`, `INTENT.md` (optional fill)
- `waves/_template/` (REVIEW-STAMP, EXEC-REPORT, STATUS + PLAN.md)
- Does **not** create a second program OS; parent keeps one HANDOFF/MEMORY.

Write locks and when a separate root is OK: `references/monorepo-workstreams.md`.

---

## Mode: `wave`

1. Detect wave-spec skill (paths such as `~/.grok/skills/wave-spec` or `~/.config/opencode/skills/wave-spec`, or project skill roots).
2. **If wave-spec is installed** → **peer-call** it (do not soft-invoke weasel: actually load and follow wave-spec for INTENT → SPEC → PLAN → human approve). Then return here for `raeh-review`.
3. **Else** → use in-package templates:
   - `assets/templates/WAVE_BRIEF.md.tmpl`
   - `assets/templates/waves/SPEC.md.tmpl` + `waves/_template/PLAN.md.tmpl`
   - Existing REVIEW-STAMP / EXEC-REPORT under `waves/_template/`
   - Copy into a **live** `waves/<date-slug>/` (never treat `_template` as the wave)
   - `bash "$SKILL_DIR/scripts/verify_wave_ready.sh" waves/<date-slug>`
4. MD or XML both valid. After draft → human approve → `raeh-review`.

Contract: `references/composition.md`.

---

## Mode: `bootstrap-lite`

When full multi-agent OS is overkill, materialize **exactly these four files**:

| # | Path |
|---|------|
| 1 | `AGENTS.md` |
| 2 | `SESSION_HANDOFF.md` |
| 3 | `.agents/memory/MEMORY.md` |
| 4 | `.gitignore` |

```bash
bash "$SKILL_DIR/scripts/install_bootstrap_lite.sh" "$PROJECT_DIR" "$PROJECT_NAME"
```

Sources: `assets/templates/AGENTS.md.tmpl`, `SESSION_HANDOFF.md.tmpl`, `MEMORY.md.tmpl`, `gitignore.tmpl`.  
Do **not** call `install_project_os.sh` for this mode (that is full OS creep).  
Do **not** add SPEC/waves/prompts unless user upgrades to `full` or `extend` (wire-raeh).

---

## Mode: `extend`

Use when a program OS (or bootstrap-lite home) **already exists** and the user needs a **delta**, not a full re-bootstrap.

| Sub-intent | What to do |
|------------|------------|
| **roles-only / add-role** | Update role table in `AGENTS.md` / `ROLES.md` from harness inventory; fill orchestrator/executor/auditor placeholders; do **not** re-run Phase 0 H-panel on REPEAT domain unless novelty changed. Optional: copy profile from `assets/templates/profiles/`. |
| **wire-raeh** | If OS exists without `waves/_template`: install from `assets/templates/waves/` (or re-run relevant parts of `install_project_os.sh` only for waves/prompts). Then `verify_raeh_ready.sh` + `verify_stamp_schema.sh` on template stamp. |
| **install-dialects** (via extend) | Prefer dedicated mode `install-dialects`; if user said “extend dispatch”, copy `assets/templates/prompts/_dispatch/`. |
| **cleanup / archive** | Move Phase 0–1 journey and museum paths → `audits/_legacy/`; prune AGENTS to live mounts only (`references/archive-hygiene.md`). Do not delete user evidence without asking. |

**Rules:**
- Never run `full` materialize over an existing OS without explicit FORCE + human OK.
- After roles-only with a **single** model family: on dual-required waves mark `DEGRADED_DUAL` (see production-playbook).
- Verify after structural change:
  ```bash
  bash "$SKILL_DIR/scripts/verify_os_gate.sh" "$PROJECT_DIR"   # if full OS expected
  bash "$SKILL_DIR/scripts/verify_handoff_gate.sh" "$PROJECT_DIR"
  bash "$SKILL_DIR/scripts/verify_raeh_ready.sh" "$PROJECT_DIR"  # if waves wired
  ```

---

## Phase flow (`full`)

```
INTENT → Phase 0 Discovery → Phase 1 Architecture (L0) → Human G0
      → Phase 2 Wire R.A.E.H. + dialects → Phase 3 Materialize → Phase 4 Cleanup
```

### Phase 0 — Discovery & model selection

1. Map adjacent projects (cap deep-read HIGH relevance **3–5**).
2. Run harness inventory:
   ```bash
   bash "$SKILL_DIR/scripts/inventory_harness.sh" "$PROJECT_DIR"
   ```
3. Classify program type:
   ```bash
   bash "$SKILL_DIR/scripts/classify_program.sh" "$PROJECT_DIR"
   ```
4. Set `domain_novelty` = `FIRST_IN_PORTFOLIO` | `REPEAT_DOMAIN` | `TRANSFER`  
   Read `references/domain-novelty.md`.
5. Draft role matrix from harness (not prestige). Template: `references/role-matrix.md`.  
   **Each active role row must include:** CLI + **model family** + default **prompt shape id**  
   (from `references/model-prompt-shapes.md` / `dispatch-algorithm.md`). Example:  
   `Executor | opencode | deepseek-v4-pro | shape:deepseek-what-where-done`.
6. Self-assessment for any role ≥10% load → `references/self-assessment-brief.md`.
7. **H-panel:** ON if FIRST (3–5 falsifiable Hs); OFF if REPEAT. Rules: `references/h-panel-rules.md`.  
   Template: `assets/templates/audits/h-panel/H-TEMPLATE.md.tmpl`.  
   If ≥3 FAIL/PARTIAL on single-model dominance → emit `ROLE_ARCHITECTURE_REQUIRED` (success).
8. Platform study only if harness unknown.
9. Write synthesis → `audits/phase0-role-synthesis.md` (from tmpl). Include roster table with shape ids.

### Phase 1 — Architecture decision

1. Write program `SPEC.md` from `assets/templates/SPEC.md.tmpl` (architecture MD — **not** wave contract).
2. **L0 Consistency Pass (never skip):**
   ```bash
   bash "$SKILL_DIR/scripts/verify_l0_inputs.sh" "$PROJECT_DIR"
   ```
   Produce `audits/<YYYY-MM-DD>-L0-consistency.md` from tmpl. Verdict: `CLEAN` | `CONTRADICTIONS`.  
   Details: `references/l0-consistency.md`.
3. Multi-model architecture panel only if L0 CONTRADICTIONS / first high-stakes / human asks.  
   Wave-level SPEC → never full panel; use Stamp Dialogue.
4. Iterate ≤3 rounds → present for **Human G0**.

### Phase 2 — Wire protocols

1. Install wave R.A.E.H. tree from `assets/templates/waves/`.
2. Install dispatch pack from `assets/templates/prompts/_dispatch/` + profiles:  
   role cheatsheets **and** `model-shapes.md` + `dispatch-algorithm.md`.
3. Encode orchestrator rules:  
   - **never execute without stamp YES**;  
   - **every worker send** follows dispatch algorithm (role → family → shape → pin → file → send).
4. Verify:
   ```bash
   bash "$SKILL_DIR/scripts/verify_raeh_ready.sh" "$PROJECT_DIR"
   bash "$SKILL_DIR/scripts/verify_stamp_schema.sh" "$PROJECT_DIR/waves/_template/REVIEW-STAMP.md"
   ```

### Phase 3 — Infrastructure materialization

Copy/adapt templates into project (substitute `${PROJECT_NAME}`, `${DATE}`, roles):

| Artifact | Template |
|----------|----------|
| AGENTS.md | `assets/templates/AGENTS.md.tmpl` |
| CLAUDE.md | only if Claude in roster |
| SPEC.md, INTENT.md, STATUS.md, plan.md | corresponding `.tmpl` |
| SESSION_HANDOFF.md | gitignored append-only |
| .agents/memory/MEMORY.md | MEMORY.md.tmpl |
| .gitignore | gitignore.tmpl |
| docs/access-map.md, cross-project-map.md | docs/*.tmpl |
| audits/README.md, lanes per role | audits/*.tmpl |
| research/ | empty dirs as needed |
| prompts/_dispatch/* | from install-dialects assets |
| ROLES.md, NEXT_SESSION_PROMPT.md | optional ops templates |

Or:
```bash
bash "$SKILL_DIR/scripts/install_project_os.sh" "$PROJECT_DIR" "$PROJECT_NAME"
```

Then:
```bash
bash "$SKILL_DIR/scripts/verify_os_gate.sh" "$PROJECT_DIR"
bash "$SKILL_DIR/scripts/verify_handoff_gate.sh" "$PROJECT_DIR"
```

### Phase 4 — Cleanup & handoff

1. Archive Phase 0–1 journey → `audits/_legacy/` (H-panel, role synthesis).
2. Prune AGENTS tree to **live mounts** only (no museum paths). See `references/archive-hygiene.md`.
3. Session-start diet ≤5 files: HANDOFF + STATUS + MEMORY (+ optional SPEC/waves pointer).
4. STATUS `CURRENT_FOCUS` = **first wave or domain task**, not “finish architecture”.
5. Done definition: `references/done-definition.md` (P1–P12).

---

## R.A.E.H. modes (`raeh-review` / `raeh-execute`)

Full card: `references/stamp-dialogue.md`, lifecycle: `references/raeh-lifecycle.md`.  
Universal loop + dual-review table: `references/production-playbook.md`.

```
DRAFT (wave mode / wave-spec peer) → REVIEW* (Stamp Dialogue) → AGREE (YES + acceptance.hash)
  → EXECUTE → VERIFY (optional F-04) → HANDOFF
```

### raeh-review

1. Require wave dir with SPEC+PLAN as **xml or md** (equal policy).
2. Same reviewer session for rounds 1..N (default MAX=5).
3. Write/update `REVIEW-STAMP.md` with required fields:
   - `AGREED: YES | NO`
   - `SPEC_PATH`, `PLAN_PATH`, `SPEC_HASH`
   - `ROUND` / `MAX`, `SESSION_ID`
   - Open deltas table if NO
   - Execute blockers / next action
4. Validate: `bash "$SKILL_DIR/scripts/verify_stamp_schema.sh" <stamp-path>`
5. On YES: `bash "$SKILL_DIR/scripts/hash_acceptance.sh" <wave-dir>` then put **64-hex** into stamp `SPEC_HASH` (placeholders fail schema).

### raeh-execute

1. Refuse unless stamp `AGREED: YES` **and** hash matches live SPEC+PLAN:
   ```bash
   bash "$SKILL_DIR/scripts/verify_stamp_schema.sh" <wave-dir>
   bash "$SKILL_DIR/scripts/verify_stamp_hash.sh" <wave-dir>
   ```
2. Build executor brief via **dispatch algorithm**  
   (`role=executor` + executor family shape + output=`EXEC-REPORT.md`).  
   GPT-5.6 executor → lean Goal/Success/Stop (OpenAI guidance), not GLM/DeepSeek form.
3. Execute only approved PLAN scope; write `EXEC-REPORT.md` with evidence paths.
4. Executor does **not** edit STATUS.md / MEMORY.md (orchestrator owns). Executor does **not** re-stamp.
5. Idempotency: waveId + phase + round + specHash + dispatchId (`references/idempotency.md`).
6. **Same reviewer session** for rounds 1..N; **fresh executor session** after YES + verified hash.

Lightweight: tiny doc tweak / no acceptance change → skip stamp. Flash one-shot → no session. Emergency → human + short stamp.

---

## Dual-review + Orca (summary)

| When dual required | Who | How |
|--------------------|-----|-----|
| Gate-critical plan / ship skill description / high-stakes synthesis | Two **different model families** | Orca: **two terminals**; **two shapes** (algorithm per worker) |
| Dual unavailable | Document `DEGRADED_DUAL` | Single family + bias warning; do not fake dual |

**Per worker (mandatory):** run `references/dispatch-algorithm.md`  
→ role → family → prompt shape → pin CLI/model/effort → write brief file → send → identity gate.

**GPT-5.6 worker:** shape `gpt56-goal-success-stop` (Goal + Success + Stop, lean).  
Official: [OpenAI GPT-5.6 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6).  
Effort/pro/verbosity = API pin, not “think step by step” in prose.

**Never** two parallel bare `opencode run` (DB lock).  
Details: `production-playbook.md`, `orca-recipes.md`, `dispatch-iron.md`, `dispatch-algorithm.md`.

---

## Dispatch dialects (`install-dialects`)

Two layers - both required for multi-model work:

| Layer | What | Source |
|-------|------|--------|
| **Role profile** | executor / orchestrator / auditor / flash | `profiles/`, role cheatsheets |
| **Model shape** | DeepSeek / GLM / Grok / **GPT-5.6** skeletons | `model-shapes.md` |
| **Algorithm** | role → family → shape → pin → send | `dispatch-algorithm.md` |

| Profile | Default form | Typical role |
|---------|--------------|--------------|
| `executor-task-done` | Task → Done (paths) → Autonomy | Wave Executor (often Grok/DeepSeek) |
| `orchestrator-goal-context` | Goal → Context → Done | Orchestrator (often GLM) |
| `auditor-what-where` | What → Where → Readiness | Cross-auditor |
| `flash-oneshot` | Single output path | Stateless pull |
| *(family override)* | GPT-5.6 always prefers **Goal + Success + Stop** lean | Any role on GPT-5.6 |

Install to project:
```
prompts/_dispatch/
├── README.md
├── executor-cheatsheet.md
├── orchestrator-cheatsheet.md
├── auditor-cheatsheet.md
├── flash-cheatsheet.md
├── model-shapes.md
└── dispatch-algorithm.md
```

Sources: `assets/templates/prompts/_dispatch/` and `assets/templates/profiles/`.  
Selection: `references/profile-selection.md` + **`references/dispatch-algorithm.md`**.  
Shapes: `references/model-prompt-shapes.md`.  
Anti-patterns: `references/anti-patterns.md`.

---

## Scripts (deterministic gates)

| Script | Purpose |
|--------|---------|
| `scripts/classify_program.sh` | multi-agent vs single-home; domain_novelty hint |
| `scripts/inventory_harness.sh` | CLIs, skill packs, MCP markers (best-effort) |
| `scripts/install_project_os.sh` | materialize **full** OS templates into target project |
| `scripts/install_bootstrap_lite.sh` | **exactly 4 files** — no waves/SPEC creep |
| `scripts/install_workstream.sh` | workstream under parent (requires parent `AGENTS.md` unless `ALLOW_NO_PARENT=1`) |
| `scripts/verify_os_gate.sh` | Phase 3 done checks |
| `scripts/verify_l0_inputs.sh` | lists canon files for L0 |
| `scripts/verify_handoff_gate.sh` | handoff/MEMORY/AGENTS separation |
| `scripts/verify_stamp_schema.sh` | required stamp fields; YES requires **64-hex** hash (not placeholder / CHECKLIST_VERSION) |
| `scripts/verify_stamp_hash.sh` | **pre-execute**: re-hash stamp SPEC_PATH+PLAN_PATH vs SPEC_HASH |
| `scripts/verify_wave_ready.sh` | **live** wave has SPEC+PLAN+stamp (not `_template`) |
| `scripts/verify_raeh_ready.sh` | waves/_template skeleton + README (install only) |
| `scripts/hash_acceptance.sh` | sha256 SPEC+PLAN (xml **or** md) → acceptance.hash |

All accept `[project_dir]` or path args; support `--help`; exit 0 on pass.

---

## Target layouts

### Parent program OS (after `full`)

```
<project>/
├── AGENTS.md, SPEC.md, INTENT.md, STATUS.md, plan.md
├── SESSION_HANDOFF.md          # gitignored, append-only
├── CLAUDE.md                   # if Claude in roster
├── .gitignore
├── .agents/memory/MEMORY.md
├── prompts/_dispatch/...
├── waves/README.md + _template/ + <date-slug>/
├── <workstream-slug>/          # via workstream-new
│   ├── STATUS.md, README.md, INTENT.md
│   └── waves/_template/ + <date-slug>/
├── audits/, docs/, research/
```

### bootstrap-lite only

```
<project>/
├── AGENTS.md
├── SESSION_HANDOFF.md
├── .agents/memory/MEMORY.md
└── .gitignore
```

Program architecture = `SPEC.md`. Wave contracts = `waves/*/SPEC.{xml|md}` + `PLAN.{xml|md}`.

---

## Progressive disclosure (read on demand)

| File | When |
|------|------|
| `references/intake.md` | First-session study + 3–5 questions |
| `references/composition.md` | wave-spec peer-call vs templates; bootstrap boundary |
| `references/monorepo-workstreams.md` | Parent vs workstream write locks |
| `references/production-playbook.md` | Universal loop; dual-review gate table; DEGRADED_DUAL |
| `references/dispatch-algorithm.md` | **Mandatory** role × family × shape before every worker send |
| `references/dispatch-iron.md` | Pin agent+model+shape; F-04 vs stress; identity gate |
| `references/orca-recipes.md` | Dual-terminal parallel workers (no headless double-run) |
| `references/domain-novelty.md` | FIRST / REPEAT / TRANSFER |
| `references/h-panel-rules.md` | Falsifiable Hs |
| `references/harness-beats-model.md` | Inventory-first roles |
| `references/role-matrix.md` | Archetypes + write locks |
| `references/self-assessment-brief.md` | ≥10% roles |
| `references/l0-consistency.md` | L0 checklist |
| `references/cross-audit-protocol.md` | F-04 cost control |
| `references/degraded-modes.md` | 1–2 model modes + DEGRADED_DUAL |
| `references/archive-hygiene.md` | Phase 4 / extend cleanup |
| `references/done-definition.md` | K/P/W checks |
| `references/stamp-dialogue.md` | Full stamp card |
| `references/raeh-lifecycle.md` | Wave lifecycle |
| `references/session-policy.md` | Session per wave |
| `references/idempotency.md` | Dispatch ids |
| `references/metrics.md` | rounds-to-YES |
| `references/profile-selection.md` | Role → profile |
| `references/model-prompt-shapes.md` | How to phrase tasks for DeepSeek / GLM / Grok / GPT-5.6 |
| `references/anti-patterns.md` | Dispatch fails |

---

## Composition (do not absorb)

| Peer | Relationship |
|------|----------------|
| **wave-spec** | **Peer-call if installed** for wave draft; else in-package templates. This skill stamps/executes. Not soft-invoke. |
| **project-bootstrap** | Full Variant-E single-CLI homes; this skill’s `bootstrap-lite` is the 4-file minimal path |
| **zcode-bootstrap** | ZCode native bits; then this skill `extend` |
| **vs-architect** | Optional helper in Phase 0 |
| Domain skills | After OS ready — never embedded |

Mirror install: keep identical trees at `~/.grok/skills/project-orchestra` and `~/.config/opencode/skills/project-orchestra` (symlink or copy; `VERSION` pin **0.6.1**). No project-specific hostnames in package.

## Anti-patterns

- H-panel on every REPEAT_DOMAIN project  
- Skip L0 because files “look fine”  
- Chat AGREED without stamp YES  
- Paste full AGENTS/MEMORY into every dispatch  
- Done = vibes without artifact path / verify report  
- Executor edits STATUS/MEMORY  
- One eternal multi-wave session  
- Two bare parallel `opencode run` (use Orca dual terminals)  
- Worker brief without model family prompt shape (especially GPT-5.6 thick dump)  
- Domain residue (site hostnames, CMS-only rules) inside skill package  
- Creating a new skill name instead of extending this one door  
