# Monorepo workstreams — parent vs theme

## Mental model

```
<parent>/                    ← one product / site / program root
  AGENTS.md                  ← program rules (orchestrator)
  SESSION_HANDOFF.md         ← ONE append-only handoff for the parent
  .agents/memory/MEMORY.md   ← ONE long-term memory for the parent
  SPEC.md / STATUS.md        ← program architecture + status
  waves/                     ← optional parent-level waves
  <workstream-slug>/         ← theme of work (optimize, audit, landing, CRM, …)
    STATUS.md
    README.md
    INTENT.md
    waves/
      _template/
      <date-slug>/           ← one wave = plan → stamp → execute → report
```

**One parent HANDOFF / MEMORY.** Workstreams do **not** get their own SESSION_HANDOFF.md unless the workstream is promoted to a separate root (see below).

## When to create a workstream

| Signal | Action |
|--------|--------|
| Same product, different theme of multi-session work | `workstream-new` under parent |
| New product / unrelated codebase | New parent root (`full` or `bootstrap-lite`) |
| One-shot task, no multi-wave | No workstream — task on parent or flash |

## Install

```bash
bash "$SKILL_DIR/scripts/install_workstream.sh" "$PARENT_DIR" "<slug>"
```

Creates `$PARENT_DIR/<slug>/STATUS.md`, `README.md`, `INTENT.md`, `waves/_template/` (+ PLAN.md.tmpl).

## Write locks

| Artifact | Writer | Readers |
|----------|--------|---------|
| Parent `AGENTS.md` / `SPEC.md` | Orchestrator (human or agent) | All |
| Parent `SESSION_HANDOFF.md` | Orchestrator only (append) | All agents starting session |
| Parent `MEMORY.md` | Orchestrator only (append facts) | All |
| Parent `STATUS.md` | Orchestrator | All |
| Workstream `STATUS.md` | Orchestrator (or workstream owner role if declared) | Executors |
| Wave `SPEC` / `PLAN` | Drafter (wave mode / wave-spec) until stamp | Reviewers |
| Wave `REVIEW-STAMP.md` | Reviewer session | Executors |
| Wave `EXEC-REPORT.md` | **Executor** | Orchestrator |
| Wave `STATUS.md` | Orchestrator (or reviewer for state) | All |

**Executor must not** edit parent STATUS, MEMORY, HANDOFF, or AGENTS.

## Separate root — when OK

Create a **new parent root** (not a workstream) when:

1. Different product / customer / deploy target with its own secrets and access map.
2. Hard isolation required (compliance, different git remote).
3. Parent OS does not exist and the theme is the entire program.

Otherwise prefer **workstream under parent**.

## Session start (monorepo)

Diet ≤5 files:

1. Parent `SESSION_HANDOFF.md` (last block)
2. Parent `STATUS.md` (or active workstream `STATUS.md` if CURRENT_FOCUS is that slug)
3. Parent `.agents/memory/MEMORY.md`
4. Optional: active wave dir pointer / SPEC
5. Optional: workstream `INTENT.md`

## Anti-patterns

- Second HANDOFF inside every workstream  
- Workstream re-running full Phase 0 H-panel on REPEAT domain without novelty  
- Executor updating parent MEMORY after a wave  
- Nested workstreams more than one level deep without explicit human design  
