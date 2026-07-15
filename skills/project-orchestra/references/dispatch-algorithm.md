# Dispatch algorithm - role × model family × prompt shape

**Mandatory** whenever the orchestrator sends work to a worker (Orca terminal, subagent, or paste).  
Not optional polish. Default shape per family; measure results — kit heuristics for non-GPT families.

Official GPT-5.6 SoT (lean contracts, outcome-first, API for effort):  
[Prompting guidance for GPT-5.6 Sol](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6)

Skeletons: `model-prompt-shapes.md` (skill) / installed `model-shapes.md`. Role pick: `profile-selection.md`. Iron: `dispatch-iron.md`. Orca transport: `orca-recipes.md`.

---

## Algorithm (run in order)

```
1. ROLE     → profile (executor | orchestrator | auditor | flash)
2. FAMILY   → DeepSeek | GLM | Grok | GPT-5.6 | other
3. SHAPE    → skeleton from model-prompt-shapes / model-shapes for that family
4. PIN      → CLI + agent (if any) + model id + effort/thinking (API/harness, not prose)
5. WRITE    → brief file under waves/<id>/prompts/ or prompts/_dispatch/
6. SEND     → Orca terminal / worker (wait TUI ready; one primary output path)
7. GATE     → identity: header has role + family + shape name
```

If step 2 or 3 is skipped → **invalid dispatch** (do not claim dual-review).

---

## Step 1 - Role → profile

| Job | Profile |
|-----|---------|
| Implement plan scope | `executor-task-done` |
| Plan / coordinate | `orchestrator-goal-context` |
| Checklist / evidence audit | `auditor-what-where` |
| One-shot pull | `flash-oneshot` |

---

## Step 2 - Family → shape name

| Family | Shape id | Carry blocks |
|--------|----------|--------------|
| DeepSeek V4 | `shape:deepseek-what-where-done` | what / where / done |
| GLM 5.2 | `shape:glm-goal-context-done` | Goal → Context → Constraints → Done |
| Grok 4.5 | `shape:grok-task-done` | Task + Done (+ Autonomy) |
| **GPT-5.6** (Sol / Terra / Luna) | `shape:gpt56-goal-success-stop` | **Goal + Success + Stop** (lean) |
| Unknown | `shape:lean-goal-success` | Goal + Success only; no thick process |

**Dual-review:** two workers → **two different families** (and thus two shapes), not two clones of the same brief.

---

## Step 3 - Fill shape (rules by family)

### All families

- One primary **output path**
- Done/Success = path or command, not vibes
- No full AGENTS/MEMORY dump

### GPT-5.6 extra (from OpenAI guidance)

**Do:**

- Outcome-first Goal; Success = acceptance + validation  
- Stop rules (answer / ask smallest field / retry)  
- Compact autonomy (local ok / external ask)  
- One instruction once; strip repeated process scaffolding  
- Thinking / verbosity / pro mode via **API** (`reasoning.effort`, `text.verbosity`), not “think harder” in text  

**Do not:**

- DeepSeek `【】` blocks  
- “Think step by step” / “use pro mode” as prose  
- “Be concise” as the only length control (use verbosity API + preserve/trim)  
- Thick tool-by-tool micro-scripts when path is free  
- Same prompt text as the other dual worker  

**Effort (directional):** low = latency; medium = default; high/xhigh = only if evals show gain.  
Terra / Sol / Luna = product/model variant - still use `shape:gpt56-goal-success-stop`.

---

## Step 4 - Brief file header (required)

```markdown
<!-- dispatch
role: auditor
profile: auditor-what-where
family: gpt-5.6
shape: gpt56-goal-success-stop
cli: codex|opencode|…
model: gpt-5.6-terra
effort: high
output: audits/…/REVIEW.md
-->
```

Then the filled skeleton for that shape.

---

## Step 5 - Where this hooks in project-orchestra

| Mode / phase | Hook |
|--------------|------|
| Intake Q3 | Capture multi vs one family; note default roster |
| Phase 0 role matrix | Each role row: CLI + family + default shape id |
| Phase 2 / install-dialects | Ship `prompts/_dispatch/model-shapes.md` + cheatsheets |
| Dual-review / F-04 | Algorithm steps 1–7 for **each** worker |
| raeh-execute | Executor brief uses executor profile + executor family shape |
| raeh-review | Reviewer brief uses auditor/orchestrator shape of **reviewer** family |

---

## Anti-patterns

| Bad | Why |
|-----|-----|
| Role profile only, ignore family | GLM gets Grok Task-shape → weak |
| GPT-5.6 + thick process dump | OpenAI: scores down, tokens up |
| Dual workers, same shape text | Fake dual |
| Effort in prose only | Wrong control surface |

---

## Quick copy: GPT-5.6 worker

```markdown
### Goal
[verb + user-visible outcome]

### Success
- Acceptance: […]
- Validation: [test/curl/lint or why skip]

### Context
- Files: [`path`]
- Now: […]
- Evidence: [known / missing]

### Constraints
- Invariants: […]
- Do not touch: […]

### Autonomy
- Without ask: local read/edit/non-destructive tests
- Ask if: external write / destructive / scope expand

### Output
- Write: `path/to/artifact`

### Stop
- Answer when: core request + enough evidence
- Ask when: one smallest missing field
```

Source: OpenAI GPT-5.6 Sol prompting guidance + `model-prompt-shapes.md`.
