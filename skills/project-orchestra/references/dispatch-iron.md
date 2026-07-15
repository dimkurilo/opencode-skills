# Dispatch iron rules

Non-negotiable constraints for multi-worker dispatches (Orca or manual).

## 0. Run dispatch algorithm first

`references/dispatch-algorithm.md`:  
**role → model family → prompt shape → pin → brief file → send → identity**.

No shape id in brief header → invalid dual-review claim.

## 1. Pin agent + model + shape

Every worker brief / terminal create must pin:

| Field | Example |
|-------|---------|
| Agent / CLI | `opencode`, `grok`, `codex`, … |
| Model family + id | DeepSeek Pro, GLM 5.2, Grok 4.5, **gpt-5.6-terra** |
| Prompt shape | `shape:gpt56-goal-success-stop` (see model-prompt-shapes) |
| Effort (API) | high / medium - **not** “think harder” in text |
| Role | reviewer-F04, stress, executor |
| CWD | absolute project path |
| Output path | single primary artifact path |

Unpinned “just open another chat” is invalid for dual-review claims.

GPT-5.6: lean Goal/Success/Stop; official guidance  
https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6

## 2. Complementary lanes (not clones)

| Lane | Focus | Invalid if… |
|------|-------|-------------|
| **F-04 / ledger** | Evidence vs claims; acceptance checklist; “is it proven?” | Same prompt as stress |
| **Stress** | Failure modes; missing gates; rollback; “what breaks?” | Only restates F-04 |

Minimum difference: different **job** + different **model family** + **different brief text/shape** when dual is required.

## 3. Identity gate

Before accepting worker output:

1. Output path exists and is non-empty.
2. Header or footer identifies worker role + model (or terminal handle logged).
3. Content addresses the assigned lane (ledger ≠ stress).
4. No stamp YES written by executor role.

If identity fails → archive as **invalid**, re-dispatch or DEGRADED_DUAL.

## 4. Invalid archive

| Condition | Action |
|-----------|--------|
| Wrong model / unpinned | Move to `audits/_invalid/` or wave `invalid/`; do not count as dual |
| Empty / tool-error only | Re-run once; then escalate |
| Stamp written without SPEC+PLAN hash path | Reject; stamp is reviewer-only |

## 5. Parallel transport

| Parallel OK | Parallel forbidden |
|-------------|-------------------|
| Orca `terminal create` × N with separate handles | Two bare headless `opencode run` against same DB |
| Sequential single-CLI if Orca unavailable | Pretending sequential single-model is dual |

## 6. File-first truth

- Dispatch briefs live under `prompts/` or `waves/<id>/prompts/`.
- Results live under `audits/<lane>/` or wave dir.
- Coordinator merges; chat summary is optional.

See also: `cross-audit-protocol.md`, `orca-recipes.md`, `production-playbook.md`.
