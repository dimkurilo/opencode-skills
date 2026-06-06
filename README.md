# opencode-skills

🇷🇺 [Русская версия](README.ru.md)

A collection of skills for [opencode](https://github.com/opencode-ai/opencode) agents.

Each skill is a set of instructions, prompt patterns, and reference materials that teach an AI agent how to perform a specific task effectively. Skills are model-agnostic and work with any LLM backend supported by opencode.

## Skills

| Skill | Description |
|-------|-------------|
| [project-bootstrap](skills/project-bootstrap/) | Agent infrastructure generator following [Agent Playbook](https://agents.md). Two modes: create from scratch and extend existing. DeepSeek optimizations: Closing Anchors, Progressive Context (L1/L2/L3), Anti-Rationalization, Adversarial Verification, Capture step. Creates AGENTS.md, SESSION_HANDOFF.md, MEMORY.md (append-only), rules with Gotchas, skills, agent personas, slash commands. 9 templates, 52 variables, 6 workflow patterns. [Details →](skills/project-bootstrap/README.md) |
| [vs-architect](skills/vs-architect/) | Distribution-level prompting via Verbalized Sampling (arXiv 2510.01171). Generates solution variants with probability estimates for architecture, debugging, strategy, and creative tasks. |

## Installation

### Quick install

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills
ln -sf ~/Projects/opencode-skills/skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
ln -sf ~/Projects/opencode-skills/skills/vs-architect ~/.config/opencode/skills/vs-architect
```

### Manual install

```bash
cp -r skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
cp -r skills/vs-architect ~/.config/opencode/skills/vs-architect
```

After copying, opencode will auto-discover the skill on next launch.

## Repository structure

```
opencode-skills/
├── README.md               # English
├── README.ru.md            # Russian
├── CHANGELOG.md            # Release history
├── LICENSE                 # MIT
├── .gitignore
└── skills/
    ├── project-bootstrap/  # Agent Playbook infrastructure generator (v3)
    │   ├── SKILL.md
    │   ├── README.md / README.ru.md
    │   ├── references/
    │   │   ├── playbook.md
    │   │   └── workflow-patterns.md
    │   └── assets/templates/   # 9 templates
    └── vs-architect/       # Verbalized Sampling prompting
        ├── SKILL.md
        ├── README.md / README.ru.md
        └── references/
            ├── vs-theory.md
            └── examples.md
```

## Creating your own skills

Skills follow a simple convention:

1. Directory named after the skill
2. `SKILL.md` — main instruction file with YAML frontmatter (`name`, `description` — describe WHEN to use, not what it does)
3. Optional `references/` — reference materials, examples, theory
4. Optional `assets/templates/` — generation templates with `${VARIABLE}` placeholders
5. Optional `scripts/` — helper shell/Python scripts

## License

MIT
