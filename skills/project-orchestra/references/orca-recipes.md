# Orca recipes (optional)

File-first truth — Orca is transport only.

```bash
# Example: dispatch review brief
orca terminal create --worktree active --title wave-review --command "grok" --json
orca terminal send --terminal <handle> --text "$(cat prompts/…/wave-review.md)" --enter --json
```

Message types (logical): task REVIEW, task EXECUTE, worker_done, escalation, decision_gate.

Never set Orca subject to AGREED without reading stamp file.
