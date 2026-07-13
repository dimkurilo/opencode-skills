# Role archetypes

| Role | Responsibility | Write scope |
|------|----------------|-------------|
| Orchestrator | Doctrine, program SPEC/PLAN, STATUS/MEMORY, dispatch, synthesis | STATUS, MEMORY, program SPEC |
| Wave Executor | Autonomous execute after stamp YES; evidence | audits/\<executor\>/, EXEC-REPORT, research/ |
| Cross-auditor | Different-family F-04 | audits/\<auditor\>/ |
| Stateless pull | One-shot API/curl | research only |

## Write lock rules

- Executor **never** edits STATUS.md or MEMORY.md.
- Auditor does not rewrite program SPEC ownership.
- One STATUS writer (orchestrator).

## Load sanity

Loads should sum ~100%. Flag if any role ≥60% without self-assessment.
