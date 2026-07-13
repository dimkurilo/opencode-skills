# skill-work-project-creator — Multi-Agent Program OS Kit

🇷🇺 [Русская версия](README.ru.md)

**Bootstrap a multi-CLI, multi-wave program OS for AI agents** — roles, gates, Stamp Dialogue, R.A.E.H. wave lifecycle, dispatch dialects, evidence plane — without rediscovering architecture on every project.

Works with **OpenCode**, **Grok**, and other agent CLIs that load `SKILL.md` packages. Peer of [project-bootstrap](../project-bootstrap/) (single-CLI homes) and **wave-spec** (wave SPEC/PLAN drafting — install separately).

**Version:** 1.0.0 · **Kit id:** multiagent-kit-1.0 · **License:** MIT

---

## Why this exists

Single-agent projects need AGENTS.md and MEMORY. **Multi-agent programs** need more:

- Who orchestrates vs who executes vs who cross-audits?
- How do you prove “AGREED” without chat theater?
- How do waves run without one eternal session?
- How do you avoid an always-on 4-model architecture panel for every SEO/ops project?

This skill packages a proven **Multi-Agent Kit**: harness inventory first, domain-novelty H-panel only on FIRST contact, L0 consistency before G0, file-backed stamps before execute.

## When to use

| Situation | Use this skill? |
|-----------|-----------------|
| New multi-CLI multi-wave program | **Yes** — mode `full` |
| “Who should orchestrate?” / role matrix | **Yes** — `roles-only` |
| Wave review / stamp / execute | **Yes** — `raeh-review` / `raeh-execute` |
| Install dispatch cheatsheets only | **Yes** — `install-dialects` |
| Simple single-CLI agent home | **No** → [project-bootstrap](../project-bootstrap/) |
| Draft wave SPEC.xml / PLAN.xml | **No** → peer **wave-spec** (then stamp here) |
| One-line edit already approved | **No** |

## Modes

| Mode | Scope |
|------|-------|
| `full` | Phases 0→4: discovery → architecture → wire R.A.E.H. → materialize OS → cleanup |
| `roles-only` | Role matrix + program SPEC path |
| `wire-raeh` | Install waves/ stamps without full boot |
| `extend` | Add roles/CLI to existing OS |
| `cleanup` | Archive journey, prune museum AGENTS |
| `raeh-review` | Stamp Dialogue REVIEW |
| `raeh-execute` | EXECUTE only after stamp YES + hash |
| `install-dialects` | `prompts/_dispatch/` cheatsheets |

## What it installs in a project

```
<project>/
├── AGENTS.md, SPEC.md, INTENT.md, STATUS.md, plan.md
├── SESSION_HANDOFF.md          # gitignored, append-only
├── .agents/memory/MEMORY.md
├── prompts/_dispatch/          # executor / orchestrator / auditor / flash
├── waves/README.md + _template/  # REVIEW-STAMP, EXEC-REPORT, STATUS
├── audits/, docs/, research/
└── .gitignore
```

Program architecture stays in **SPEC.md**. Wave contracts (SPEC.xml + PLAN.xml) come from **wave-spec**.

## Core ideas

| Idea | Rule |
|------|------|
| **Harness > model** | Roles from CLI/skills/MCP inventory, not prestige |
| **domain_novelty** | H-panel ON for FIRST, OFF for REPEAT |
| **L0 consistency** | Always before architecture G0 |
| **Stamp Dialogue** | Disk stamp is authority; chat “AGREED” does not count |
| **R.A.E.H.** | Review → Agree → Execute → Handoff; new session per wave |
| **Write locks** | Executor does not edit STATUS/MEMORY |
| **F-04** | Cross-audit with a **different** model family |

## Installation

### OpenCode

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

# symlink (recommended — updates with git pull)
ln -sfn ~/Projects/opencode-skills/skills/skill-work-project-creator \
  ~/.config/opencode/skills/skill-work-project-creator

# or copy
cp -R ~/Projects/opencode-skills/skills/skill-work-project-creator \
  ~/.config/opencode/skills/skill-work-project-creator
```

### Grok

```bash
ln -sfn ~/Projects/opencode-skills/skills/skill-work-project-creator \
  ~/.grok/skills/skill-work-project-creator
```

### Materialize OS into a target project

```bash
bash ~/.config/opencode/skills/skill-work-project-creator/scripts/install_project_os.sh \
  /path/to/project "my-program"

bash ~/.config/opencode/skills/skill-work-project-creator/scripts/verify_os_gate.sh \
  /path/to/project
```

## Usage

Invoke the skill (slash or natural language):

```
/skill-work-project-creator
```

Examples:

- “Bootstrap a multi-agent program OS for this repo”
- “Who should orchestrate — Claude or Grok?”
- “Run R.A.E.H. review on waves/2026-07-13-p1”
- “Install dispatch dialects only”

The agent follows `SKILL.md`: classify → inventory → phases/modes → templates → verify scripts.

## Scripts (gates)

| Script | Purpose |
|--------|---------|
| `classify_program.sh` | multi-agent vs single-home; novelty hint |
| `inventory_harness.sh` | CLIs, skill roots, MCP config markers |
| `install_project_os.sh` | copy templates into project |
| `verify_os_gate.sh` | Phase 3 OS readiness |
| `verify_l0_inputs.sh` | L0 canon file list |
| `verify_handoff_gate.sh` | AGENTS / HANDOFF / MEMORY separation |
| `verify_raeh_ready.sh` | waves/_template present |
| `verify_stamp_schema.sh` | REVIEW-STAMP required fields |
| `hash_acceptance.sh` | sha256(SPEC+PLAN) → acceptance.hash |

All support `--help` and exit 0 on success.

## Skill package structure

```
skill-work-project-creator/
├── SKILL.md                 # Agent entry (modes, phases, gates)
├── VERSION                  # 1.0.0
├── agents/openai.yaml       # UI metadata
├── scripts/                 # 9 gate/install scripts
├── assets/templates/        # OS + waves + dispatch profiles
└── references/              # Progressive disclosure (stamp, R.A.E.H., L0, …)
```

## Composition with other skills

| Skill | Relationship |
|-------|----------------|
| **project-bootstrap** | Single-CLI agent homes only |
| **wave-spec** | Draft INTENT → SPEC.xml → PLAN.xml; this skill stamps/executes |
| **vs-architect** | Optional helper in Phase 0 role debate |
| Domain skills (`/seo`, …) | After OS is ready — not embedded here |

## Anti-patterns

- H-panel on every REPEAT_DOMAIN project  
- Skipping L0 because files “look fine”  
- Chat AGREED without stamp YES  
- Pasting full AGENTS.md into every worker dispatch  
- Executor editing STATUS/MEMORY  
- Domain-specific hostnames inside the skill package  

## License

MIT — see repository root [LICENSE](../../LICENSE).
