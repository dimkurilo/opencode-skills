# Project Bootstrap — agent infrastructure generator

🇷🇺 [Русская версия (primary)](README.ru.md)

In one session it builds an agent "home" for a project (AGENTS.md Variant E, SESSION_HANDOFF, .gitignore, `.agents/memory`, rules, skills), adapted to project type (ops/code/agent/content) and model (DeepSeek/GLM/Qwen/universal).

> **Primary docs (single source of truth):** [README.ru.md](README.ru.md) (Russian, maintained) + [SKILL.md](SKILL.md) (canonical contract). This file is a pointer — do not edit content here (README drift root).

**Router:** новый проект → `project-bootstrap` · план спринта → `wave-spec` · 2+ модели → `multi-model-orchestration`. project-bootstrap = точка входа.

**Use when** starting/extending a project ("создай структуру", "разверни агента"). **Do NOT use** for minor edits / audit / already-configured projects (extension mode there).
