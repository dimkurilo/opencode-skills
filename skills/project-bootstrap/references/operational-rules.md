# Operational Rules — Canonical Reference

> Канонические operational rules для embedding в generated AGENTS.md (multi-model project type).
> Source: production incident during a multi-model skill port.
> Применяются через `${OPERATIONAL_RULES_MULTI_MODEL}` placeholder в `AGENTS.md.tmpl`.

---

## Когда включать

`classify_project.sh` детектит multi-model project type по сигналам:
- В проекте есть `.agents/skills/multi-model-orchestration/` или ссылка на него
- В AGENTS.md упоминаются `orca orchestration`, `dispatch --inject`, `worker_done`
- Project type = `agent` или гибрид с agent-составляющей

Для trivial / single-model / content-only проектов — правила **опускаются** (negative path).

---

## 3 Iron Rules (IF-THEN, primacy + recency)

### Rule 1 (worker_done rule): worker_done требует обязательный `--to`

**IF** sendишь `worker_done` (или heartbeat/escalation) через `orca orchestration send`
**THEN** ОБЯЗАТЕЛЬНО включай `--to <coordinator-handle>` в CLI

**Без --to:** orca возвращает msg ID (выглядит как успех: `Sent msg_<id>`), но message уходит в void route. Координатор никогда его не получит.

**Пример (правильно):**
```bash
orca orchestration send --to <COORDINATOR-HANDLE> --type worker_done \
  --subject "PASS — 7 paths modified" \
  --body "<3-sentence summary>" \
  --task-id <TID> --dispatch-id <DID> \
  --files-modified "path/a,path/b" \
  --json
```

**Anti-pattern (нарушение):**
```bash
# НЕПРАВИЛЬНО — пропущен --to, msg уйдёт в void
orca orchestration send --subject "PASS" --body "..." --task-id <TID> --json
```

**Source:** production incident — reviewer реконструировал `orca orchestration send` из памяти, пропустил `--to`, message потерян. Координатор стал messenger'ом (paste verdict manually).

**Per-family blind spot:** некоторые worker-families имеют склонность реконструировать send-команды из памяти, а не copy из brief. Другие нативно понимают lifecycle (меньше риск) или выполняют brief буквально. Для reconstruct-prone workers — обязательно explicit example в brief.

---

### Rule 2 (verify-arrival rule): Verify delivery via global inbox, не trust terminal output

**IF** после `check --wait` получил `Sent msg_...` в terminal output (или ждёшь worker_done)
**THEN** НЕ доверяй handle-scoped `check`. Верифицируй delivery через **GLOBAL inbox**, фильтруя по payload taskId.

**Reason:** две независимые причины, по которым handle-scoped `check` (`--peek/--unread/--all`) НЕ показывает worker_done, хотя сообщение существует:
1. **Route void** — `orca orchestration send` возвращает msg ID **даже когда delivery fails** (пропущен `--to`). Terminal "Sent msg_..." ≠ proof of delivery.
2. **Handle drift / self-send** — `check` = handle-scoped ("every message for the handle"), `inbox` (без `--terminal`) = runtime-global ("across recipients"). `check` пропускает сообщение, если (a) оно адресовано на **STALE handle** координатора (handle drift после рестарта терминала — pane получает новый handle), или (b) это **self-send** (stored `from == to`, напр. worker в терминале координатора без `--from`). Оба случая дают `check=0` при `inbox=N`.

**Protocol:**
```bash
# Step 1: dispatch + wait
# ... (dispatch sequence) ...
orca orchestration check --wait --types worker_done,escalation,decision_gate --json

# Step 2: verify delivery через GLOBAL inbox (не handle-scoped check!)
orca orchestration inbox --limit 20 --json | jq '.result.messages[] | select(.type=="worker_done") | select(.payload|contains("<TASK_ID>"))'

# Step 3 (optional cross-check): handle-scoped queue
orca orchestration check --peek --json | grep -A 2 "worker_done"
```

**Decision branch:**
- **inbox показывает worker_done с нужным taskId, но `check --wait` его не вернул** → handle вашего терминала изменился (restart) ИЛИ self-send. Recovery:
  1. Re-resolve handle: `orca terminal list --worktree active --json`
  2. Сравни `to_handle` сообщения (из inbox) с текущим handle координатора; mismatch = handle drift. Проверь orphan: `orca terminal list --json | grep <to_handle>` → нет live pane = stale.
  3. При необходимости re-dispatch активных задач, чтобы workers получили НОВЫЙ handle; или читай mail через `inbox` + payload taskId/dispatchId фильтр.
  4. Self-send prevention: workers ставят explicit `--from <own-handle>`, не полагаются на auto-resolve из shared/coordinator терминала.
- **inbox НЕ показывает worker_done с нужным taskId** → реальный routing miss. Recovery:
  1. `terminal read --terminal <worker_handle>` — что worker реально сделал
  2. Если worker напечатал report как текст, но не sendил через CLI → `terminal send`: "Отправь worker_done через `orca orchestration send --to <COORDINATOR-HANDLE> --from <YOUR-HANDLE> --type worker_done ...`. Текстовый отчёт в чат = FAILURE."
  3. Если worker sendил но без `--to` → re-dispatch с explicit example в brief (Rule 1 fix)

**Source:** production incident + routing investigation: `check`=handle-scoped vs `inbox`=global; доказано self-send skip + stale-handle invisibility (message → orphaned handle).

---

### Rule 3 (writer-swap rule): Writer swap protocol на API retry storm

**IF** worker в terminal output показывает API retry attempt #5+ (например: `Request Timeout: request timeout [retrying in 8s attempt #10]`)
**THEN** НЕ жди до упора и НЕ redo-from-scratch. Выполни swap protocol:

**Step 1:** Terminal read
```bash
orca terminal read --terminal <worker_handle> --json
```

**Step 2:** File inspection
```bash
git diff --stat
# или
git status --short
```

**Step 3:** Decision branch
- **IF files modified match expected scope** (например 7 paths) → writer сделал работу, но не может signal.
  - Action: Ctrl-C worker terminal
  - Dispatch NEW writer terminal с brief "verify + finalize" (НЕ redo from scratch)
  - Fresh writer runs: lint × 3, git diff review, sends worker_done
- **IF files НЕ modified или partially** → writer не сделал работу.
  - Action: Ctrl-C, re-dispatch from scratch с возможным другим model (cross-family swap)

**Step 4:** Document в handoff: что произошло, какой branch выбран, reserve dispatch использован.

**Source:** production incident — primary writer applied 6 items but stuck on retry #10 without `worker_done`. Fallback writer verify+finalize brief succeeded in 5 min. Если бы координатор сделал redo-from-scratch → потерял бы всю работу primary writer.

---

## Включение в generated AGENTS.md

При генерации AGENTS.md для multi-model project type:

**ПРЕАМБУЛА** (primacy-зона): 3 правила в формате IF-THEN с incident anchor:
```markdown
➡ Sendишь worker_done?
   → ОБЯЗАТЕЛЬНО: `--to <coordinator-handle>`. Без него msg уходит в void route.
   → Source: incident — message потерян (пропущен `--to`).

➡ После `check --wait` получил "Sent msg_..."?
   → НЕ trust handle-scoped check. Верифицируй через GLOBAL inbox (`orca orchestration inbox --limit 20 --json`, фильтр по taskId).
   → `check` пропускает worker_done при handle drift (stale recipient) и self-send (from==to): check=0, inbox=N.
   → Source: incident + routing investigation.

➡ Worker на API retry #5+?
   → НЕ redo. СНАЧАЛА: terminal read → git diff → verify+finalize brief, не redo.
   → Source: incident — fallback writer verify+finalize в 5 мин после retry storm.
```

**CLOSING ANCHORS** (recency-зона): 3 однострочных compressed версии:
```markdown
➡ worker_done: `--to <coordinator-handle>` обязательно (Rule 1, incident).
➡ После `check --wait` → verify delivery через GLOBAL inbox (фильтр taskId), не handle-scoped check; check=0/inbox=N ⇒ handle drift или self-send (Rule 2, incident).
➡ API retry #5+ → terminal read → file inspect → verify+finalize (Rule 3, incident).
```

**Per-family blind spots note** для reconstruct-prone workers (опционально, в §1 Gotchas):
```markdown
| Some family workers | Реконструирует send-команды из памяти, пропускает `--to` | Всегда explicit example в brief + verify через check --peek |
```

---

## References

- `<wave>/iterations/<iteration>-fix.handoff.md` — исходные 3 rule definitions с incident evidence
- `skills/multi-model-orchestration/references/worker-contract.md` — inject preamble (где `--to` в CLI примере нужно усилить bold)
- `skills/multi-model-orchestration/references/failure-handling.md` — где "Message routing void" failure mode нужно добавить
- (production incident) — incident source for the 3 operational rules
