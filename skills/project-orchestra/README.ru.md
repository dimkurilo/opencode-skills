# project-orchestra — OS для multi-agent программ

🇬🇧 [English version](README.md)

**Развёртывает multi-CLI multi-wave «операционную систему» для AI-агентов** — роли, гейты, Stamp Dialogue, жизненный цикл R.A.E.H., диалекты диспатча, evidence plane — без повторного изобретения архитектуры на каждом проекте.

Работает с **OpenCode**, **Grok** и другими CLI, которые читают пакеты `SKILL.md`. Сосед [project-bootstrap](../project-bootstrap/) (простые single-CLI дома) и peer **wave-spec** (черновик SPEC/PLAN волны).

**Версия:** 1.0.0 · **Kit id:** multiagent-kit-1.0 · **Лицензия:** MIT

---

## Зачем это нужно

Одному агенту хватает AGENTS.md и MEMORY. **Мультиагентной программе** нужно больше:

- Кто оркестратор, кто executor, кто cross-аудитор?
- Как зафиксировать «AGREED» без театра в чате?
- Как гонять волны без одной вечной сессии?
- Как не включать 4-модельный architecture panel на каждый SEO/ops-проект?

Скилл упаковывает проверенный **Multi-Agent Kit**: сначала inventory harness, H-panel только при FIRST-контакте с доменом, L0 consistency до G0, file-backed stamp до execute.

## Когда использовать

| Ситуация | Этот скилл? |
|----------|-------------|
| Новая multi-CLI multi-wave программа | **Да** — mode `full` |
| «Кто должен оркестрировать?» / матрица ролей | **Да** — `roles-only` |
| Ревью волны / stamp / execute | **Да** — `raeh-review` / `raeh-execute` |
| Только cheatsheets диспатча | **Да** — `install-dialects` |
| Простой single-CLI агентский дом | **Нет** → [project-bootstrap](../project-bootstrap/) |
| Черновик SPEC.xml / PLAN.xml волны | **Нет** → **wave-spec**, потом stamp здесь |
| Однострочная правка уже approved | **Нет** |

## Режимы (modes)

| Mode | Область |
|------|---------|
| `full` | Фазы 0→4: discovery → architecture → wire R.A.E.H. → материализация OS → cleanup |
| `roles-only` | Матрица ролей + путь к program SPEC |
| `wire-raeh` | Установка waves/stamps без полного boot |
| `extend` | Добавить роли/CLI к существующей OS |
| `cleanup` | Архив journey, вычистить «музей» из AGENTS |
| `raeh-review` | Stamp Dialogue REVIEW |
| `raeh-execute` | EXECUTE только после stamp YES + hash |
| `install-dialects` | `prompts/_dispatch/` cheatsheets |

## Что появляется в проекте

```
<project>/
├── AGENTS.md, SPEC.md, INTENT.md, STATUS.md, plan.md
├── SESSION_HANDOFF.md          # gitignored, append-only
├── .agents/memory/MEMORY.md
├── prompts/_dispatch/          # executor / orchestrator / auditor / flash
├── waves/README.md + _template/  # REVIEW-STAMP, EXEC-REPORT, STATUS
├── audits/, docs/, research/
└── .gitignore
```

Архитектура программы — в **SPEC.md**. Контракты волны (SPEC.xml + PLAN.xml) — из **wave-spec**.

## Ключевые идеи

| Идея | Правило |
|------|---------|
| **Harness > model** | Роли из inventory CLI/skills/MCP, не из «престижа» модели |
| **domain_novelty** | H-panel ON для FIRST, OFF для REPEAT |
| **L0 consistency** | Всегда до architecture G0 |
| **Stamp Dialogue** | Stamp на диске — источник правды; chat «AGREED» не считается |
| **R.A.E.H.** | Review → Agree → Execute → Handoff; новая сессия на волну |
| **Write locks** | Executor не правит STATUS/MEMORY |
| **F-04** | Cross-audit **другой** семейством моделей |

## Установка

### OpenCode

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills

# symlink (рекомендуется — обновляется через git pull)
ln -sfn ~/Projects/opencode-skills/skills/project-orchestra \
  ~/.config/opencode/skills/project-orchestra

# или копия
cp -R ~/Projects/opencode-skills/skills/project-orchestra \
  ~/.config/opencode/skills/project-orchestra
```

### Grok

```bash
ln -sfn ~/Projects/opencode-skills/skills/project-orchestra \
  ~/.grok/skills/project-orchestra
```

### Развернуть OS в целевой проект

```bash
bash ~/.config/opencode/skills/project-orchestra/scripts/install_project_os.sh \
  /path/to/project "my-program"

bash ~/.config/opencode/skills/project-orchestra/scripts/verify_os_gate.sh \
  /path/to/project
```

## Использование

Вызови скилл (slash или естественный язык):

```
/project-orchestra
```

Примеры:

- «Разверни multi-agent program OS для этого репо»
- «Кто должен оркестрировать — Claude или Grok?»
- «Сделай R.A.E.H. review для waves/2026-07-13-p1»
- «Поставь только dispatch dialects»

Агент следует `SKILL.md`: classify → inventory → phases/modes → templates → verify-скрипты.

## Скрипты (гейты)

| Скрипт | Назначение |
|--------|------------|
| `classify_program.sh` | multi-agent vs single-home; novelty hint |
| `inventory_harness.sh` | CLI, skill roots, MCP-конфиги |
| `install_project_os.sh` | копирование шаблонов в проект |
| `verify_os_gate.sh` | готовность OS (Phase 3) |
| `verify_l0_inputs.sh` | список канон-файлов для L0 |
| `verify_handoff_gate.sh` | разделение AGENTS / HANDOFF / MEMORY |
| `verify_raeh_ready.sh` | наличие waves/_template |
| `verify_stamp_schema.sh` | обязательные поля REVIEW-STAMP |
| `hash_acceptance.sh` | sha256(SPEC+PLAN) → acceptance.hash |

Все поддерживают `--help` и exit 0 при успехе.

## Структура пакета

```
project-orchestra/
├── SKILL.md                 # Entry для агента (modes, phases, gates)
├── VERSION                  # 1.0.0
├── agents/openai.yaml       # UI metadata
├── scripts/                 # 9 gate/install скриптов
├── assets/templates/        # OS + waves + dispatch profiles
└── references/              # Progressive disclosure (stamp, R.A.E.H., L0, …)
```

## Связь с другими скиллами

| Скилл | Связь |
|-------|--------|
| **project-bootstrap** | Только single-CLI agent homes |
| **wave-spec** | Черновик INTENT → SPEC.xml → PLAN.xml; этот скилл stamps/executes |
| **vs-architect** | Опциональный helper в Phase 0 |
| Доменные (`/seo`, …) | После готовности OS — не вшиваются в kit |

## Анти-паттерны

- H-panel на каждом REPEAT_DOMAIN проекте  
- Пропуск L0 «потому что файлы выглядят ок»  
- Chat AGREED без stamp YES  
- Вставка полного AGENTS.md в каждый worker dispatch  
- Executor правит STATUS/MEMORY  
- Доменные hostname’ы внутри пакета скилла  

## Лицензия

MIT — см. корневой [LICENSE](../../LICENSE).
