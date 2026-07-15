# VS Architect - distribution-level prompting for LLMs

🇷🇺 [Русская версия](README.ru.md)

A skill for [opencode](https://github.com/opencode-ai/opencode) agents that uses **Verbalized Sampling** (arXiv 2510.01171) so the model does not collapse into one default answer.

## Verbalized Sampling

Ask an LLM “do X” and you get the most typical answer (mode prototype). That is **mode collapse**: the same templated solution every time, even when many good alternatives exist.

**Verbalized Sampling (VS)** changes the prompt shape. Instead of “do X”, ask: “give 5 variants for X with success probabilities”. The model stops locking onto one prototype and returns a distribution closer to real diversity of solutions.

Paper: arXiv 2510.01171v3 (ICLR 2026) -
*Verbalized Sampling: How to Mitigate Mode Collapse and Unlock LLM Diversity.*

## Problems it covers

| Problem | What VS does |
|---------|--------------|
| LLM always gives the same answer | Distribution-level prompt opens up diversity |
| Unsure which approach to pick | Variants with probabilities - easier to see what is promising |
| Diagnosis with no single hypothesis | VS-CoT builds a hypothesis tree with checks |
| Architecture choice | VS-Standard compares approaches with pros and cons |
| Need many ideas or data points | VS-Multi: multiple rounds, 10+ variants |

## What you get

- 3 to 10+ solution variants with success probability estimates
- Clear task classification a human can read
- Ready execution prompt for the chosen variant
- Fewer “ask again and hope it differs” loops

## When to use

- Choosing architecture or approach among several options
- Direct prompts produce repetitive, mode-collapsed answers
- Debugging with unknown root cause
- Hypotheses, synthetic data, test cases
- Creative work where diversity matters

## When not to use

- Simple scripts with an obvious answer - write them directly
- Factual queries (2 plus 2, capital of France)
- Stable production code - a direct prompt is more reliable

## Installation

```bash
# Clone the skills repo
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

# Symlink into your opencode config
ln -sf ~/Projects/opencode-skills/skills/vs-architect ~/.config/opencode/skills/vs-architect
```

Or copy the folder:

```bash
cp -r ~/Projects/opencode-skills/skills/vs-architect ~/.config/opencode/skills/vs-architect
```

## Usage

Once installed, opencode discovers the skill and offers it when the task matches the description.

## Patterns

| Pattern | When | What it does |
|---------|------|--------------|
| **A** VS-Standard | Moderate complexity, 3-5 variants | One call, k variants with probabilities |
| **B** Diversity Tuning | Direct prompt yields uniform answers | Filter by probability threshold |
| **C** VS-CoT | Uncertainty, diagnostics, strategy | Reasoning first, then distribution |
| **D** VS-Multi | Need 10+ variants | Multiple rounds, each excludes prior ideas |
| **E** External Collapse | External constraints the LLM does not know | You weight variants by your criteria |
| **F** VS-Refine | Strong ideas need sharpening | Two passes: variants, then refine the best |
| **G** VS-Ensemble | Critical decision needs cross-check | Two independent VS prompts, compare results |

## Layout

```
vs-architect/
├── SKILL.md           # Agent instructions (loaded by opencode)
├── README.md          # This file
├── references/
│   ├── vs-theory.md   # Decision tree, templates, mode mapping
│   └── examples.md    # Real-world examples
└── .gitignore
```

## License

MIT - part of [opencode-skills](https://github.com/dimkurilo/opencode-skills).
