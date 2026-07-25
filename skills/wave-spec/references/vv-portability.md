# vv-opencode → wave-spec portability

| vv-opencode | wave-spec |
|-------------|-----------|
| `vv-spec` mode | this skill steps 0–3 → `SPEC.xml` |
| `vv-plan` mode | this skill step 4 → `PLAN.xml` |
| `.vvoc/specs/<date>-<slug>/spec.xml` | `waves/<date>-<slug>/SPEC.xml` or `roadmap/PROGRAM_SPEC.xml` |
| `.vvoc/specs/.../plan.xml` | `PLAN.xml` beside SPEC |
| approve in framework | user message `approve` + status fields |
| execution in same harness | worker briefs + any CLI / Orca |
| design-context.xml | optional; use MEMORY.md + research files instead |
| XML runtime validation in vv | soft validation by skill quality bar |

## Keep from vv

- Spec before plan
- Measurable success criteria
- Explicit out of scope
- Wave/task dependency order
- Nested structured fields (XML)

## Drop from vv (unless big rewrite)

- Mandatory multi-thousand-line architecture dump for every wave
- Framework-only commands
- Dual design-context unless code rewrite

## Why XML here

Structured nested contracts reduce ambiguity for agents (required sections, ids, depends_on).
You get the **document shape** of vv without requiring the **vv-opencode runtime**.
INTENT stays Markdown for humans.
