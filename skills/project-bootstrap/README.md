# Project Bootstrap v2 — Agent Infrastructure Generator

🇷🇺 [Русская версия](README.ru.md)

A skill for [opencode](https://github.com/opencode-ai/opencode) agents that bootstraps complete agent infrastructure for projects of any type following the [Agent Playbook](https://agents.md) standard.

**v2** adds Variant E architecture (rules in primacy + recency = inevitable), GRACE semantic anchors for grep-able rule discovery, and adaptive project classification.

## Why this exists

When starting a new project with an AI agent, the first few sessions are spent inventing structure: where to store rules, how to preserve context between sessions, where to put scripts. Project-bootstrap handles this in one session — describe your task as a stream of thought, and get a ready-to-use `.agents/` structure with AGENTS.md, memory, rules, and skills.

The skill is **universal** and **model-adaptive**: works for technical projects (backups, servers, integrations), business projects (marketing digitization), and personal projects (job search, resume building). Adapts templates to the target model (DeepSeek V4, GLM 5+, universal).

## What types of projects it suits

| Project type | Examples | Variant | What it creates |
|-------------|---------|---------|-----------------|
| Ops / Server | Docker, backups, CI/CD, monitoring | `variant-e-full` | Full preamble + checklist + gotchas + failure packet + hierarchy + closing anchors |
| Code | JS/TS/Python, tests, integrations | `variant-e-grace` | Variant E + GRACE anchors in code files |
| Agent | Skills, prompts, model configs | `variant-e-model` | Model-specific closing anchors (DeepSeek/GLM) |
| Content / Business | Articles, analytics, briefs | `lightweight` | Preamble without technical rules |
| Undetermined | <3 files, new project | `base` | Minimal template with upgrade suggestion |

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
| `plan.md` | Strategic plan for humans: phases (no statuses), decisions, blockers |
| `AGENTS.md` | Main manifest: description, architecture, Progressive Context (L1/L2/L3), Closing Anchors |
| `SESSION_HANDOFF.md` | Operational state: current phase, tasks, environment (.gitignore) |
| `.gitignore` | Exclusions for secrets and SESSION_HANDOFF.md |
| `.agents/memory/MEMORY.md` | Long-term memory (append-only): CONFIRMED_FACTS, UNRESOLVED_ISSUES, FAILED_APPROACHES, decisions |
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
- **Agent1st Protocol v30 (DeepSeek)** — CSA citation budget, Closing Anchors, Cascade Breaker, Failure Packet (internal agent protocol)

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
├── SKILL.md                         # Agent instructions (6-phase workflow)
├── README.md / README.ru.md
├── references/
│   ├── playbook.md                  # Agent Playbook specification
│   ├── workflow-patterns.md         # 9 architectural patterns
│   ├── variant-e-structure.md       # Variant E architecture + few-shot examples
│   ├── grace-anchors.md             # GRACE anchor specification + grep commands
│   └── model-profiles.md            # DeepSeek vs GLM vs universal profiles
├── scripts/
│   ├── classify_project.sh          # Auto-detect project type + select variant
│   └── verify-handoff-gate.sh       # Phase 4c: verify handoff-destination rules
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

MIT — part of [opencode-skills](https://github.com/dimkurilo/opencode-skills).
