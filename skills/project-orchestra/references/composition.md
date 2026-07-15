# Composition — project-orchestra kit 1.1

This skill is the **one door** for multi-agent program OS, workstreams, waves, and R.A.E.H.  
It packages kit members as **modes** (not separate skill names).

| Mode cluster | Kit member | Owns |
|--------------|------------|------|
| full / extend | project-orchestra | roles, L0, program SPEC, OS tree, archive |
| workstream-new | monorepo scaffold | parent → workstream write locks, STATUS + waves/ |
| wave | wave draft router | peer-call wave-spec **or** in-package templates |
| bootstrap-lite | minimal home | exactly 4 files |
| raeh-review / raeh-execute | raeh-protocol | Stamp Dialogue, R.A.E.H., wave stamps |
| install-dialects | dispatch-dialects | profiles + `_dispatch` cheatsheets |

## Peers (external — do not reimplement / do not absorb in 1.1)

| Peer | Boundary |
|------|----------|
| **wave-spec** | INTENT → SPEC → PLAN → human approve → worker briefs |
| **project-bootstrap** | Full Variant-E single-CLI homes (this skill has `bootstrap-lite` for 4-file minimum) |
| **zcode-bootstrap** | ZCode native home; then `extend` for multi-agent layer |
| Domain skills | SEO etc. after OS ready — never hostnames in this package |

### wave-spec peer-call contract (not weasel)

| Situation | Action |
|-----------|--------|
| wave-spec skill **installed** (skill root exists under grok/opencode/project skills) | **Peer-call**: load and follow wave-spec for draft. Do not reimplement its interview/XML pipeline. After draft → return to `raeh-review`. |
| wave-spec **not** installed | Use **in-package templates**: `WAVE_BRIEF.md.tmpl`, `waves/_template/PLAN.md.tmpl`, stamp/exec templates. MD preferred when no wave-spec. |
| Soft-invoke without loading | **Forbidden.** Either peer-call for real or template for real. Document which path was used in wave STATUS. |

### MD = XML policy

| Artifact | Formats |
|----------|---------|
| Wave SPEC | `SPEC.xml` **or** `SPEC.md` |
| Wave PLAN | `PLAN.xml` **or** `PLAN.md` |
| Hash | `hash_acceptance.sh` accepts either pair |
| Prefer | Format already present in the wave dir; do not convert without need |

Full absorb / EOL of wave-spec is **out of 1.1** (metrics-driven in 1.3).

## Routing

| User intent | Skill/mode |
|-------------|------------|
| New multi-agent program | this skill `full` |
| Monorepo theme / workstream folder | this skill `workstream-new` |
| Wave SPEC/PLAN draft | this skill `wave` (peer wave-spec **or** templates) |
| Minimal 4-file agent home | this skill `bootstrap-lite` |
| Full Variant-E single-home (rules, commands, personas) | peer **project-bootstrap** |
| Stamp / execute wave | `raeh-review` / `raeh-execute` |
| Worker prompt only | `install-dialects` + profiles |
| Ambiguous workstream vs wave | **one** clarifying question |

## Version pin

`VERSION` file in skill root = `1.1.0`. Mirrors: `~/.grok/skills/` and `~/.config/opencode/skills/` should be the same tree (symlink recommended).
