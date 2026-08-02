# Model Card — Multi-Model Orchestration ([platform])

> **What this IS:** Evidence-based role map. 30-second reference: who does what, what to never confuse.
> **What this is NOT:** Capability rankings. ★★★★★ beauty contests. Roles differ, not "smarter."

Source: I3–[TICKET] post-mortems. Self-contained — reads without [client-project] checkout.
Updated: 2026-07-26.

---

## Agent pins (launch from this skill alone)

> **Правило доступности:** перед запуском любой модели проверить её статус в этой таблице.
> Доступность может меняться (временные ограничения тарифа, новые лимиты).
> Модель помечена ⚠️ — временно недоступна, использовать замену.
> Модель без пометки — доступна, запускать по указанному пину.

| Model | Family | Pin / CLI | Launch (Orca terminal or shell) |
|-------|--------|-----------|----------------------------------|
| **Qwen 3.8 Max** | Alibaba | OpenCode agent **`A/agent1st_qwen-3.8`** (versionless) | `opencode --agent A/agent1st_qwen-3.8` |
| **Qwen Code** | Alibaba | **Separate CLI** `qwen` (NOT an OpenCode agent) | `qwen --approval-mode yolo` |
| **GLM 5.2** | Zhipu | OpenCode `A/agent1st_v13-glm` | `opencode --agent A/agent1st_v13-glm` · fallback model: `-m zai-coding-plan/glm-5.2` |
| **DeepSeek V4 Pro** | DeepSeek | OpenCode `A/agent1st_v36-pro` | `opencode --agent A/agent1st_v36-pro` · if agent not found: `opencode -m opencode-go/deepseek-v4-pro` |
| **DeepSeek V4 Flash** | DeepSeek | OpenCode `A/agent1st_v36-flash` | `opencode --agent A/agent1st_v36-flash` · fallback: `-m opencode-go/deepseek-v4-flash` |
| **Codex 5.5** | OpenAI | **Native Codex CLI** (not an OpenCode `A/` agent) | `orca terminal create --command "codex" --json` · or shell `codex` · optional: `codex --model gpt-5.5` / effort flags per host |
| **Grok 4.5** | xAI | Orchestrator / Grok CLI | Coordinator session (this skill). Worker research: host Grok CLI if available — **not** for product implement. |

**OpenCode agents** live under `~/.config/opencode/agents/` (nested `A/` → launch name **`A/<stem>`**, e.g. `A/agent1st_qwen-3.8`).  
**Qwen versionless pin:** skills always pin `A/agent1st_qwen-3.8`. Versioned `v5.1` / `v5.2` files may remain as history/rollback only. Protocol patches (incl. written≠persisted) live **inside the agent file** — bumping protocol does not require a skill edit.

**Codex is not a missing pin:** it is **outside** OpenCode agent files. Security gate and fidelity merge gate still **route to Codex 5.5** via the native Codex CLI above. Do not invent a fake `A/agent1st-codex` unless the host actually provides one.

**written≠persisted is a skill-wide worker gate**, not only a Qwen patch — see `worker-contract.md` and SKILL.md §2d.

---

## Qwen Code (separate CLI — NOT an OpenCode agent)

| Parameter | Value |
|-----------|-------|
| **CLI** | `qwen` (separate binary) |
| **Family** | **Alibaba** |
| **Launch** | `qwen --approval-mode yolo` |
| **Effort** | `/effort medium` (implement) · `/effort high` · `/effort xhigh` (review) · `/effort max` |
| **Orchestration** | Native: worker_done, heartbeat, escalation |
| **Approval** | `--approval-mode yolo` MANDATORY for Orca worker |
| **Role** | Primary coder (medium effort) |
| **Cross-family review** | Reviewer: DeepSeek Pro (DeepSeek) or GLM 5.2 (Zhipu). NOT OpenCode Qwen (same family) |
| **Do not confuse** | OpenCode Qwen (`opencode --agent A/agent1st_qwen-3.8`) — different CLI, `/variants` instead of `/effort`, SAME family |

### Effort vs Variants (do not confuse!)

| CLI | Command | Values |
|-----|---------|--------|
| **Qwen Code** | `/effort` | `medium`, `high`, `xhigh`, `max` |
| **OpenCode** | `/variants` | `default`, `low`, `medium`, `xhigh` |

Both persist across sessions. Always set explicitly.

---

## 30-Second Role Table

| Model | Role | Не путать с | Evidence 1-liner |
|-------|------|-------------|------------------|
| **Qwen 3.8 Max** (`agent1st_qwen-3.8`) | Fidelity writer · RLS reviewer | General writer | [TICKET]: 5832-case byte-identical prompt matrix, 0 failures, build/tsc green. Best RLS alignment — caught `is_active_user()` MAJOR with concrete one-line fix. |
| **Qwen Code** (`qwen --approval-mode yolo`) | Primary coder (implement) · Native orchestration | OpenCode Qwen (same family, different CLI) | Native worker_done/heartbeat. `/effort` not `/variants`. `--approval-mode yolo` mandatory for Orca. Cross-family reviewer: DeepSeek Pro or GLM 5.2. |
| **GLM 5.2** | Multi-file writer (default) · Static parity reviewer (best in stack) | Sole reviewer | I4/I5: ~15 min multi-file implement, ~10 min fix-round, build green. [TICKET]: 40+ verification points, 9 functions byte-checked, 0 false positives — best static parity auditor. **Перед запуском проверить доступность** — возможны временные ограничения тарифа. При недоступности: DeepSeek V4 Pro или Qwen 3.8 Max. |
| **Codex 5.5** | Merge gate · Behavioral regression gate | "Just another reviewer" | I4: caught UNIQUE(user_id,nonce) cross-user MAJOR. [TICKET]: caught abort/cost MAJOR that GLM's static review missed. Best hosted-semantics gate in the stack — unique role, not redundant. |
| **DeepSeek V4 Pro** | Depth analyst · Race/ordering | Security gate · Sole merge gate | I4: best depth on 10-constraint matrix, resurrection races. But under-severity on RLS — rated disabled-user SELECT + global nonce as PASS/soft O* while Codex/Qwen independently rated MAJOR. |
| **DeepSeek V4 Flash** | Bulk · Hotfix · Simple edits | Multi-file writer · Fidelity writer | I3 post-mortem: edge-case SQL bugs after RLS changes, lock leaks after reorder, in-memory guards on serverless. "Almost right, then hotfix" — not primary on multi-file tasks. |
| **Grok 4.5** | Orchestrator | Implementer | [TICKET]: correct role lock, correct routing, correct synthesis. Never implements code — dispatch → wait → gate. **Orchestrator role is owner-pinnable (§Owner Pin below).** |

---

## Owner Pin (Writer Replaceability)

**Owner phrase instantly pins the session writer — no skill rewrite, no routing table change.**

- **«сейчас writer=Qwen»** → Qwen 3.8 Max is the writer for this session/wave. GLM becomes reviewer.
- **«сейчас writer=GLM»** → GLM 5.2 is the writer for this session/wave. Qwen becomes reviewer.
- **«сейчас writer=Pro»** → DeepSeek V4 Pro is the writer. Reviewer must be different family (GLM/Codex/Qwen).

Both confirmed fidelity-capable:
- [TICKET]: Qwen wrote 5832-case byte-identical prompt matrix · GLM reviewed static parity (0 false positives).
- I4/I5: GLM wrote multi-file architecture · Codex∥Pro reviewed (build green, fix-round ~10 min).
- [TICKET]: DeepSeek V4 Pro as orchestrator completed full cycle (dispatch→wait→verify→fix→re-dispatch) on 2 test waves.

The orchestrator reads the owner pin and routes accordingly. The model card documents current capability — it does not encode a permanent assignment.

## Owner Pin — Orchestrator (NEW)

**«сейчас orchestrator=X» instantly pins the session orchestrator. Default: Grok 4.5.**

- **«сейчас orchestrator=Grok»** → Grok 4.5 (default, xAI family, fastest dispatch)
- **«сейчас orchestrator=Pro»** / **«orchestrator=DeepSeek»** → DeepSeek V4 Pro (1M context, structured thinking, [TICKET] evidence)
- **«сейчас orchestrator=Qwen»** → Qwen 3.8 Max (2.4T weights, CoT, vision)
- **«сейчас orchestrator=GLM»** → GLM 5.2 (1M state continuity, Self-Harness. ⚠️ Watch: tool passivity, session drift, overthinking — agent anti-patterns §4.5). Best for architecture-heavy waves.

**Flash as orchestrator — mechanics only ([TICKET] T-Q2):** допускается как оркестратор-механик для волн по УЖЕ утверждённому PLAN: dispatch → wait → gate → test. НЕ для суждения/синтеза high-stakes (minority-first или внешний синтезатор), НЕ для multi-file writer (I3: almost-right-then-hotfix, model-card role = bulk/hotfix writer). Ограничения: no write вне тестов волны, no deploy, no paid/CRM, внешний верификатор существует.

The orchestrator pin affects:
- NEXT_SESSION copy-paste block format (Grok: Task/Autonomy, Pro: Задача/Где/Должно быть/Не трогать, Qwen: Context/Objective/Constraints, GLM: Goal/Context/Constraints/Done)
- LAUNCH.md default orchestrator in tools table
---

## Stack Composition

| Task type | Writer | Review | Notes |
|-----------|--------|--------|-------|
| **Implement (Qwen Code)** | Qwen Code (`qwen --approval-mode yolo`, `/effort medium`) | DeepSeek Pro (DeepSeek) or GLM 5.2 (Zhipu) | Cross-family mandatory. NOT OpenCode Qwen as reviewer (same Alibaba family). |
| **Fidelity port** | Qwen 3.8 Max (default) | GLM 5.2 ∥ Codex 5.5 | Dual review mandatory. Flash explicitly excluded (I3: simplifies). Writer ≠ reviewer — cross-family. |
| **Security / RLS / auth** | Codex + Qwen (parallel) | + Pro (depth supplement) | **Never Pro-only as sole gate** (I4 under-severity lesson). Pro = correctness/depth, not gate authority. |
| **Multi-file implement** (3+ files) | GLM 5.2 (default, owner can swap to Qwen) | Pro + Codex or Qwen Code | Writer ≠ reviewer mandatory. Owner pin overrides default. |
| **Deep race / ordering** | DeepSeek V4 Pro | Codex 5.5 (behavioral semantics) | Pro for depth on lock ordering, constraint matrices. Codex for hosted semantics — complementary. |
| **Bulk / hotfix** (1-2 files) | Flash | — | Solo OK for trivial. Not multi-file. |
| **Orchestration** | **Grok 4.5** (default) · **DeepSeek V4 Pro** · **Qwen 3.8 Max** · **GLM 5.2** ⚠️ | — | Owner pin (§below). Never implements (§3 role lock). GLM = architecture-heavy waves; ⚠️ tool passivity + drift. Evidence: [TICKET] — DeepSeek V4 Pro completed full orchestration cycle on 2 test waves. |

### Cross-family pairs (writer.family ≠ reviewer.family)

| Writer | Family | Valid reviewers | Invalid reviewers |
|--------|--------|----------------|-------------------|
| Qwen Code | Alibaba | DeepSeek Pro, GLM 5.2, Codex 5.5 | OpenCode Qwen (Alibaba) |
| Qwen 3.8 Max | Alibaba | DeepSeek Pro, GLM 5.2, Codex 5.5 | OpenCode Qwen (Alibaba) |
| GLM 5.2 | Zhipu | Qwen Code, DeepSeek Pro, Codex 5.5 | — |
| DeepSeek Pro | DeepSeek | Qwen Code, GLM 5.2, Codex 5.5 | DeepSeek Flash (DeepSeek) |
| Codex 5.5 | OpenAI | Qwen Code, GLM 5.2, DeepSeek Pro | — |

---

## Anti-Patterns

1. **Flash as multi-file writer** → I3: edge-case bugs, almost-right-then-hotfix. Flash = bulk/hotfix only.
2. **Pro as sole security gate** → I4: under-severity on RLS. Pro = depth supplement, not gate authority.
3. **Writer = reviewer (same model family)** → Blind-spot risk. Cross-family review mandatory for product code. Qwen Code writer + OpenCode Qwen reviewer = BOTH Alibaba = violation.
4. **Codex = "just another reviewer"** → Codex = the behavioral regression gate. [TICKET]: caught abort/cost MAJOR that GLM's static review missed. Unique role — "ещё reviewer" understates its gate function.
5. **Writer self-review** → No model reviews its own work on fidelity/security tasks. Dual review = different families.
6. **Pro-only merge decision** → Pro under-calls security severity. Merge decisions need behavioral semantics gate (Codex).
7. **written≠persisted** → Claim `worker_done` / CHANGES without `ls`/`git status` proof. [TICKET]: notes said model-card NEW while public path missing. Gate binds **all** workers (`worker-contract.md`).
8. **Qwen Code without `--approval-mode yolo`** → Blocks orca commands on confirmation prompts. Always `qwen --approval-mode yolo` for Orca workers.
9. **Launching model without checking availability** → Pins and availability change. Check this table before every launch. ⚠️ = temporarily unavailable.

---

## Evidence Anchors (Post-Mortem Sources)

- **I3 (Flash multi-file):** Full skeleton in ~11 min, but edge-case SQL bugs after RLS changes, lock leaks after reorder, in-memory guards on serverless. "Almost right, then hotfix" pattern → Flash excluded from multi-file writer role.
- **I4 (Pro under-severity):** Pro rated disabled-user SELECT and global nonce as PASS/soft O*. Codex and Qwen independently rated both as MAJOR. Pattern: Pro trends depth on correctness, under-calls security/behavioral severity. → Pro = depth supplement, never sole security gate.
- **[TICKET] (Qwen/Codex complementary):** Qwen wrote 5832-case byte-identical prompt matrix with 0 failures (fidelity writer confirmed). GLM reviewed 40+ static verification points with 0 false positives (static parity confirmed). Codex caught abort/cost MAJOR — a hosted-semantics regression that GLM's static-only review missed. Dual review = necessary, not redundant. Codex gate = complementary, not "just another review."
