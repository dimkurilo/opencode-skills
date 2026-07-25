# wave-spec

Portable plan-gate skill (vv-method, multi-CLI). INTENT → interview → structured SPEC.xml + PLAN.xml → human approve → worker briefs → STATUS/handoff. Universal: development, content, skill-port, translation, orchestration, site rebuild.

## When to use

Use when starting a sprint/wave, or when multi-session development/content/skill-port/translation work must not skip planning. Works in Grok, Claude Code, OpenCode, ZCode — writes files in the project, does not require vv-opencode runtime.

**Do NOT use** for trivial one-line edits already approved by the user.

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
- `assets/templates/` — INTENT, SPEC, PLAN, STATUS, worker brief templates
