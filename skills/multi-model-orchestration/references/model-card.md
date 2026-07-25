# Model Card — Multi-Model Orchestration ([platform])

> **What this IS:** Evidence-based role map. 30-second reference: who does what, what to never confuse.
> **What this is NOT:** Capability rankings. ★★★★★ beauty contests. Roles differ, not "smarter."

Source: I3–[TICKET] post-mortems. Self-contained — reads without [client-project] checkout.
Updated: 2026-07-26.

---

## Agent pins (OpenCode launch)

| Model | Agent file (SoT under `~/.config/opencode/agents/`) | Launch |
|-------|------------------------------------------------------|--------|
| **Qwen 3.8 Max** | **`A/agent1st_v5.2-qwen-3.8`** ← **current** (v5.1 retired for new work) | `opencode --agent A/agent1st_v5.2-qwen-3.8` |
| GLM 5.2 | `A/agent1st_v13-glm` | `opencode --agent A/agent1st_v13-glm` |
| DeepSeek V4 Pro | `A/agent1st_v36-pro` | `opencode --agent A/agent1st_v36-pro --model opencode-go/deepseek-v4-pro` |
| DeepSeek V4 Flash | `A/agent1st_v36-flash` | `opencode --agent A/agent1st_v36-flash --model opencode-go/deepseek-v4-flash` |

**Qwen v5.2 (2026-07-25/26):** absolute path  
`/Users/dimk/.config/opencode/agents/A/agent1st_v5.2-qwen-3.8.md`  
= v5.1 + JUDGMENT-layer patches from [TICKET] combat (R1–R6, RW1–RW9): runtime-boundary fidelity, writer self-skepticism, sibling consistency, evidence hygiene, fidelity temp, brief-as-plan gate, P17 ops, mechanism-vs-effect, cross-family pre-mortem, worktree hygiene, written≠persisted.  
**Do not launch `A/agent1st_v5.1-qwen-3.8` for new waves** — keep v5.1 only as historical reference on disk.

---

## 30-Second Role Table

| Model | Role | Не путать с | Evidence 1-liner |
|-------|------|-------------|------------------|
| **Qwen 3.8 Max** (`v5.2` agent) | Fidelity writer · RLS reviewer | General writer | [TICKET]: 5832-case byte-identical prompt matrix, 0 failures, build/tsc green. Best RLS alignment — caught `is_active_user()` MAJOR with concrete one-line fix. |
| **GLM 5.2** | Multi-file writer · Static parity reviewer | Sole reviewer | I4/I5: ~15 min multi-file implement, ~10 min fix-round, build green. [TICKET]: 40+ verification points, 9 functions byte-checked, 0 false positives — best static parity auditor. |
| **Codex 5.5** | Merge gate · Behavioral regression gate | "Just another reviewer" | I4: caught UNIQUE(user_id,nonce) cross-user MAJOR. [TICKET]: caught abort/cost MAJOR that GLM's static review missed. Best hosted-semantics gate in the stack — unique role, not redundant. |
| **DeepSeek V4 Pro** | Depth analyst · Race/ordering | Security gate · Sole merge gate | I4: best depth on 10-constraint matrix, resurrection races. But under-severity on RLS — rated disabled-user SELECT + global nonce as PASS/soft O* while Codex/Qwen independently rated MAJOR. |
| **DeepSeek V4 Flash** | Bulk · Hotfix · Simple edits | Multi-file writer · Fidelity writer | I3 post-mortem: edge-case SQL bugs after RLS changes, lock leaks after reorder, in-memory guards on serverless. "Almost right, then hotfix" — not primary on multi-file tasks. |
| **Grok 4.5** | Orchestrator only | Implementer | [TICKET]: correct role lock, correct routing (Qwen write · GLM∥Codex review), correct synthesis (stricter wins), clean handoff. Never implements code — dispatch → wait → gate. |

---

## Owner Pin (Writer Replaceability)

**Owner phrase instantly pins the session writer — no skill rewrite, no routing table change.**

- **«сейчас writer=Qwen»** → Qwen 3.8 Max is the writer for this session/wave. GLM becomes reviewer.
- **«сейчас writer=GLM»** → GLM 5.2 is the writer for this session/wave. Qwen becomes reviewer.

Both confirmed fidelity-capable:
- [TICKET]: Qwen wrote 5832-case byte-identical prompt matrix · GLM reviewed static parity (0 false positives).
- I4/I5: GLM wrote multi-file architecture · Codex∥Pro reviewed (build green, fix-round ~10 min).

The orchestrator reads the owner pin and routes accordingly. The model card documents current writer capability — it does not encode a permanent assignment.

---

## Stack Composition

| Task type | Writer | Review | Notes |
|-----------|--------|--------|-------|
| **Fidelity port** | Qwen 3.8 Max (default) | GLM 5.2 ∥ Codex 5.5 | Dual review mandatory. Flash explicitly excluded (I3: simplifies). Writer ≠ reviewer — cross-family. |
| **Security / RLS / auth** | Codex + Qwen (parallel) | + Pro (depth supplement) | **Never Pro-only as sole gate** (I4 under-severity lesson). Pro = correctness/depth, not gate authority. |
| **Multi-file implement** (3+ files) | GLM 5.2 (default, owner can swap to Qwen) | Pro + Codex | Writer ≠ reviewer mandatory. Owner pin overrides default. |
| **Deep race / ordering** | DeepSeek V4 Pro | Codex 5.5 (behavioral semantics) | Pro for depth on lock ordering, constraint matrices. Codex for hosted semantics — complementary. |
| **Bulk / hotfix** (1-2 files) | Flash | — | Solo OK for trivial. Not multi-file. |
| **Orchestration** | Grok 4.5 | — | Never implements (§3 role lock). |

---

## Anti-Patterns

1. **Flash as multi-file writer** → I3: edge-case bugs, almost-right-then-hotfix. Flash = bulk/hotfix only.
2. **Pro as sole security gate** → I4: under-severity on RLS. Pro = depth supplement, not gate authority.
3. **Writer = reviewer (same model family)** → Blind-spot risk. Cross-family review mandatory for product code.
4. **Codex = "just another reviewer"** → Codex = the behavioral regression gate. [TICKET]: caught abort/cost MAJOR that GLM's static review missed. Unique role — "ещё reviewer" understates its gate function.
5. **Writer self-review** → No model reviews its own work on fidelity/security tasks. Dual review = different families.
6. **Pro-only merge decision** → Pro under-calls security severity. Merge decisions need behavioral semantics gate (Codex).

---

## Evidence Anchors (Post-Mortem Sources)

- **I3 (Flash multi-file):** Full skeleton in ~11 min, but edge-case SQL bugs after RLS changes, lock leaks after reorder, in-memory guards on serverless. "Almost right, then hotfix" pattern → Flash excluded from multi-file writer role.
- **I4 (Pro under-severity):** Pro rated disabled-user SELECT and global nonce as PASS/soft O*. Codex and Qwen independently rated both as MAJOR. Pattern: Pro trends depth on correctness, under-calls security/behavioral severity. → Pro = depth supplement, never sole security gate.
- **[TICKET] (Qwen/Codex complementary):** Qwen wrote 5832-case byte-identical prompt matrix with 0 failures (fidelity writer confirmed). GLM reviewed 40+ static verification points with 0 false positives (static parity confirmed). Codex caught abort/cost MAJOR — a hosted-semantics regression that GLM's static-only review missed. Dual review = necessary, not redundant. Codex gate = complementary, not "just another review."
