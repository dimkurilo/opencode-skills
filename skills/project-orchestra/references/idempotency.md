# Idempotency keys

Compose: `waveId + phase + round + specHash + dispatchId`

- Re-dispatch same review round → same stamp path, increment ROUND only after author patch cycle.
- EXECUTE twice with same keys → should not double-write conflicting evidence; append with timestamp if needed.
- Store dispatchId in EXEC-REPORT and Orca task metadata when available.
