# Session policy

| Layer | Strategy |
|-------|----------|
| Program | Orchestrator session; STATUS/MEMORY owner |
| Wave **review** rounds 1..N | **Same** reviewer session |
| Wave **execute** after YES + verified hash | **Fresh** executor session |
| Flash pull | Stateless; no session |

Do **not** reuse the review session as the executor session after stamp YES.

Flush/persist decisions to disk before compact. Raw dumps live on disk, not in chat forever.
