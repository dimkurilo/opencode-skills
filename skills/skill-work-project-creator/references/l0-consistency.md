# L0 Consistency Pass

| Field | Rule |
|-------|------|
| Who | One model (orchestrator candidate or cheapest cross-family reader) |
| Inputs | AGENTS, SPEC, STATUS, plan, MEMORY roles, CLI entry files |
| Output | `audits/<date>-L0-consistency.md` |
| Checks | Single orchestrator; write locks; role %; STATUS↔SPEC; one focus; gate names |
| Verdict | `CLEAN` \| `CONTRADICTIONS` (file:line list) |
| Gate | CONTRADICTIONS block G0 / block fast-path success |

**Never skip** on architecture path. Use `verify_l0_inputs.sh` first.
