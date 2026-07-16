# opencode-skills

🇷🇺 [Русская версия](README.ru.md)

Skills for [opencode](https://github.com/opencode-ai/opencode) and compatible CLIs.

Each skill is instructions, prompt patterns, scripts, and reference material so an AI agent can do a concrete job. Model-agnostic; several also install into **Grok** (`~/.grok/skills/`).

## Skills

| Skill | Description |
|-------|-------------|
| [project-bootstrap](skills/project-bootstrap/) | Single-agent “home” following [Agent Playbook](https://agents.md). **v2**: Variant E (rules at the start and end of the file), GRACE anchors, project classification (ops / code / agent / content), closing anchors for DeepSeek and GLM, dual audit. Writes AGENTS.md, SESSION_HANDOFF.md, MEMORY.md, rules, skills, personas, slash commands. 14 templates, 50+ variables, 6 workflow phases. [Details](skills/project-bootstrap/README.md) |
| [vs-architect](skills/vs-architect/) | Verbalized Sampling (arXiv 2510.01171): solution variants with probability estimates - architecture, debugging, strategy, creative work. |

### Which skill when?

| You need… | Skill |
|-----------|--------|
| Single-CLI agent home (AGENTS / MEMORY / HANDOFF) | **project-bootstrap** |
| Diverse solution variants with probabilities | **vs-architect** |

## Installation

### Quick install

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

ln -sfn ~/Projects/opencode-skills/skills/project-bootstrap \
  ~/.config/opencode/skills/project-bootstrap
ln -sfn ~/Projects/opencode-skills/skills/vs-architect \
  ~/.config/opencode/skills/vs-architect
```

### Manual install

```bash
cp -R skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
cp -R skills/vs-architect ~/.config/opencode/skills/vs-architect
```

After copying, opencode picks up the skill on the next launch.

## Repository structure

```
opencode-skills/
├── README.md               # English
├── README.ru.md            # Russian
├── CHANGELOG.md            # Release history
├── LICENSE                 # MIT
├── .gitignore
└── skills/
    ├── project-bootstrap/  # Single-CLI Agent Playbook infrastructure
    └── vs-architect/       # Verbalized Sampling prompting
```

## Creating your own skills

Simple convention:

1. Directory named after the skill
2. `SKILL.md` - main instructions with YAML frontmatter (`name`, `description` - describe **when** to use, not only what it does)
3. Optional `references/` - reference materials, examples, theory
4. Optional `assets/templates/` - generation templates with `${VARIABLE}` placeholders
5. Optional `scripts/` - helper shell/Python scripts

## License

MIT
