# Degraded modes (1–2 models)

| Roster | How to operate |
|--------|----------------|
| 1 model only | Same model may orchestrate + execute; F-04 becomes human or time-shifted self-check with explicit bias warning |
| 2 models | Prefer different families for author vs F-04 |
| No Orca | File-first stamps; paste/dispatch by hand; sequential dual if needed |
| Dual required but second family missing | **`DEGRADED_DUAL`** — see below |

Document degraded mode in SPEC.md or wave STATUS. Do not pretend full 4-role stack if harness missing.

## DEGRADED_DUAL

When the dual-review **gate table** (`production-playbook.md`) requires two families but only one is available:

1. Produce the single-family review artifact anyway.
2. Mark explicitly:
   ```text
   DEGRADED_DUAL: true
   reason: <no second family | cost | outage | human waiver>
   ```
3. Do not claim “dual-review PASS” in STATUS or release notes.
4. On high-stakes rows, prefer human skim before EXECUTE.

| Related mark | Meaning |
|--------------|---------|
| `DEGRADED_DUAL` | Dual required; only one family ran |
| `HUMAN_WAIVED_DUAL` | Human explicitly waived dual for this wave |

See also: `cross-audit-protocol.md`, `dispatch-iron.md`.
