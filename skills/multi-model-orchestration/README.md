<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/hero-light.svg">
  <img alt="multi-model-orchestration" src="assets/hero-light.svg" width="100%">
</picture>

# multi-model-orchestration

🇷🇺 [Русская версия](README.ru.md) · **English** · [← all skills](../../README.md)

**Coordinate 2+ AI models for review, cross-validation, or bulk work.**

A dispatch/review engine. The coordinator routes a task to N model workers via [Orca](https://onorca.dev), waits for results, and synthesizes — with a hard rule that the writer and reviewer never come from the same model family.

---

## When to use

- You need **independent perspectives** — *"обсудите с 2 моделями"*, *"cross-validate"*, *"parallel review"*.
- A **fidelity port** (generator, vectorizer, reference→platform) — dual review mandatory.
- **Security / RLS / auth** review — never gated by one model alone.
- **Bulk work** that exceeds one context window.

**Don't use it** for single-model tasks, trivial edits, or when a direct prompt is enough. Solo first, multi only when a second family actually adds signal.

## The routing table

| Work | Route to | Why |
|------|----------|-----|
| Orchestrator + primary writer | **DeepSeek V4 Flash** | role lock: dispatch → wait → gate → synthesize, plus primary coder |
| Multi-file implement (3+) | **GLM 5.2** | 1M state continuity, long-horizon specialty |
| Review / architecture (default reviewer) | **Qwen 3.8 Max** | depth, architecture, business analysis |
| Security / behavioral gate | **GPT-5.5** | unique role — caught regressions other models missed |

**Cross-family rule:** `writer.family ≠ reviewer.family`. Qwen-writer → reviewer must be DeepSeek/Zhipu/OpenAI, not another Alibaba model. Different families catch different blind spots.

## How a wave runs

```
1. CLASSIFY       solo or multi? (§1 decision tree)
2. SELECT models  name them to the human first
3. CREATE         one terminal per worker, same worktree
4. BUILD briefs   model-specific (references/routing.md)
5. PRE-DISPATCH   model-card check → --agent flag → variant/effort → sleep 3
6. DISPATCH       task-create → dispatch --inject (NOT terminal send)
7. WAIT           check --wait --types worker_done,escalation,decision_gate
8. SYNTHESIZE     consensus / contradictions / gaps — stricter severity wins
```

Coordinator **does not write code** in the same task — that's a role lock. Review-only `worker_done` reports findings; it does not authorize the coordinator to edit. Implementation = new task.

## The worker contract

Every worker brief carries `ROLE / SCOPE / MODE / DONE / FORBIDDEN` and ends with:

```
SUMMARY / EVIDENCE / CHANGES / RISKS / BLOCKERS
```

`worker_done` is a CLI signal with a mandatory `--to <coordinator-handle>` — without it the message routes to void (production incident). `heartbeat` means alive, **not** done. One timeout = liveness check, not failure.

## Install

```bash
ln -sfn ~/Projects/opencode-skills/skills/multi-model-orchestration \
  ~/.config/opencode/skills/multi-model-orchestration
```

Requires the `orchestration` and `orca-cli` skills loaded alongside, and Orca runtime up (`orca status --json`).

## Example wave

> **You:** discuss this architecture with 2 models — I want independent takes.
>
> **Coordinator** *(loads skill)*: classifies multi → routes architecture review to Qwen 3.8 (default reviewer) + GPT-5.5 (security/behavioral lens) → builds briefs → dispatch via Orca `--inject` → wait → Qwen flags a race condition, GPT-5.5 flags an abort-edge-case → synthesize: 2 MAJOR findings, both must fix before merge → routes the fix round to Flash (writer, different family).

## What's inside

- **References:**
  - `routing.md` — full routing table, per-model brief templates, cross-family pairs.
  - `model-card.md` — roles, family field, launch pins, "do not confuse with" notes.
  - `worker-contract.md` — output contract, inject preamble, `worker_done` delivery rule.
  - `failure-handling.md` — timeout policy, escalation, circuit-breaker, writer-swap rule.
  - `prohibitions.md` — 11 hard prohibitions with correct alternatives.
- **Lifecycle gates, fidelity dual review, deploy probe:** canonical definitions live in `wave-spec`.

## Router

```
новый проект → project-bootstrap · план спринта → wave-spec · 2+ модели → multi-model-orchestration
```

## License

MIT · part of [opencode-skills](../../README.md)
