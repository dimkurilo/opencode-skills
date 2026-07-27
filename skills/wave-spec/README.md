# wave-spec

Portable plan-gate skill (vv-method, multi-CLI). INTENT → interview → structured SPEC.xml + PLAN.xml → human approve → worker briefs → LAUNCH.md → STATUS/handoff → NEXT_SESSION. Universal: development, content, skill-port, translation, orchestration, site rebuild.

## When to use

Use when starting a sprint/wave, or when multi-session development/content/skill-port/translation work must not skip planning. Works in Grok, Claude Code, OpenCode, ZCode, Qwen Code — writes files in the project, does not require vv-opencode runtime.

**Do NOT use** for trivial one-line edits already approved by the user.

## Key features (v1.4)

- **LAUNCH.md auto-generation (step 6b):** worker launch commands from model-card.md + PLAN.xml roles, cross-family check (writer.family ≠ reviewer.family), per-model review brief templates (DeepSeek, GLM, Codex/GPT, Qwen Code), prohibitions section, versioning on role change
- **NEXT_SESSION pattern (step 6c):** unique files `NEXT_SESSION_I{N}.md` per iteration (never overwrite), copy-paste block with full path (format by orchestrator model), root pointer `NEXT_SESSION.md`, 10 iteration-specific sections (no SKILL.md duplication)
- **Iteration handoff (step 7):** unique per-iteration files `iterations/I{N}-<slug>.handoff.md`, root SESSION_HANDOFF.md as pointer only
- **Linear workflow generation (step 6d):** parametric `.agents/rules/linear-workflow.md` from wave parameters, APPEND on new wave in same project
- **Linear validation checklist:** project, parent, title format, Russian language, checklists, status flow
- **PLAN.xml `<roles>`:** orchestrator + executors with tool/agent/flags/effort/family + `<family_rule>`
- **Cross-family validation:** writer.family ≠ reviewer.family enforced in LAUNCH.md and anti-patterns
- **Post-mortem → skill update:** closeout checklist includes creating INTENT.md for skill improvements

## SoT + Symlink Layout

**Source of Truth (SoT):** `<repo>/skills/wave-spec/` — git-tracked.

**Host symlinks** (replace real dirs with `ln -s` to SoT):

- `~/.grok/skills/wave-spec` → `<repo>/skills/wave-spec`
- `~/.config/opencode/skills/wave-spec` → `<repo>/skills/wave-spec`
- `~/.claude/skills/wave-spec` → `<repo>/skills/wave-spec`

## Lifecycle (one-liner)

Implement done → In Review (dual review) → Commit → PR → Merge → Deploy probe (curl ≠ 404) → On prod (owner smoke OR RESIDUAL-RISK-OWNER-SMOKE) → Done. No "NEXT product" handoff until Deploy gate passed.

## References

- `references/program-maps.md` — domain-specific program maps (4 menus: skill-port, translation, fidelity port, SEO)
- `references/vv-portability.md` — mapping to vv-opencode tags
- `assets/templates/` — INTENT, SPEC, PLAN, STATUS, worker brief, review synthesis, fix-round, ASSUMPTIONS, **LAUNCH.md**, **iteration-handoff.md**, **NEXT_SESSION.md**, **linear-workflow.md**
