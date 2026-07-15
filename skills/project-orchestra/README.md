# project-orchestra

🇷🇺 [Русская версия](README.ru.md)

A skill for people who run **several AI agents** on one product: one leads, one builds, one reviews - so folders and chats do not turn into soup.

Works with OpenCode, Grok, and other CLIs that read `SKILL.md`.

**Version:** 0.6.0 · **License:** MIT

---

## Do I need this?

**Probably yes** if:

- Two or more agents (or two different models) touch the same product.
- You work in **chunks**: plan, then “ok, build”, then a short report - not one endless chat for everything.
- Themes live as **subfolders** (optimize, landing, CRM, audit), but **project memory is shared** - not a second “brain” in every folder.
- You want “we agreed” to live in a **file**, not only in last week’s chat.

**Probably no** if:

- You need one already-approved line change.
- You need a home for a **single** agent with long rules - use [project-bootstrap](../project-bootstrap/). This skill still has a short path: four files (`bootstrap-lite`).
- You want an SEO playbook (titles, speed, content). This skill is about **how agents work together**, not SEO. Domain skills come after the “office” exists.
- You want a **new skill name** for every kind of task. Here it is the opposite: one entry - `/project-orchestra`.

---

## What it is for

Without shared rules, this is common:

| What happens | What you get |
|--------------|--------------|
| Every project reinvents roles and folders | Agents overwrite each other |
| Agreement stayed in chat | Nobody remembers what was approved |
| Two agents edit the same status file | Noise in status and memory |
| Two bare `opencode run` in parallel | DB lock, weird failures |
| You juggle wave-spec, bootstrap, orchestra | Three names, one mess |

The skill gives a **shared folder language** and simple rules for **who may write what**.

### Where the ideas come from

Not a textbook. Real multi-CLI work that falls apart without light discipline.

What we kept:

- First look at tools you actually have (CLIs, skills, MCP), then assign roles. The “fanciest” model is not automatically boss.
- Heavy multi-model architecture panels are for **new** domains. If you already did this kind of work, skip the museum.
- A chunk of work: plan, review, do, handoff. After “go”, prefer a **new session**, not one eternal chat.
- Important claims: check with a **different** model family when you can.
- One product keeps **one** operational memory (HANDOFF / MEMORY). Themes are subfolders, not a second project by default.

### Why this shape

We compared fat “absorb everything” skills, three or four skill names, and “templates only, no rules”. The compromise: **one name**, with themes, waves, and two-model review inside. We did **not** swallow wave-spec whole: if it is installed, call it; if not, use templates here. Easier to roll back, fewer names to remember.

---

## How I actually use this

Not a product brochure. Day-to-day work. `project-orchestra` matches that order: one entry, waves, a “go” file, two-model review. Without a place where several agents sit side by side, half of the skill is theory.

### Orca - where I run it

I deliberately recommend **[Orca](https://onorca.dev)** ([repo: stablyai/orca](https://github.com/stablyai/orca)). They call it an ADE - an environment **for agents**, not “yet another code editor”. Their pitch matches what I needed: IDEs were built for you; an ADE is for you **and** your agents (separate working copies, terminals, browser, CLI in one app). Plus *bring your own agent / subscription*: Claude Code, Codex, OpenCode, Grok and other CLIs side by side on **your** plans.

Why I stick with it:

1. **Several agents at once without circus.** When I need two different reviews, I open two terminals in Orca, pick which agent and which model, and wait for answers as **files on disk**. Two bare `opencode run` processes used to lock the DB for me - I am done with that.
2. **Projects and working copies in one window.** I am not hunting which iTerm tab is DeepSeek.
3. **The `orca` command.** The lead agent can create a terminal and send a task there - useful when the skill says: two workers, different jobs (one checks facts, the other looks for what breaks).
4. **Different CLIs under one shell.** Grok, Claude Code, OpenCode - I do not hop apps every hour.

**What I like:**

- multi-agent layout is actually manageable;
- open source (MIT), public site and releases;
- phone app - sometimes I check status when I step away;
- does not force “their” model - you bring CLIs and keys.

**What frictions:**

- another layer on top of a plain terminal. One forever-agent setup may not need it;
- the product moves fast; UI habits shift;
- separate worktrees and terminal handles take a week to feel natural;
- Orca does **not** replace discipline (the “go” file, STATUS, HANDOFF). It only **carries** that discipline.

One line: the skill says *what* to do. Orca is *where* several agents can live without colliding.

- site: [onorca.dev](https://onorca.dev)
- code: [github.com/stablyai/orca](https://github.com/stablyai/orca)

### Models I run

I do not sit on one model. Current set:

| Where | What | Why |
|-------|------|-----|
| **Grok 4.5** (native build) | Often lead / long sessions | Fast think-write-check loop |
| **Claude Code** | Lead on **GLM 5.2** (and when the Claude Code shell fits better) | Different head and UX; good for plan + workers |
| **OpenCode** | **GLM 5.2**, **DeepSeek V4 Pro** (others as needed) | Workers: checklist check, “what breaks”, implement |

Why not “Claude everywhere” or “Grok everywhere”:

- **Different families** for two-model review. DeepSeek and GLM often complement each other: one holds the checklist and evidence, the other breaks “what if we ship”.
- **Lead** is usually Claude Code (often GLM 5.2) **and/or** Grok 4.5 in the native build. Whichever has less friction that day. Not a religion.
- **Personal agent instructions** (roles, AGENTS, personas) stay **private**. The public skill only ships the skeleton: modes, stamp, who may write what, Orca recipe. The kitchen of prompts is mine.

Short: *several shells + several model families + Orca as the table so they do not collide*.

---

## Folder model

```
project (whole product)
├── AGENTS, HANDOFF, MEMORY, SPEC…   - shared brain
├── optimize/                        - theme of work
│   └── waves/2026-07-15-…/          - one chunk: plan, “go” file, report
└── landing/
    └── waves/…
```

| Layer | Plain words | Mode |
|-------|-------------|------|
| **Project root** | Whole product, shared rules and memory | `full` or `bootstrap-lite` |
| **Theme** | Topic subfolder (not necessarily its own git) | `workstream-new` |
| **Wave** | One finished chunk of work | `wave`, then review, then execute |

---

## What happens when you run it

1. The agent **looks** at the current folder (git optional - files are enough).
2. It writes a short “what I see” and a proposal.
3. If something is unclear - **up to five questions** (full office or four files, which root, one model or several, prod risk, which theme).
4. You confirm the mode.
5. Files appear and checks run. Done means artifacts and green checks, not vibes.

You can skip most questions: “new theme optimize” or “four files only”.

---

## Modes

| Mode | One line |
|------|----------|
| `full` | Full multi-agent office |
| `bootstrap-lite` | Exactly four files: AGENTS, HANDOFF, MEMORY, gitignore |
| `workstream-new` | New theme folder under an existing project |
| `wave` | Draft the wave plan (wave-spec if present, else templates) |
| `raeh-review` | Review until “go” (stamp + hash) |
| `raeh-execute` | Do the approved plan; write the report |
| `install-dialects` | Role prompt cheatsheets only |
| `extend` | Patch an existing setup: roles, waves, cleanup |

---

## When it helps - and when it does not

| Situation | Helps? | Note |
|-----------|--------|------|
| Several agents, unclear who leads | Yes | `full` or `extend` |
| Product exists, new multi-session theme | Yes | theme, then wave |
| Plan, two-model review, work with a report | Yes | stamp + two models |
| Empty folder, “just agent files” | Yes, short path | `bootstrap-lite` |
| Full SEO methodology | Not alone | Office first, then SEO skills |
| One approved line change | No | Overkill |
| “Ship to prod with no human” | No | Prod stays human |

---

## Install

### OpenCode

```bash
git clone git@github.com:dimkurilo/opencode-skills.git ~/Projects/opencode-skills
ln -sfn ~/Projects/opencode-skills/skills/project-orchestra \
  ~/.config/opencode/skills/project-orchestra
```

### Grok

```bash
ln -sfn ~/Projects/opencode-skills/skills/project-orchestra \
  ~/.grok/skills/project-orchestra
```

### Scripts

```bash
# four files
bash …/scripts/install_bootstrap_lite.sh /path/to/project "name"

# full office
bash …/scripts/install_project_os.sh /path/to/project "name"

# theme (root already needs AGENTS.md)
bash …/scripts/install_workstream.sh /path/to/project "theme-slug"
```

---

## Usage

```
/project-orchestra
```

Examples:

- “Look at this repo and suggest how to set agents up”
- “New theme optimize”
- “Plan the next wave in optimize”
- “Review wave waves/2026-07-15-p1”
- “Four files only”

---

## Related skills

| Skill | Role |
|-------|------|
| **project-bootstrap** | Rich home for one agent |
| **wave-spec** | If installed, helps draft a wave; else templates inside orchestra |
| **vs-architect** | Several solution options with weights |
| Domain skills (SEO, etc.) | After the office exists |

---

## Rules that matter

1. “Go” lives in the **stamp file**. Chat “ok, ship it” is not enough by itself.
2. Wave plan can be `.md` or `.xml` - both work for hashing.
3. The agent who **builds** does not edit STATUS, MEMORY, or HANDOFF - that is the lead’s job.
4. If two different models are required and you only have one family - write `DEGRADED_DUAL`.
5. Two agents in parallel: **two terminals in Orca**, not two bare `opencode run`.
6. No client hostnames or SEO doctrine inside this package.

Full agent protocol: [`SKILL.md`](SKILL.md). Refs: `references/`.

---

## Package layout

```
project-orchestra/
├── SKILL.md
├── VERSION
├── README.md / README.ru.md
├── scripts/
├── assets/templates/
└── references/
```

---

## Please do not

- Install full office when someone asked for four files.
- Create a theme folder when the root has no AGENTS yet.
- Treat chat agreement as enough to start execute.
- Run two same-model reviews and call it “two-model check”.
- Put SEO recipes or client site hostnames into the skill package.

---

## License

MIT - see [LICENSE](../../LICENSE) at the repo root.
