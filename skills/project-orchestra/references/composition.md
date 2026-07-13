# Composition — project-orchestra kit

This skill packages the multiagent-kit 1.0 members as **modes**:

| Mode cluster | Kit member | Owns |
|--------------|------------|------|
| full / roles-only / extend / cleanup | project-orchestra | roles, L0, program SPEC, OS tree, archive |
| wire-raeh / raeh-review / raeh-execute | raeh-protocol | Stamp Dialogue, R.A.E.H., wave stamps |
| install-dialects | dispatch-dialects | profiles + `_dispatch` cheatsheets |

## Peers (external — do not reimplement)

| Peer | Boundary |
|------|----------|
| **wave-spec** | INTENT → SPEC.xml → PLAN.xml → human approve → worker briefs |
| **project-bootstrap** | Single-CLI AGENTS/MEMORY/HANDOFF only |
| **zcode-bootstrap** | ZCode native home; then `extend` for multi-agent layer |
| Domain skills | SEO etc. after OS ready |

## Routing

| User intent | Skill/mode |
|-------------|------------|
| New multi-agent program | this skill `full` |
| Simple single-home agent | project-bootstrap |
| Wave SPEC/PLAN draft | wave-spec |
| Stamp / execute wave | `raeh-review` / `raeh-execute` |
| Worker prompt only | `install-dialects` + profiles |

## Version pin

`VERSION` file in skill root = `1.0.0`. Mirrors: `~/.grok/skills/` and `~/.config/opencode/skills/` must match checksum or be copied together.
