# Project Bootstrap — Agent Infrastructure Generator

🇷🇺 [Русская версия](README.ru.md)

A skill for [opencode](https://github.com/opencode-ai/opencode) agents that bootstraps complete agent infrastructure for projects of any type following the [Agent Playbook](https://agents.md) standard (v0.0.5).

## Why this exists

When starting a new project with an AI agent, the first few sessions are spent inventing structure: where to store rules, how to preserve context between sessions, where to put scripts. Project-bootstrap handles this in one session — describe your task as a stream of thought, and get a ready-to-use `.agents/` structure with AGENTS.md, memory, rules, and skills.

The skill is **universal**: works for technical projects (backups, servers, integrations), business projects (marketing digitization), and personal projects (job search, resume building, market analysis).

## What types of projects it suits

| Project type | Examples | What it creates |
|-------------|---------|-----------------|
| Technical | Server backups, CI/CD, monitoring | AGENTS.md, procedure rules, skills with scripts, commands |
| Business | Marketing digitization, CRM integration | AGENTS.md, MEMORY.md with resources, process rules, agent roles |
| Personal | Job search, resume, market analysis | AGENTS.md + profile, formatting rules, assistant agents |

## Which LLMs it works best with

The skill is optimized for **DeepSeek V4** (Pro for main work, Flash for subagents). DeepSeek-specific features:

- **Closing Anchors** — critical rules placed at the end of AGENTS.md (DeepSeek V4 recency effect)
- **CSA-aware grouping** — related rules grouped in one section (~4000 token precise context budget)
- **Progressive Context (Level 1/2/3)** — tiered context instead of flat table
- **Anti-Rationalization** — table of common agent excuses with rebuttals
- **Adversarial Verification** — critical artifacts checked by a separate agent

The skill is **model-agnostic**: all templates and rules use standard Markdown with YAML frontmatter, works with any LLM backend (OpenAI, Anthropic, Qwen).

## What it creates

| Module | Purpose |
|--------|---------|
| `AGENTS.md` | Main manifest: description, architecture, Progressive Context (L1/L2/L3), Closing Anchors |
| `SESSION_HANDOFF.md` | Dynamic cross-session context (.gitignore) |
| `.gitignore` | Exclusions for secrets and SESSION_HANDOFF.md |
| `.agents/memory/MEMORY.md` | Persistent memory (append-only) with sources |
| `.agents/memory/YYYY-MM-DD.md` | Daily notes (for long-term projects) |
| `.agents/rules/general.md` | Base rules: Anti-Rationalization, Adversarial Verification, Gotchas |
| `.agents/rules/*.md` | Domain rules with frontmatter (applies_to, priority) |
| `.agents/skills/*/SKILL.md` | Workflow skills with gotchas and verification |
| `.agents/agents/*.md` | Subagent personas (@role) |
| `.agents/commands/*.md` | Slash commands (/command) |
| `.agents/scripts/` | Shared utilities |
| `readme.md` | Human-readable documentation (optional) |

**Key principle:** creates only what the task actually requires. No bloat.

## Key features (v3)

### Two operation modes
- **Create from scratch** — for new projects
- **Extend** — if AGENTS.md already exists, reads it and adds only new modules

### Capture step
After generation, records not just WHAT was created but WHY: decisions made, rejected alternatives, deferred tasks. Critical for the next session.

### Data discovery
Before generation, scans the project root (`ls`) and includes existing data folders in the AGENTS.md architecture.

### Workflow patterns catalog
6 architectural patterns (Classify-and-Act, Fan-out-and-Synthesize, Adversarial Verification, Generate-and-Filter, Tournament, Loop Until Done) — helps choose the right architecture for complex skills.

## Inspiration & sources

- **[Agent Playbook v0.0.5](https://github.com/PromptPasture/agent.md)** — `.agents/` structure standard
- **[Cursor Rules](https://cursor.com/docs/rules)** & **[OpenCode Rules](https://opencode.ai/docs/rules/)** — context loading best practices
- **[Thariq @ Anthropic](https://x.com/trq212/status/2061907337154367865)** — "A harness for every task" — 6 workflow patterns, adversarial verification, progressive disclosure
- **Vladimir Ivanov [@turboproject](https://t.me/turboproject)** — GRACE approach popularization, semantic anchors, knowledge graph
- **[vv-opencode (GRACE)](https://github.com/osovv/vv-opencode)** — delegation packet convention, three-layer spec-to-code, module contracts
- **[AGENTS.md Patterns (Blake Crosley)](https://blakecrosley.com/blog/agents-md-patterns)** — command-first, closure-defined, 150-line limit
- **[Agent1st Protocol v30 (DeepSeek)](https://agents.md)** — CSA citation budget, Closing Anchors, Cascade Breaker, Failure Packet

## Installation

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills
ln -sf ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
```

## Usage

Describe your task in any format (stream of thought, file link, voice note) and say "create structure" or "bootstrap". The skill auto-detects project type and creates the right infrastructure.

## Skill structure

```
project-bootstrap/
├── SKILL.md                         # Agent instructions
├── references/
│   ├── playbook.md                  # Agent Playbook v0.0.5 specification
│   └── workflow-patterns.md         # 6 architectural patterns catalog
└── assets/templates/
    ├── AGENTS.md.tmpl               # Manifest template (Closing Anchors + L1/L2/L3)
    ├── SESSION_HANDOFF.md.tmpl      # Cross-session context
    ├── MEMORY.md.tmpl               # Persistent memory (append-only)
    ├── general-rule.md.tmpl         # Base rules + Anti-Rationalization
    ├── rule.md.tmpl                 # Domain rules + Gotchas
    ├── SKILL.md.tmpl                # Skill template
    ├── command.md.tmpl              # Slash commands
    ├── agent-persona.md.tmpl        # Subagents
    └── YYYY-MM-DD.md.tmpl          # Daily notes
```

## License

MIT — part of [opencode-skills](https://github.com/dimkurilo/opencode-skills).
