# opencode-skills

🇷🇺 [Русская версия](README.ru.md)

A collection of skills for [opencode](https://github.com/opencode-ai/opencode) (and compatible) agents.

Each skill is a set of instructions, prompt patterns, scripts, and reference materials that teach an AI agent how to perform a specific task effectively. Skills are model-agnostic and work with any LLM backend supported by opencode; several also install cleanly into **Grok** (`~/.grok/skills/`).

## Skills

| Skill | Description |
|-------|-------------|
| [project-bootstrap](skills/project-bootstrap/) | Agent infrastructure generator following [Agent Playbook](https://agents.md). **v2**: Variant E architecture (rules in primacy + recency = inevitable), GRACE semantic anchors, adaptive project classification (ops/code/agent/content), model-specific closing anchors (DeepSeek/GLM/universal), dual-audit verification. Creates AGENTS.md, SESSION_HANDOFF.md, MEMORY.md (append-only), rules with Gotchas, skills, agent personas, slash commands. 14 templates, 50+ variables, 6 workflow phases. [Details →](skills/project-bootstrap/README.md) |
| [skill-work-project-creator](skills/skill-work-project-creator/) | **Multi-Agent Kit 1.0** — bootstrap a multi-CLI multi-wave program OS: harness inventory, domain-novelty H-panel, role matrix, L0 consistency, Stamp Dialogue + R.A.E.H., dispatch dialects, evidence plane. Modes: `full`, `roles-only`, `wire-raeh`, `extend`, `cleanup`, `raeh-review`, `raeh-execute`, `install-dialects`. 9 gate scripts, 33 templates, 19 references. OpenCode + Grok. Peer of project-bootstrap (single-CLI) and wave-spec (wave drafting). [Details →](skills/skill-work-project-creator/README.md) |
| [vs-architect](skills/vs-architect/) | Distribution-level prompting via Verbalized Sampling (arXiv 2510.01171). Generates solution variants with probability estimates for architecture, debugging, strategy, and creative tasks. |

### Which skill when?

| You need… | Skill |
|-----------|--------|
| Single-CLI agent home (AGENTS / MEMORY / HANDOFF) | **project-bootstrap** |
| Multi-CLI roles, stamps, wave OS | **skill-work-project-creator** |
| Diverse solution variants with probabilities | **vs-architect** |

## Installation

### Quick install

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

ln -sfn ~/Projects/opencode-skills/skills/project-bootstrap \
  ~/.config/opencode/skills/project-bootstrap
ln -sfn ~/Projects/opencode-skills/skills/skill-work-project-creator \
  ~/.config/opencode/skills/skill-work-project-creator
ln -sfn ~/Projects/opencode-skills/skills/vs-architect \
  ~/.config/opencode/skills/vs-architect

# Optional: Grok user skills
ln -sfn ~/Projects/opencode-skills/skills/skill-work-project-creator \
  ~/.grok/skills/skill-work-project-creator
```

### Manual install

```bash
cp -R skills/project-bootstrap ~/.config/opencode/skills/project-bootstrap
cp -R skills/skill-work-project-creator ~/.config/opencode/skills/skill-work-project-creator
cp -R skills/vs-architect ~/.config/opencode/skills/vs-architect
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
    ├── project-bootstrap/           # Single-CLI Agent Playbook infrastructure
    ├── skill-work-project-creator/  # Multi-agent program OS kit (v1.0)
    └── vs-architect/                # Verbalized Sampling prompting
```

## Creating your own skills

Skills follow a simple convention:

1. Directory named after the skill
2. `SKILL.md` — main instruction file with YAML frontmatter (`name`, `description` — describe WHEN to use, not only what it does)
3. Optional `references/` — reference materials, examples, theory
4. Optional `assets/templates/` — generation templates with `${VARIABLE}` placeholders
5. Optional `scripts/` — helper shell/Python scripts

## License

MIT
