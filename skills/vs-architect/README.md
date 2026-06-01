# VS Architect — Distribution-Level Prompting for LLMs

🇷🇺 [Русская версия](README.ru.md)

A skill for [opencode](https://github.com/opencode-ai/opencode) agents that uses **Verbalized Sampling** (arXiv 2510.01171) to overcome LLM mode collapse.

## What is Verbalized Sampling?

When you ask an LLM "do X", the model outputs the most typical answer (mode prototype).
This is called **mode collapse** — the model converges to the same templated solution every time,
even when many good alternatives exist.

**Verbalized Sampling (VS)** solves this by changing the prompt structure.
Instead of `"do X"`, ask: `"give 5 variants for X with success probabilities"`.
The model stops collapsing into a single prototype and starts generating a distribution of variants
that approximates the real diversity of possible solutions.

Based on arXiv 2510.01171v3 (ICLR 2026):
*"Verbalized Sampling: How to Mitigate Mode Collapse and Unlock LLM Diversity."*

## What problem does it solve?

| Problem | How VS solves it |
|---------|-----------------|
| LLM always gives the same answer | Distribution-level prompt unlocks diversity |
| Uncertain which approach to pick | VS generates variants with probabilities — you see which are promising |
| Complex diagnosis with no clear hypothesis | VS-CoT pattern builds a hypothesis tree with verifications |
| Architecture selection anxiety | VS-Standard — approach comparison with pros/cons |
| Need many ideas or data points | VS-Multi — iterative generation, 10+ variants |

## What results to expect?

- 3 to 10+ solution variants with success probability estimates
- Clear task classification, understandable to the user
- Ready-to-use execution prompt for the selected variant
- Time savings: no need to ask the LLM 5 times hoping for a different answer

## When to use

- Choosing architecture or approach from multiple options
- Direct prompts produce repetitive, mode-collapsed responses
- Debugging with unknown root cause
- Generating hypotheses, synthetic data, test cases
- Creative tasks where diversity matters

## When NOT to use

- Simple scripts with obvious solutions (faster to write directly)
- Factual queries (2+2, capital of France)
- Stable production code — direct prompt is more reliable

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

Once installed, the opencode agent will automatically discover the skill and offer to load it
when the task matches the skill description.

## Patterns

| Pattern | When | What it does |
|---------|------|-------------|
| **A** VS-Standard | Moderate complexity, 3–5 variants | Single call → k variants with probabilities |
| **B** Diversity Tuning | Uniform responses from direct prompt | Filters by probability threshold |
| **C** VS-CoT | Uncertainty, diagnostics, strategy | Step-by-step reasoning first, then distribution |
| **D** VS-Multi | Need 10+ variants | Multiple rounds, each excluding previous ideas |
| **E** External Collapse | External constraints LLM doesn't know about | User weights variants by own criteria |
| **F** VS-Refine | Interesting ideas need elaboration | Two-pass: variants → refine top picks |
| **G** VS-Ensemble | Critical decision needs cross-validation | Two independent VS prompts, results compared |

## Repository structure

```
vs-architect/
├── SKILL.md           # Agent instructions (loaded by opencode)
├── README.md          # This file — human-readable description
├── references/
│   ├── vs-theory.md   # Full decision tree, templates, mode mapping
│   └── examples.md    # Real-world usage examples
└── .gitignore
```

## License

MIT — part of [opencode-skills](https://github.com/dimkurilo/opencode-skills).
