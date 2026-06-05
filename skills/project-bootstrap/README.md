# Project Bootstrap — Agent Playbook Infrastructure Generator

🇷🇺 [Русская версия](README.ru.md)

A skill for [opencode](https://github.com/opencode-ai/opencode) agents that bootstraps a complete agent infrastructure for new projects following the [Agent Playbook](https://agents.md) standard (v0.0.5).

## What is Agent Playbook?

Agent Playbook is a standard for organizing AI agent infrastructure in software projects. It defines a consistent structure of `.agents/` directory with modular rules, skills, commands, agent personas, and persistent memory — so agents can work effectively across sessions without losing context.

## What does this skill do?

When you describe a new project (in any form — free text, spec link, voice transcript), this skill:

1. **Analyzes** the task for "dark spots" — searches the web for current CLI syntax, API docs, and best practices
2. **Checks existing projects** — finds and reuses relevant context from your other `.agents/` setups
3. **Generates the infrastructure** — creates exactly what the project needs:

| Module | What it creates |
|--------|----------------|
| `AGENTS.md` | Main manifest with project description, architecture tree, Loaded Context table, critical rules |
| `.agents/memory/MEMORY.md` | Persistent memory: CONFIRMED_FACTS, tools, limitations, anti-patterns |
| `.agents/rules/general.md` | Base rules: language, verification, no hallucinations, failure handling |
| `.agents/rules/*.md` | Domain-specific rules (if the task has repeatable operations) |
| `.agents/agents/*.md` | Subagent personas (if the task has distinct roles) |
| `.agents/commands/*.md` | Slash commands (if the task has repeatable commands) |
| `.agents/skills/*/` | Multi-step workflows with SKILL.md + WORKFLOW.md + scripts |
| `docs/` | Formal specs (if the user provided a PRD/spec) |

**Key principle:** creates only what the task actually requires. No bloat.

## When to use

- Starting a new project and want agent infrastructure from day one
- Applying Agent Playbook standard to an existing project
- You have a loose task description and want it turned into a structured agent-ready project
- User says: "создай структуру", "разверни агента", "настрой проект", "bootstrap"

## When NOT to use

- Small edits or fixes within an already-configured project
- Auditing existing infrastructure
- Tasks that don't involve creating new project structure

## What results to expect

- A complete `.agents/` directory tree with all relevant modules
- `AGENTS.md` at the project root with Loaded Context table
- CLI syntax, API endpoints, and best practices fetched from the web and stored in memory
- Reused context from your other projects (SSH configs, known pitfalls, working procedures)
- No passwords, tokens, or secrets — ever

## Installation

```bash
# Clone the skills repo
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

# Symlink into your opencode config
ln -sf ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
```

Or copy the folder:

```bash
cp -r ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
```

## Usage

Once installed, the opencode agent will automatically discover the skill and offer to load it when you describe a new project or say "создай структуру", "разверни агента", etc.

## Decision Framework

The skill applies this logic when analyzing tasks:

| Situation | Solution | Example |
|-----------|----------|---------|
| Frequent/secured operation | MCP (mentioned in AGENTS.md) | Confluence, Jira, GitHub API |
| Rare/complex operation | CLI command (in commands/) | `gh pr create`, `aws s3 sync` |
| CLI + MCP chain | Script in `skills/*/scripts/` | yt-dlp → metadata → S3 |
| Repeatable workflow | Skill with WORKFLOW.md | "server backup" = 5 steps |

## Repository structure

```
project-bootstrap/
├── SKILL.md                    # Agent instructions (loaded by opencode)
├── README.md                   # This file — human-readable description
├── README.ru.md                # Russian version
├── references/
│   └── playbook.md             # Agent Playbook v0.0.5 condensed reference
└── assets/
    └── templates/
        ├── AGENTS.md.tmpl       # Main manifest template
        ├── MEMORY.md.tmpl       # Persistent memory template
        ├── general-rule.md.tmpl # Base rules template
        ├── rule.md.tmpl         # Domain rule template
        ├── agent-persona.md.tmpl # Subagent persona template
        └── command.md.tmpl      # Slash command template
```

## License

MIT — part of [opencode-skills](https://github.com/dimkurilo/opencode-skills).
