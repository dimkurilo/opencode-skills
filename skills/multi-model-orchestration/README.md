# Multi-Model Orchestration

🇷🇺 [Русская версия (primary)](README.ru.md)

Coordinates 2+ AI models via [Orca](https://onorca.dev) for parallel review, cross-validation, and bulk work. The coordinator routes, dispatches, waits, synthesizes, gates — never implements code.

> **Primary docs (single source of truth):** [README.ru.md](README.ru.md) (Russian, maintained) + [SKILL.md](SKILL.md) (canonical contract). This file is a pointer — do not edit content here ([TICKET]: README drift root).

**Router:** новый проект → `project-bootstrap` · план спринта → `wave-spec` · 2+ модели → `multi-model-orchestration`.

**Use when:** "discuss with 2 models", multi-model review, cross-validate, fidelity ports (writer + dual review), security/RLS (never single-model gate), bulk > 1 context window. **Do NOT use** for single-model tasks / trivial edits / when §1 says solo.
