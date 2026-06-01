# opencode-skills

🇷🇺 [Русская версия](README.ru.md)

A collection of skills for [opencode](https://github.com/opencode-ai/opencode) agents.

Each skill is a set of instructions, prompt patterns, and reference materials that teach an AI agent how to perform a specific task effectively. Skills are model-agnostic and work with any LLM backend supported by opencode (OpenAI-compatible API).

## Skills

| Skill | Description |
|-------|-------------|
| [vs-architect](skills/vs-architect/) | Distribution-level prompting via Verbalized Sampling (arXiv 2510.01171). Generates diverse solution variants with probability estimates for architecture decisions, debugging, strategy, creative work, and data generation. |

## Installation

### Quick install

```bash
# Clone the repo
git clone git@github.com:YOUR_USERNAME/opencode-skills.git ~/Projects/opencode-skills

# Symlink a skill into your opencode config
ln -sf ~/Projects/opencode-skills/skills/vs-architect ~/.config/opencode/skills/vs-architect
```

### Manual install

Copy the skill folder directly:

```bash
cp -r skills/vs-architect ~/.config/opencode/skills/vs-architect
```

After copying, the opencode agent will automatically discover the skill on next launch.

### Per-project install

```bash
# In your project root
mkdir -p .opencode/skills
cp -r skills/vs-architect .opencode/skills/vs-architect
```

## Repository structure

```
opencode-skills/
├── README.md               # This file (English)
├── README.ru.md            # Russian version
├── LICENSE                 # MIT
├── .gitignore
└── skills/
    └── vs-architect/       # Individual skill
        ├── SKILL.md
        ├── references/
        │   ├── vs-theory.md
        │   └── examples.md
        └── .gitignore
```

## Creating your own skills

Skills in this repo follow a simple convention:

1. A directory named after the skill
2. `SKILL.md` — main instruction file with YAML frontmatter (`name`, `description`)
3. Optional `references/` — reference materials, examples, theory
4. Optional `scripts/` — helper shell/Python scripts
5. Optional `config/` — configuration templates

If you want to contribute or fork, feel free to follow the same structure.

## License

MIT
