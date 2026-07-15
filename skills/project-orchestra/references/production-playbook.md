# Production playbook — universal loop

File-first. Chat is transport, not authority.

## Universal loop

```
1. INTENT (parent or workstream)
2. PLAN wave          → mode wave (peer wave-spec OR templates)
3. DISPATCH PREP      → for each worker: role × family × prompt shape
                        (references/dispatch-algorithm.md)
                        GPT-5.6 = Goal+Success+Stop lean
4. DUAL-REVIEW        → when gate table requires (two families, two shapes)
5. STAMP              → raeh-review → REVIEW-STAMP.md (same reviewer session, rounds 1..N)
6. HASH               → hash_acceptance.sh → real 64-hex on stamp
7. PRE-EXECUTE GATE   → verify_stamp_schema.sh + verify_stamp_hash.sh (paths named in stamp)
8. NEW SESSION        → raeh-execute (fresh executor session; brief via same algorithm)
9. EVIDENCE           → EXEC-REPORT.md + paths
10. HANDOFF           → append parent SESSION_HANDOFF; orchestrator updates STATUS/MEMORY
```

Lightweight exceptions: tiny doc tweak with no acceptance change → skip stamp.  
Emergency: human + short stamp. Flash one-shot: no multi-session.

## Dual-review gate table

| Situation | Dual-review required? | Who | Mark if single family |
|-----------|----------------------|-----|------------------------|
| High-stakes wave (prod mutate, money, public ship) | **YES** | Two different model families | `DEGRADED_DUAL` |
| Skill/package description or gate-critical docs before release | **YES** | F-04 ledger family + complementary stress family | `DEGRADED_DUAL` |
| L0 CONTRADICTIONS on program architecture | **YES** (on conflict claims) | 2-family minimum | `DEGRADED_DUAL` |
| FIRST_IN_PORTFOLIO high-stakes H-panel synthesis | **YES** after synthesis | Different family F-04 | `DEGRADED_DUAL` |
| Routine REPEAT_DOMAIN wave, low blast radius | Optional | Prefer dual if cheap | optional note |
| Tiny doc / no acceptance change | No | — | — |
| Human explicitly waives dual | No (log waiver) | — | `HUMAN_WAIVED_DUAL` |

### Complementary roles (not two clones)

| Lane | Job |
|------|-----|
| **F-04 / ledger** | Claims vs evidence; checklist completeness; “did we prove it?” |
| **Stress / adversarial** | Failure modes; missing gates; “what breaks if we ship?” |

Do not run two identical “please review” prompts. See `dispatch-iron.md`.

### DEGRADED_DUAL

When only one model family is available:

1. Still produce the review artifact under `audits/` or wave dir.
2. Header must include: `DEGRADED_DUAL: true` and reason (no second family / cost / outage).
3. Do **not** claim dual-review PASS in STATUS.
4. Prefer human skim before EXECUTE on high-stakes rows above.

Also listed in `degraded-modes.md`.

## bootstrap-lite (exactly 4 files)

When full OS is not needed:

| # | File |
|---|------|
| 1 | `AGENTS.md` |
| 2 | `SESSION_HANDOFF.md` |
| 3 | `.agents/memory/MEMORY.md` |
| 4 | `.gitignore` |

```bash
bash "$SKILL_DIR/scripts/install_bootstrap_lite.sh" "$PROJECT_DIR" "$PROJECT_NAME"
```

Do **not** call `install_project_os.sh` for lite (that installs full OS).  
No SPEC/waves/prompts unless user upgrades (`full` / `extend`).

## Orca parallel (truth, not myth)

| Do | Do not |
|----|--------|
| `orca terminal create` ×2 with different agent/model pins | Two parallel bare `opencode run` (shared DB lock) |
| File-first: workers write paths; coordinator reads stamp/reports | Subject line “AGREED” without reading stamp file |
| task/dispatch with identity gate | Anonymous dual workers with no pin |

Full recipes: `orca-recipes.md`. Iron rules: `dispatch-iron.md`.

## Done = artifacts + verify, not vibes

- Acceptance criteria checked (checkbox or script)
- Evidence paths in EXEC-REPORT
- For skill releases: `1.1_VERIFY.md` (or equivalent) with command outputs
- STATUS updated by orchestrator only

## MD = XML

SPEC/PLAN as `.md` or `.xml` are equal for stamp and `hash_acceptance.sh`.
