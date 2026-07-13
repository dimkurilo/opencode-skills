---
name: project-orchestra
description: >
  Bootstrap a multi-CLI multi-wave program OS (project-orchestra kit): harness inventory,
  domain-novelty H-panel, role matrix, L0 consistency, program SPEC, R.A.E.H. Stamp Dialogue,
  dispatch dialects, evidence plane, archive hygiene. Modes: full, roles-only, wire-raeh,
  extend, cleanup, raeh-review, raeh-execute, install-dialects. Use when starting a multi-agent
  program, choosing orchestrator vs executor, multi-agent bootstrap, who should orchestrate,
  R.A.E.H., stamp dialogue, or project-orchestra (formerly skill-work-project-creator). Do NOT use for simple single-CLI
  scaffolds (project-bootstrap / zcode-bootstrap), pure wave drafting on an existing OS
  (wave-spec + raeh mode), or one-line edits.
metadata:
  short-description: Multi-agent program OS kit (orchestra + R.A.E.H. + dialects)
  version: "1.0.0"
  kit: multiagent-kit-1.0
---

# project-orchestra — Multi-Agent Program OS Kit 1.0

**One-line:** Boot a multi-CLI program OS, wire Stamp Dialogue + R.A.E.H., install dispatch dialects — without re-paying first-domain discovery tax every project.

**You (the agent) execute this skill.** Copy templates from this skill dir; run scripts with absolute path to this skill.

```
SKILL_DIR = directory containing this SKILL.md
# Grok:     ~/.grok/skills/project-orchestra
# OpenCode: ~/.config/opencode/skills/project-orchestra
```

## Modes

| Mode | Scope | When |
|------|-------|------|
| `full` | Phases 0→4 | New multi-agent program |
| `roles-only` | Phase 0 (light) + 1 | Who orchestrates / role matrix only |
| `wire-raeh` | Phase 2 + partial 3 | OS exists; need waves/stamps only |
| `extend` | Inventory delta + 3 + 4 | Add roles/CLI to existing OS |
| `cleanup` | Phase 4 only | Archive journey, prune museum AGENTS |
| `raeh-review` | Stamp Dialogue REVIEW | Wave SPEC/PLAN ready for stamp |
| `raeh-execute` | EXECUTE after stamp YES | Stamp AGREED=YES + hash match |
| `install-dialects` | prompts/_dispatch only | Need cheatsheets without full boot |

**Route rules:**
- Single-CLI simple agent home → **stop**, recommend `project-bootstrap` / `zcode-bootstrap`.
- Wave drafting INTENT→SPEC.xml→PLAN.xml → peer skill **`wave-spec`** (do not reimplement).
- OS already complete + user wants `full` → refuse; point to `wave-spec` + `raeh-review`.
- Domain SEO methodology → external `/seo` skills; never embed domain doctrine here.

## Hard gates

| Gate | Rule |
|------|------|
| L0 | Always before architecture fast-path / G0 |
| G0 | Human approve program SPEC.md |
| Stamp | EXECUTE only if `REVIEW-STAMP.md` has `AGREED: YES` + hash matches SPEC+PLAN |
| G1 | Human before heavy/prod-bound execute (or pre-approved policy) |
| G-deploy | Human + domain safety ritual for production mutate |
| F-04 | Cross-audit important synthesis with **different model family** |

**Forbidden:** chat/subject “AGREED” when stamp file ≠ YES. Stamp file wins.

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
6. Self-assessment for any role ≥10% load → `references/self-assessment-brief.md`.
7. **H-panel:** ON if FIRST (3–5 falsifiable Hs); OFF if REPEAT. Rules: `references/h-panel-rules.md`.  
   Template: `assets/templates/audits/h-panel/H-TEMPLATE.md.tmpl`.  
   If ≥3 FAIL/PARTIAL on single-model dominance → emit `ROLE_ARCHITECTURE_REQUIRED` (success).
8. Platform study only if harness unknown.
9. Write synthesis → `audits/phase0-role-synthesis.md` (from tmpl).

### Phase 1 — Architecture decision

1. Write program `SPEC.md` from `assets/templates/SPEC.md.tmpl` (architecture MD — **not** wave XML).
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
2. Install dispatch cheatsheets from `assets/templates/prompts/_dispatch/` + profiles.
3. Encode orchestrator rule: **never execute without stamp YES**.
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

```
DRAFT (wave-spec) → REVIEW* (Stamp Dialogue) → AGREE (YES + acceptance.hash)
  → EXECUTE → VERIFY (optional F-04) → HANDOFF
```

### raeh-review

1. Require wave dir with SPEC.xml + PLAN.xml (from wave-spec).
2. Same reviewer session for rounds 1..N (default MAX=5).
3. Write/update `REVIEW-STAMP.md` with required fields:
   - `AGREED: YES | NO`
   - `SPEC_PATH`, `PLAN_PATH`, `SPEC_HASH`
   - `ROUND` / `MAX`, `SESSION_ID`
   - Open deltas table if NO
   - Execute blockers / next action
4. Validate: `bash "$SKILL_DIR/scripts/verify_stamp_schema.sh" <stamp-path>`
5. On YES: `bash "$SKILL_DIR/scripts/hash_acceptance.sh" <wave-dir>`

### raeh-execute

1. Refuse unless stamp `AGREED: YES` and hash matches.
2. Execute only approved PLAN scope; write `EXEC-REPORT.md` with evidence paths.
3. Executor does **not** edit STATUS.md / MEMORY.md (orchestrator owns).
4. Idempotency: waveId + phase + round + specHash + dispatchId (`references/idempotency.md`).
5. New session **per wave**; same session across review rounds.

Lightweight: tiny doc tweak / no acceptance change → skip stamp. Flash one-shot → no session. Emergency → human + short stamp.

---

## Dispatch dialects (`install-dialects`)

Profiles (role + model family quirks, not prestige):

| Profile | Shape | Typical role |
|---------|-------|--------------|
| `executor-task-done` | Task → Done (paths) → Autonomy | Wave Executor |
| `orchestrator-goal-context` | Goal → Context → Constraints → Done | Orchestrator |
| `auditor-what-where` | What → Where → Readiness (+ discipline) | Cross-auditor |
| `flash-oneshot` | Single call, single output path | Stateless pull |

Install to project:
```
prompts/_dispatch/
├── README.md
├── executor-cheatsheet.md
├── orchestrator-cheatsheet.md
├── auditor-cheatsheet.md
└── flash-cheatsheet.md
```

Sources: `assets/templates/prompts/_dispatch/` and `assets/templates/profiles/`.  
Selection: `references/profile-selection.md`. Anti-patterns: `references/anti-patterns.md`.

---

## Scripts (deterministic gates)

| Script | Purpose |
|--------|---------|
| `scripts/classify_program.sh` | multi-agent vs single-home; domain_novelty hint |
| `scripts/inventory_harness.sh` | CLIs, skill packs, MCP markers (best-effort) |
| `scripts/install_project_os.sh` | materialize templates into target project |
| `scripts/verify_os_gate.sh` | Phase 3 done checks |
| `scripts/verify_l0_inputs.sh` | lists canon files for L0 |
| `scripts/verify_handoff_gate.sh` | handoff/MEMORY/AGENTS separation |
| `scripts/verify_stamp_schema.sh` | required stamp fields |
| `scripts/verify_raeh_ready.sh` | waves/_template + README |
| `scripts/hash_acceptance.sh` | sha256 SPEC+PLAN → acceptance.hash |

All accept `[project_dir]` or path args; support `--help`; exit 0 on pass.

---

## Target project OS (after `full`)

```
<project>/
├── AGENTS.md, SPEC.md, INTENT.md, STATUS.md, plan.md
├── SESSION_HANDOFF.md          # gitignored, append-only
├── CLAUDE.md                   # if Claude in roster
├── .gitignore
├── .agents/memory/MEMORY.md
├── .agents/rules/...
├── prompts/_dispatch/...
├── waves/README.md + _template/ + <date-slug>/
├── audits/{README, <role>/, _legacy/}
├── docs/{access-map,cross-project-map}.md
└── research/<sources>/
```

Program architecture = `SPEC.md`. Wave contracts = `waves/*/SPEC.xml` + `PLAN.xml` via **wave-spec**.

---

## Progressive disclosure (read on demand)

| File | When |
|------|------|
| `references/composition.md` | Boundaries with wave-spec / bootstrap |
| `references/domain-novelty.md` | FIRST / REPEAT / TRANSFER |
| `references/h-panel-rules.md` | Falsifiable Hs |
| `references/harness-beats-model.md` | Inventory-first roles |
| `references/role-matrix.md` | Archetypes + write locks |
| `references/self-assessment-brief.md` | ≥10% roles |
| `references/l0-consistency.md` | L0 checklist |
| `references/cross-audit-protocol.md` | F-04 cost control |
| `references/degraded-modes.md` | 1–2 model modes |
| `references/archive-hygiene.md` | Phase 4 |
| `references/done-definition.md` | K/P/W checks |
| `references/stamp-dialogue.md` | Full stamp card |
| `references/raeh-lifecycle.md` | Wave lifecycle |
| `references/session-policy.md` | Session per wave |
| `references/orca-recipes.md` | Optional Orca |
| `references/idempotency.md` | Dispatch ids |
| `references/metrics.md` | rounds-to-YES |
| `references/profile-selection.md` | Dialect pick |
| `references/anti-patterns.md` | Dispatch fails |

---

## Composition (do not absorb)

| Peer | Relationship |
|------|----------------|
| **wave-spec** | Draft INTENT/SPEC.xml/PLAN.xml; this skill stamps/executes |
| **project-bootstrap** | Single-CLI homes only |
| **zcode-bootstrap** | ZCode native bits; then this skill `extend` |
| **vs-architect** | Optional helper in Phase 0 |
| Domain skills (`/seo`, …) | After OS ready |

Mirror install: keep identical trees at `~/.grok/skills/project-orchestra` and `~/.config/opencode/skills/project-orchestra` (copy; `VERSION` pin 1.0.0). No project-specific hostnames in package.

## Anti-patterns

- H-panel on every REPEAT_DOMAIN project  
- Skip L0 because files “look fine”  
- Chat AGREED without stamp YES  
- Paste full AGENTS/MEMORY into every dispatch  
- Done = “сделай хорошо” without artifact path  
- Executor edits STATUS/MEMORY  
- One eternal multi-wave session  
- Domain residue (site hostnames, CMS-only rules) inside skill package  
