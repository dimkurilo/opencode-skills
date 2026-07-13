# Session policy

| Layer | Strategy |
|-------|----------|
| Program | Orchestrator session; STATUS/MEMORY owner |
| Wave review+exec | **One session per wave** |
| Review rounds 1..N | **Same** reviewer session |
| Flash pull | Stateless; no session |

Flush/persist decisions to disk before compact. Raw dumps live on disk, not in chat forever.
