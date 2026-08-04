<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/hero-light.svg">
  <img alt="project-bootstrap" src="assets/hero-light.svg" width="100%">
</picture>

# project-bootstrap

🇷🇺 [Русская версия](README.ru.md) · **English** · [← all skills](../../README.md)

**Agent infrastructure for a project, generated in one session.**

Drop a new project (or a messy existing one) in front of an agent with this skill loaded, and it builds the full "home" the agent needs to work in: an `AGENTS.md` contract, handoff and memory files, rules, scripts, `.gitignore` — adapted to the project type and the model you're running.

---

## When to use

- You're starting a new project and want the agent infrastructure right from day one.
- You said something like *"set up the agent structure"*, *"разверни агента"*, *"configure the project"*.
- You're rescuing an existing project where the agent keeps losing context or forgetting decisions.

**Don't use it for** minor edits, audits, or a project that's already configured — the skill has an extension mode for adding pieces to a working setup, not a full rebuild.

## What it generates

```
<project>/
├── AGENTS.md              # the universal contract: preamble rules, protocol, hierarchy
├── SESSION_HANDOFF.md     # what's happening right now (phase, tasks, env) — gitignored
├── .gitignore
├── plan.md                # optional — strategic plan
└── .agents/
    ├── memory/MEMORY.md   # long-term memory: confirmed facts, unresolved issues, rules
    ├── rules/             # reusable rules (general, skill-conventions, release-flow)
    ├── commands/          # /commands the agent can run
    ├── scripts/           # classify, lint, verify, release helpers
    └── skills/            # project-specific skills
```

Every file is adapted to the **project type** (`ops`, `code`, `agent`, `content`) and the **model** (DeepSeek / GLM / Qwen / universal). A content project gets a different rule set than a code project; a Qwen-run project gets model-specific discipline rules.

## How it works

1. **Classify** — `scripts/classify_project.sh` reads the task and figures out the project type + complexity.
2. **Template** — the right `assets/templates/` set is picked (15 templates: `AGENTS.md.tmpl`, `MEMORY.md.tmpl`, `SKILL.md.tmpl`, `rule.md.tmpl`, …).
3. **Generate** — files are written with `${VARIABLE}` placeholders filled from the task.
4. **Contradiction check** — preamble rules vs closing anchors (no rule conflicts).
5. **Double audit** — structure + content verified before claiming done.

The skill is built on **Variant E + GRACE anchors**: the most important rules appear twice — in the preamble (primacy) and in closing anchors (recency) — so the model can't drift away from them in a long session.

## Install

```bash
ln -sfn ~/Projects/opencode-skills/skills/project-bootstrap \
  ~/.config/opencode/skills/project-bootstrap
```

Then tell the agent: *"set up this project for me"* / *"настрой проект"*.

## Example session

> **You:** New project — a content site for a small magazine, running on DeepSeek. Set up the agent structure.
>
> **Agent** *(loads project-bootstrap)*: runs `classify_project.sh` → type=`content`, model=`deepseek` → generates `AGENTS.md` with content-project rules, `SESSION_HANDOFF.md`, `.agents/memory/MEMORY.md`, `.agents/rules/` with content conventions, `classify_project.sh` installed. Contradiction check passes. Reports what was created and why.

## What's inside

- **References:** `model-profiles.md` (DeepSeek/GLM/Qwen behavior + anti-patterns), `playbook.md`, `grace-anchors.md`, `variant-e-structure.md`, `workflow-patterns.md`, `operational-rules.md`.
- **Templates (15):** `AGENTS.md.tmpl`, `MEMORY.md.tmpl`, `SESSION_HANDOFF.md.tmpl`, `SKILL.md.tmpl`, `rule.md.tmpl`, `command.md.tmpl`, `agent-persona.md.tmpl`, `opencode-agent.md.tmpl`, `nda-anonymization.md.tmpl`, `script.sh.tmpl`, `script.py.tmpl`, `plan.md.tmpl`, `general-rule.md.tmpl`, `api-config.example.tmpl`, `YYYY-MM-DD.md.tmpl`.
- **Scripts:** `classify_project.sh`, `verify-handoff-gate.sh`.

## Router

This is the **entry point** of the planning trio:

```
new project → project-bootstrap → (inside it) wave-spec → multi-model-orchestration
```

## License

MIT · part of [opencode-skills](../../README.md)
