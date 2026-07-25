# opencode-skills

🇷🇺 [Русская версия](README.ru.md)

Skills for [opencode](https://github.com/opencode-ai/opencode) and compatible CLIs.

Each skill is instructions, prompt patterns, scripts, and reference material so an AI agent can do a concrete job. Model-agnostic; several also install into **Grok** (`~/.grok/skills/`).

## Skills

| Skill | Description |
|-------|-------------|
| [project-bootstrap](skills/project-bootstrap/) | Minimal cross-platform project setup for Codex, Grok, OpenCode, ZCode, and GLM/DeepSeek hosts. Uses a short `AGENTS.md` as the universal core; bounded handoff/memory, adapters, and selective GSD are opt-in. Includes read-only inspection, reversible migration, and deterministic verification. [Details](skills/project-bootstrap/README.md) |
| [multi-model-orchestration](skills/multi-model-orchestration/) | Coordinate 2+ AI models (GLM 5.2, DeepSeek V4 Pro/Flash, Qwen 3.8 Max, Grok 4.5, GPT-5.6) for parallel review, cross-validation, or bulk work via Orca. Routing table, dual review rules, deploy gate, lifecycle. [Details](skills/multi-model-orchestration/README.md) |
| [vs-architect](skills/vs-architect/) | Verbalized Sampling (arXiv 2510.01171): solution variants with probability estimates - architecture, debugging, strategy, creative work. |

### Which skill when?

| You need… | Skill |
|-----------|--------|
| Minimal agent project contract or safe legacy migration | **project-bootstrap** |
| Coordinating 2+ AI models for parallel review, cross-validation, or bulk work | **multi-model-orchestration** |
| Diverse solution variants with probabilities | **vs-architect** |

## Installation

### Quick install

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

ln -sfn ~/Projects/opencode-skills/skills/project-bootstrap \
  ~/.config/opencode/skills/project-bootstrap
ln -sfn ~/Projects/opencode-skills/skills/vs-architect \
  ~/.config/opencode/skills/vs-architect
ln -sfn ~/Projects/opencode-skills/skills/multi-model-orchestration \
  ~/.config/opencode/skills/multi-model-orchestration
```

### Manual install

```bash
cp -R skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
cp -R skills/vs-architect ~/.config/opencode/skills/vs-architect
cp -R skills/multi-model-orchestration ~/.config/opencode/skills/multi-model-orchestration
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
    ├── project-bootstrap/  # Minimal cross-platform agent project setup
    └── vs-architect/       # Verbalized Sampling prompting
    └── multi-model-orchestration/  # Multi-model coordination via Orca
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
