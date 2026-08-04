<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/hero-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="docs/assets/hero-light.svg">
  <img alt="opencode-skills" src="docs/assets/hero-light.svg" width="100%">
</picture>

# opencode-skills

🇷🇺 [Русская версия](README.ru.md) · **English**

**Skills that turn an AI agent into a specialist for a concrete job — not a chat partner.**

Each skill is a pack of instructions, templates, scripts, and reference material that drops into [opencode](https://github.com/opencode-ai/opencode) (or any compatible CLI) and tells the agent exactly how to do one thing well: bootstrap a project, run a planned sprint, coordinate multiple models, or break out of a mode-collapsed loop.

No runtime. No lock-in. Just files the agent reads on demand.

---

## The four skills

| Skill | One-liner | Use when |
|-------|-----------|----------|
| [**project-bootstrap**](skills/project-bootstrap/) | Generates the agent "home" for a project in one session — `AGENTS.md`, handoff, memory, rules, adapted to project type and model. | You're starting a new project or rescuing an existing one and want the agent infrastructure right. |
| [**wave-spec**](skills/wave-spec/) | A plan-gate skill for sprints and waves: `INTENT → interview → SPEC/PLAN → approve → dispatch → lifecycle gates`. Portable across OpenCode, ZCode, Qwen Code. | You're running a multi-session sprint, a content/translation wave, or any work that must not skip planning. |
| [**multi-model-orchestration**](skills/multi-model-orchestration/) | Coordinates 2+ AI models (DeepSeek V4 Flash, Qwen 3.8 Max, GLM 5.2, GPT-5.5) for parallel review, cross-validation, or bulk work via Orca. | You need independent perspectives, a fidelity port, or a security/RLS review that one model alone can't gate. |
| [**vs-architect**](skills/vs-architect/) | Verbalized Sampling ([arXiv 2510.01171](https://arxiv.org/abs/2510.01171)) — generates diverse solution variants with probability estimates. | You're choosing between approaches, debugging an unknown root cause, or breaking out of a mode-collapsed loop. |

### Which skill when?

```
New project, "set up the agent structure"          →  project-bootstrap
Sprint/wave that must not skip planning            →  wave-spec
2+ models for review, cross-validation, bulk work  →  multi-model-orchestration
Diverse variants with probabilities                →  vs-architect
```

The three planning skills chain: **project-bootstrap** sets up the agent home → **wave-spec** runs the sprint inside it → **multi-model-orchestration** cross-reviews the work. **vs-architect** is a standalone thinking tool.

---

## Install

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

# symlink the skills you want into opencode
for skill in project-bootstrap wave-spec multi-model-orchestration vs-architect; do
  ln -sfn ~/Projects/opencode-skills/skills/$skill ~/.config/opencode/skills/$skill
done
```

Manual install (no symlinks): `cp -R skills/<name> ~/.config/opencode/skills/<name>`. opencode picks up new skills on the next launch.

Several skills also install into **Grok** (`~/.grok/skills/`) and other CLIs that follow the same `SKILL.md` convention.

---

## What's actually in a skill

```
skills/<name>/
├── SKILL.md                # main instructions + YAML frontmatter (name, description)
├── README.md / README.ru.md
├── references/             # reference material, examples, theory
├── assets/templates/       # generation templates with ${VARIABLE} placeholders
└── scripts/                # helper shell/Python scripts (lint, verify, classify)
```

The frontmatter `description` tells the host agent **when** to load the skill. The body is the workflow. References are loaded on demand. Templates produce the artifacts (`SPEC.xml`, `PLAN.xml`, `AGENTS.md`, briefs, handoffs) the skill generates.

---

## Creating your own skills

Same convention: a directory under `skills/`, a `SKILL.md` with frontmatter (`name`, `description` — describe **when** to use, not only what), optional `references/`, `assets/templates/`, `scripts/`. The `skill-creator` and `skill-audit` skills (in `~/.config/opencode/skills/`) help you write and review them.

---

## Repository

```
opencode-skills/
├── README.md / README.ru.md
├── CHANGELOG.md
├── LICENSE                 # MIT
└── skills/
    ├── project-bootstrap/
    ├── wave-spec/
    ├── multi-model-orchestration/
    └── vs-architect/
```

Public, MIT-licensed. Inspired by [PromptPasture/agent.md](https://github.com/PromptPasture/agent.md), [Cursor Rules](https://cursor.com/docs/rules), [OpenCode Rules](https://opencode.ai/docs/rules/), [vv-opencode](https://github.com/osovv/vv-opencode), and the [Agent1st Protocol](https://github.com/dimkurilo/agent1st-protocols).

## License

MIT
