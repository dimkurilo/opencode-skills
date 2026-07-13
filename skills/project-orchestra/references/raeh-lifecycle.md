# R.A.E.H. lifecycle

```
DRAFT (Author / wave-spec)
  → REVIEW* (Stamp Dialogue)
  → AGREE (stamp YES + acceptance.hash)
  → EXECUTE (Reviewer/Executor — separate task type)
  → VERIFY (optional F-04)
  → HANDOFF (Author STATUS/MEMORY; append SESSION_HANDOFF)
```

| Rule | Detail |
|------|--------|
| Execute gate | REVIEW-STAMP AGREED=YES + hash matches SPEC+PLAN |
| Session | Same session across review rounds; **new session per wave** |
| Write locks | Executor does not edit STATUS/MEMORY |
| Idempotency | waveId + phase + round + specHash + dispatchId |

Lightweight: skip stamp for tiny doc tweaks; flash = no session; emergency = human + short stamp.
