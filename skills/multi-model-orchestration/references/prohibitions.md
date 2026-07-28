# Hard Prohibitions

12 rules. Each has a reason and a correct alternative. Violation = operational failure.

| # | Prohibition | Reason | Correct alternative |
|---|------------|--------|---------------------|
| 1 | `opencode` without `--agent` | Launches vv-controller (default agent, explores project instead of task) | `opencode --agent <pin from model-card.md>` |
| 2 | Launching model without checking model-card.md | Availability and pins change. Model may be temporarily unavailable | Before launch: check model-card.md → current pin, status (⚠️ = unavailable) |
| 3 | `terminal send` for task delivery | No lifecycle preamble → worker_done won't arrive | `dispatch --inject` (only path) |
| 4 | Skipping `sleep 3` after variant/effort | Race condition: dispatch arrives before variant applied | Always `sleep 3` between variant/effort and dispatch |
| 5 | `result.id` when parsing task-create | Correct path: `result.task.id` | `json.load(sys.stdin)['result']['task']['id']` |
| 6 | Qwen Code without `--approval-mode yolo` | Blocks orca commands on confirmation prompts | Always `qwen --approval-mode yolo` |
| 7 | Writer + reviewer from same family | Blind-spot risk: one model family can't see its own patterns | Cross-family: writer.family ≠ reviewer.family (see routing.md) |
| 8 | Coordinator writes code | Role lock: dispatch → wait → synthesize → gate. Coordinator editing files = violation | New task → one writer (not coordinator). If coordinator edited → undo → re-dispatch |
| 9 | Restart worker on silence | Heartbeat = alive. Timeout ≠ failure | Liveness check (`terminal read`) → repeat wait |
| 10 | Flash on multi-file (3+ files) | I3: edge-case bugs, almost-right-then-hotfix | GLM 5.2 or Qwen Code for multi-file |
| 11 | Tool-calling loop > 3 identical actions without text output | Blocks user, wastes time (P15/P18: Grok 10x "Post Linear comment") | STOP after 3 identical calls → text response to user with status |
| 12 | Flash as orchestrator | No `plan-before-act` anchor (P1 = act-immediately), no `task: true` in frontmatter, bulk/hotfix only (I3 post-mortem). Will skip planning and jump to execution — dangerous for multi-step orchestration | Use Grok 4.5 (default), DeepSeek V4 Pro, or Qwen 3.8 Max. Owner pin: «сейчас orchestrator=X» |
