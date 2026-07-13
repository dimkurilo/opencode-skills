# REVIEW-STAMP — ${WAVE_ID}

```
AGREED: NO
SPEC_PATH: waves/${WAVE_ID}/SPEC.xml
PLAN_PATH: waves/${WAVE_ID}/PLAN.xml
SPEC_HASH: (run hash_acceptance.sh after YES path)
ROUND: 1
MAX: 5
SESSION_ID: ${SESSION_ID}
CHECKLIST_VERSION: ${CHECKLIST_VERSION}
TIMESTAMP: ${DATE}
AUTHORITY: Wave Reviewer (executor or auditor)
```

## Open deltas (if AGREED=NO)

| id | path | fix | severity |
|----|------|-----|----------|
| D1 | | | |

## Execute blockers
- (list or "none after YES")

## Next action for Author
- Patch only open deltas; re-dispatch same review session.

## Notes
- Do not expand checklist mid-loop except CRITICAL safety.
- Forbidden: claim AGREED in chat if this file says NO.
