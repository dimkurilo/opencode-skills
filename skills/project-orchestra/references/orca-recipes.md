# Orca recipes

File-first truth — Orca is **transport only**. Stamp file and reports on disk are authority.  
Orchestration task API / `worker_done` messages are **optional** convenience; default dual is two terminals + two output files.

**Author recommendation:** use [Orca](https://onorca.dev) ([github.com/stablyai/orca](https://github.com/stablyai/orca)) when two agents must run side by side. Pros/cons: skill README, *How I actually use this*.

## Pin rules (do not invent providers)

| Family | Typical CLI pin (examples) |
|--------|----------------------------|
| GPT-5.6 / Codex | `codex exec --model gpt-5.6-sol -c model_reasoning_effort="xhigh"` (effort = API pin) |
| GLM 5.2 | `opencode --auto --agent A/agent1st_v13-glm --model zai-coding-plan/glm-5.2` |
| DeepSeek V4 Pro | `opencode --auto --agent A/agent1st_v36-pro --model opencode-go/deepseek-v4-pro` |
| Grok | `grok --always-approve --no-plan` (or project default) |

- Prefer model/agent from **your** agent frontmatter / harness inventory — do not invent OpenRouter routes.
- Never two parallel bare `opencode run` (DB lock). Use two Orca terminals (or sequential).
- **Never** hang Grok persona text on Codex/GLM; use shape + CLI/model pin only.

## Dual-worker parallel review (1.1 default)

**Goal:** two complementary jobs (different families + different shapes + different brief text).

```bash
# 1) Two terminals — pin agent+model in --command (parameterize per family)
orca terminal create --worktree active --title po-ledger \
  --command 'opencode --auto --agent A/agent1st_v36-pro --model opencode-go/deepseek-v4-pro' --json
orca terminal create --worktree active --title po-stress \
  --command 'opencode --auto --agent A/agent1st_v13-glm --model zai-coding-plan/glm-5.2' --json

# 2) Wait until each TUI is ready (do not send into a cold prompt)
orca terminal wait --terminal <handle-ledger> --for tui-idle --timeout-ms 90000 --json
orca terminal wait --terminal <handle-stress> --for tui-idle --timeout-ms 90000 --json

# 3) Different briefs (not clones) — prefer short "read file X and execute"
orca terminal send --terminal <handle-ledger> --text "$(cat prompts/…/f04-ledger.md)" --enter --json
orca terminal send --terminal <handle-stress> --text "$(cat prompts/…/stress-fail.md)" --enter --json

# 4) Wait for **files on disk** (poll paths), not chat vibes
# 5) Identity gate: each report header has role + family + shape
# 6) Merge into audits/ or wave STATUS; mark DEGRADED_DUAL if only one family
```

| Worker | Role | Shape example | Output example |
|--------|------|---------------|----------------|
| Terminal A | F-04 ledger | deepseek-what-where-done | `audits/f04/REVIEW.md` |
| Terminal B | Stress | glm-goal-context-done | `audits/stress/FAILURE_MODES.md` |

**Never:**

- Two parallel bare `opencode run` on the same OpenCode DB  
- Chat `AGREED` without stamp YES  
- Same prompt text to both workers labeled “dual”  
- Default agent `vv-controller` for narrow audit/execute tasks  

If Orca unavailable → sequential single terminals or human dual; mark `DEGRADED_DUAL` if only one family.

## Single wave review dispatch

```bash
orca terminal create --worktree active --title wave-review \
  --command 'opencode --auto --agent A/agent1st_v13-glm --model zai-coding-plan/glm-5.2' --json
orca terminal wait --terminal <handle> --for tui-idle --timeout-ms 90000 --json
orca terminal send --terminal <handle> --text "$(cat waves/<id>/prompts/wave-review.md)" --enter --json
# Same reviewer session for rounds 1..N
```

## Execute after stamp YES

```bash
# Schema + live hash (paths named in stamp)
bash "$SKILL_DIR/scripts/verify_stamp_schema.sh" waves/<id>
bash "$SKILL_DIR/scripts/verify_stamp_hash.sh" waves/<id>

# Fresh executor session (not the review session)
orca terminal create --worktree active --title wave-exec \
  --command 'opencode --auto --agent A/agent1st_v36-pro --model opencode-go/deepseek-v4-pro' --json
orca terminal wait --terminal <handle> --for tui-idle --timeout-ms 90000 --json
orca terminal send --terminal <handle> --text "$(cat waves/<id>/prompts/execute.md)" --enter --json
```

Executor writes `EXEC-REPORT.md` only — not STATUS/MEMORY/HANDOFF.

## Optional: orchestration messages

Supervised `worker_done` / task DAGs via Orca orchestration are fine when the coordinator already uses that skill. They are **not** required for dual-review validity — files on disk are.

## Identity + invalid

Pin agent+model per terminal. Fail identity → invalid archive (`dispatch-iron.md`).
