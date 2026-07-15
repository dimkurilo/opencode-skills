# Intake - study first, then ask

For humans and agents. Goal: **never silent wrong layout** on a new or existing folder.

## When

Every invocation of `/project-orchestra` unless the user already gave:

- exact **mode**, and  
- exact **paths**, and  
- no structural ambiguity  

Then you may skip questions and still do a **quick scan** for safety (existing OS? FORCE risk?).

## Step A - Study (no git required)

```
PROJECT_DIR = cwd (or user-given root)
```

Checklist (fast):

1. List top-level files/dirs.  
2. Presence of: `AGENTS.md`, `SESSION_HANDOFF.md`, `.agents/memory/`, `SPEC.md`, `STATUS.md`, `waves/`, workstream-like subdirs.  
3. If monorepo-looking: note packages / theme folders; **do not** deep-read everything.  
4. Optional: `bash scripts/classify_program.sh` + `inventory_harness.sh` when multi-agent is likely.

Write 3–6 lines of **findings** before questions.

## Step B - Propose

Example shape:

```text
Findings:
- Parent looks like code repo without agent OS.
- No waves/; no workstream STATUS folders.

Proposal:
- Mode bootstrap-lite (4 files) if you only need agent home today.
- Or mode full if you already know multi-CLI multi-wave is required.

Questions:
1. …
```

## Step C - Questions (cap 3-5)

| # | Question | Maps to mode |
|---|----------|--------------|
| 1 | Full OS / 4-file home / workstream / wave / stamp-execute? | full / bootstrap-lite / workstream-new / wave / raeh-* |
| 2 | Is this folder the program root? | parent path |
| 3 | One model or multi-family roles? | full vs lite; dual-review |
| 4 | One task vs multi-session program? | lite vs full / workstream |
| 5 | Prod / public / money this session? | dual-review gate |
| 6 | (If large) Which path/theme is in scope? | workstream slug / cwd |

Skip questions the scan already answered.

## Step D - Confirm and act

1. State `Mode: …` and files/dirs that will be created or changed.  
2. If overwriting or FORCE → human OK.  
3. Run scripts / copy templates for that mode only.  
4. Run the matching `verify_*.sh` and report pass/fail with paths.

## Defaults when user is vague

| Vague ask | Default proposal |
|-----------|------------------|
| “настрой агентов” / “bootstrap” on empty-ish repo | **bootstrap-lite**, mention full as upgrade |
| “workstream optimize” under existing AGENTS | **workstream-new** |
| “спланируй волну” | **wave** |
| “stamp / AGREED” | **raeh-review** |
| Existing full OS + “bootstrap again” | **refuse full**; offer wave / workstream / extend |

## Anti-patterns

- Calling `install_project_os.sh` when user wanted 4 files  
- Creating workstream without parent AGENTS (script refuses unless `ALLOW_NO_PARENT=1`)  
- Asking 10+ questions before reading the tree  
- Deploying while cwd is wrong subfolder without confirming root  
