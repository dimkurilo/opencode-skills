# Project Bootstrap v2 - agent infrastructure generator

🇷🇺 [Русская версия](README.ru.md)

A skill for [opencode](https://github.com/opencode-ai/opencode): in one session it builds an agent “home” for a project, following the [Agent Playbook](https://agents.md) standard.

**v2** adds Variant E (rules at the start and end of the file so they are harder to skip), GRACE anchors (rules findable with `grep`), and template choice by project type.

## Why it exists

A new project with an AI agent often starts by inventing structure: where rules live, how to keep context across sessions, where scripts go. Project-bootstrap does that in one session - you describe the task as a stream of thought and get a ready `.agents/` tree with AGENTS.md, memory, rules, and skills.

It fits technical work (backups, servers, integrations), business work (marketing digitization), and personal work (job search, resume). Templates adapt to the target model: DeepSeek V4, GLM 5+, universal.

## Project types

| Type | Examples | Variant | What you get |
|------|----------|---------|--------------|
| Ops / server | Docker, backups, CI/CD, monitoring | `variant-e-full` | Full preamble, checklist, gotchas, failure packet, hierarchy, closing anchors |
| Code | JS/TS/Python, tests, integrations | `variant-e-grace` | Variant E and GRACE anchors in files |
| Agent | Skills, prompts, model configs | `variant-e-model` | Closing anchors tuned for DeepSeek or GLM |
| Content / business | Articles, analytics, briefs | `lightweight` | Preamble without technical rules |
| Unclear | fewer than three files, brand-new project | `base` | Minimal template with a nudge to upgrade later |

## Which LLMs it likes

Tuned for **DeepSeek V4** (Pro for main work, Flash for subagents). What that shapes:

- **Closing Anchors** - critical rules at the end of AGENTS.md (DeepSeek V4 recency effect)
- **CSA-aware grouping** - related rules in one section (about 4000 tokens of precise context budget)
- **Progressive Context (Level 1/2/3)** - tiered context, not one flat table
- **Anti-Rationalization** - common agent excuses with rebuttals
- **Adversarial Verification** - critical artifacts checked by a separate agent

Templates are plain Markdown with YAML frontmatter. Backend can be OpenAI, Anthropic, Qwen - DeepSeek is not required.

## What it creates

| Module | Purpose |
|--------|---------|
| `plan.md` | Human-facing plan: phases (no statuses), decisions, blockers |
| `AGENTS.md` | Manifest: description, architecture, Progressive Context (L1/L2/L3), Closing Anchors |
| `SESSION_HANDOFF.md` | Current phase, tasks, environment (gitignored) |
| `.gitignore` | Secrets and SESSION_HANDOFF.md |
| `.agents/memory/MEMORY.md` | Long-term memory (append-only): facts, open issues, failed approaches, decisions |
| `.agents/memory/YYYY-MM-DD.md` | Daily notes (for long-running projects) |
| `.agents/rules/general.md` | Base rules: Anti-Rationalization, Adversarial Verification, Gotchas |
| `.agents/rules/*.md` | Domain rules with frontmatter (`applies_to`, `priority`) |
| `.agents/skills/*/SKILL.md` | Workflow skills with gotchas and verification |
| `.agents/agents/*.md` | Subagent personas (`@role`) |
| `.agents/commands/*.md` | Slash commands (`/command`) |
| `.agents/scripts/` | Shared utilities |
| `readme.md` | Human-readable docs (optional) |

Only what the task needs. No bloat.

## What matters in v3

### Two modes

- **From scratch** - new project
- **Extend** - AGENTS.md already exists: read it, add only new modules

### Capture step

After generation, MEMORY.md records **what** was created and **why**: decisions, rejected alternatives, deferred work. The next session does not guess.

### Data discovery

Before generation, scans the project root (`ls`) and folds existing data folders into the AGENTS.md architecture.

### Workflow patterns catalog

Six architectures (Classify-and-Act, Fan-out-and-Synthesize, Adversarial Verification, Generate-and-Filter, Tournament, Loop Until Done) - a menu for complex skills.

## Inspiration and sources

- **[Agent Playbook v0.0.5](https://github.com/PromptPasture/agent.md)** - `.agents/` structure standard
- **[Cursor Rules](https://cursor.com/docs/rules)** and **[OpenCode Rules](https://opencode.ai/docs/rules/)** - how context loading works in practice
- **[Thariq @ Anthropic](https://x.com/trq212/status/2061907337154367865)** - “A harness for every task”: 6 workflow patterns, adversarial verification, progressive disclosure
- **Vladimir Ivanov [@turboproject](https://t.me/turboproject)** - GRACE, semantic anchors, knowledge graph
- **[vv-opencode (GRACE)](https://github.com/osovv/vv-opencode)** - delegation packet, three-layer spec-to-code, module contracts
- **[AGENTS.md Patterns (Blake Crosley)](https://blakecrosley.com/blog/agents-md-patterns)** - command-first, closure-defined, ~150-line limit
- **Agent1st Protocol v30 (DeepSeek)** - CSA citation budget, Closing Anchors, Cascade Breaker, Failure Packet (internal agent protocol)

## Installation

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills
ln -sf ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
```

## Usage

Describe the task in any form (stream of thought, file link, voice note) and say “create structure” or “bootstrap”. The skill picks the project type and builds the matching files.

## Skill layout

```
project-bootstrap/
├── SKILL.md                         # Agent instructions (6-phase workflow)
├── README.md / README.ru.md
├── references/
│   ├── playbook.md                  # Agent Playbook specification
│   ├── workflow-patterns.md         # 9 architectural patterns
│   ├── variant-e-structure.md       # Variant E + few-shot examples
│   ├── grace-anchors.md             # GRACE anchors + grep commands
│   └── model-profiles.md            # DeepSeek, GLM, universal
├── scripts/
│   ├── classify_project.sh          # Project type + variant
│   └── verify-handoff-gate.sh       # Phase 4c: handoff-destination
└── assets/templates/                # 15 generation templates
    ├── plan.md.tmpl
    ├── AGENTS.md.tmpl               # Variant E: preamble + closing anchors
    ├── SESSION_HANDOFF.md.tmpl
    ├── MEMORY.md.tmpl
    ├── general-rule.md.tmpl
    ├── rule.md.tmpl
    ├── SKILL.md.tmpl
    ├── command.md.tmpl
    ├── agent-persona.md.tmpl
    ├── opencode-agent.md.tmpl
    ├── nda-anonymization.md.tmpl
    ├── script.py.tmpl
    ├── script.sh.tmpl
    ├── api-config.example.tmpl
    └── YYYY-MM-DD.md.tmpl
```

## License

MIT - part of [opencode-skills](https://github.com/dimkurilo/opencode-skills).
