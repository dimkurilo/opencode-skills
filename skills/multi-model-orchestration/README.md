# Multi-Model Orchestration

🇷🇺 [Русская версия](README.ru.md)

A skill for [opencode](https://github.com/opencode-ai/opencode) agents that coordinates 2+ AI models via [Orca](https://onorca.dev) for parallel review, cross-validation, and bulk work. The coordinator routes, dispatches, waits, synthesizes, and gates — never implements code.

## When to use

- "Discuss this with 2 models", "multi-model review", "cross-validate with N models"
- Fidelity ports (reference→platform): one writer (Qwen/GLM) + dual review (GLM ∥ Codex)
- Security/RLS/auth reviews: parallel Codex + Qwen (never single-model gate)
- Architecture decisions needing independent perspectives
- Bulk work exceeding one context window

## When not to use

- Single-model tasks, trivial edits, or §1 decision tree says "solo"
- Tasks that don't benefit from independent model perspectives
- Implementation by the coordinator (coordinator never writes code)

## Models

| Model | Best role | Cost |
|-------|-----------|------|
| GLM 5.2 | Multi-file implement, architecture synthesis | Medium |
| Qwen 3.8 Max | Fidelity port write, complex reasoning, multimodal | High |
| DeepSeek V4 Pro | Deep analysis, cross-audit, race conditions | Medium |
| DeepSeek V4 Flash | Bulk mechanical, inventory, hotfixes | Low |
| Grok 4.5 | Orchestration, fast research, speed loops | Low-Medium |
| Codex 5.5 | Security/RLS review, behavioral regression gate | High |
| GPT-5.6 | Lean outcome-focused coding | High |

Routing depends on task type, not model preference. See `references/routing.md` for the full table with evidence anchors.

## [platform] highlights

- **Routing table:** 7 task types mapped to model families with evidence from I3–[TICKET] waves
- **Dual review mandatory:** fidelity ports require GLM 5.2 (static parity) ∥ Codex 5.5 (hosted semantics) — complementary, not redundant
- **Deploy / smoke gate:** prove shipped surface exists before handoff (principle + curl examples in `references/routing.md`)
- **Lifecycle:** 7 explicit gates: implement → review → commit → PR → merge → deploy → done. No collapsing into "writer Done"
- **Writer replaceable:** owner phrase «сейчас writer=X» pins writer instantly — no skill rewrite

## Installation

```bash
# Clone the skills repo
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

# Symlink into your opencode config
ln -sfn ~/Projects/opencode-skills/skills/multi-model-orchestration ~/.config/opencode/skills/multi-model-orchestration
```

Or copy the folder:

```bash
cp -r ~/Projects/opencode-skills/skills/multi-model-orchestration ~/.config/opencode/skills/multi-model-orchestration
```

Requires `orca-cli` and `orchestration` skills installed. Workers use Orca terminals or manual fallback.

## Layout

```
multi-model-orchestration/
├── SKILL.md              # Agent instructions (loaded by opencode)
├── README.md             # This file
├── README.ru.md          # Russian version
└── references/
    ├── routing.md         # Full model routing table, brief templates, deploy/smoke gate
    ├── worker-contract.md # Output contract, live worker_done CLI, written≠persisted gate
    ├── failure-handling.md # Timeout policy, escalation, circuit-breaker
    └── model-card.md      # Roles, «не путать с», evidence 1-liners, owner pin, launch pins
```

## License

MIT — part of [opencode-skills](https://github.com/dimkurilo/opencode-skills).
