# Profile selection

Два шага: **роль**, потом **семья модели**.

## 1. Роль → profile

| Role | Default profile |
|------|-----------------|
| Wave Executor | `executor-task-done` |
| Orchestrator drafting | `orchestrator-goal-context` |
| Cross-auditor / checklist check | `auditor-what-where` |
| Stateless one-shot | `flash-oneshot` |

Profiles: `assets/templates/profiles/`.  
Cheatsheets after install: `prompts/_dispatch/`.

Выбор **не по престижу** модели («самая новая = всегда auditor»).

## 2. Семья модели → форма запроса

Роль говорит *зачем*. Форма запроса зависит от **семьи**:

| Семья | Несущая форма | Файл |
|-------|---------------|------|
| DeepSeek V4 | что / где / done | `model-prompt-shapes.md` |
| GLM 5.2 | Goal → Context → Constraints → Done | `model-prompt-shapes.md` |
| Grok 4.5 | Task + Done (+ Autonomy) | `model-prompt-shapes.md` |
| **GPT-5.6** | Goal + Success + Stop (lean) | `model-prompt-shapes.md` |

Читай **`references/model-prompt-shapes.md`** перед dual-worker dispatch.

## 3. Пример связки (авторский стек, не догма)

| Job | Типично |
|-----|---------|
| Lead / plan | Grok 4.5 или Claude Code + GLM 5.2 |
| Checklist / evidence | DeepSeek V4 Pro или GPT-5.6 |
| Stress «что сломается» | GLM 5.2 или GPT-5.6 (другая семья, чем author) |
| Execute | Grok / DeepSeek / OpenCode - pin shell + model |

Личные длинные гайды и agent-persona **не** входят в публичный пакет - только каркас выше.
