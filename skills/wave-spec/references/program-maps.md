# Program maps (optional reference)

Use when kind=program for a multi-wave project. A **program** = workstreams + phase order + definition of done. This is a **menu**, not a mandatory checklist — pick phases from INTENT + evidence. Each domain-specific program map is one section.

## §1 Skill-port / orchestration program

For multi-skill portfolio development (e.g. opencode-skills), cross-platform fidelity ports (product → reference platform), and orchestration/skill-to-skill pipeline builds.

**Shape evidence:** [TICKET] waves in opencode-skills; [client-project] I0→I7 in [client-project].

### Typical workstreams

**Inventory + baseline:**
- Read existing skills, SKILL.md, README, templates
- Audit git log / changelog for recent changes
- Identify SoT paths and symlink targets

**Architecture / contract:**
- Define skill interface: frontmatter description triggers, modes, templates
- Document cross-skill boundaries (what delegates to what)
- Interface versioning (semver per skill)

**Fidelity port:**
- Parity matrix: reference→target platform (file:line)
- Behavioral equivalence: same inputs → same outputs
- Regression checklist per platform

**Review / lifecycle:**
- Dual review (GLM static parity ∥ Codex behavioral semantics)
- Deploy probe: file existence, route check, install-path verify
- Lifecycle gates: Implement → In Review → Commit → PR → Merge → Deploy → Done

**Dispatch / orchestration:**
- Worker brief templates, PARALLEL/DEPENDS annotation
- Orca dispatch commands (terminal create, send)
- STATUS.md tracking

### Wave sizing
- One wave = one skill or one cross-skill contract
- Inventory+baseline before architecture before port before review
- Parallel waves OK if artifact paths don't overlap

### Anti-patterns
- Implementing before SPEC/PLAN approved
- One PLAN with all skills — split by portfolio domain
- Skipping fidelity dual review for ports
- Claiming Done without deploy probe

---

## §2 Book multi-pass translation program

For translating a book through multiple quality passes: glossary extraction → draft translation (3 models × 3 passes) → literary adaptation → consistency QA → typesetting.

### Typical workstreams

**Glossary extraction:**
- Extract domain terms from source
- Build unified glossary (term → target language, notes)
- Freeze glossary before draft

**Draft translation (3 × 3):**
- 3 models produce independent drafts in parallel
- 3 passes: structural → semantic → stylistic
- Merge via synthesis (stricter wins on contradictions)

**Literary adaptation:**
- Native-speaker voice alignment
- Register consistency (formal/casual)
- Cultural references adaptation

**Consistency QA:**
- Term consistency against frozen glossary
- Cross-chapter coherence
- Regression on sections edited after merge

**Typesetting:**
- Target format prep (LaTeX, InDesign, Markdown→PDF)
- Index, TOC, cross-references
- Final proof

### Wave sizing
- Glossary + chapter 1–3 draft (pilot wave)
- Chapters 4–N draft (parallelizable by chapter)
- Literary + QA (sequential, depends on draft)
- Typesetting (final wave)

### Anti-patterns
- Starting translation without frozen glossary
- Merging passes without synthesis rules
- Parallel editors on same chapter

---

## §3 Product fidelity port program

For porting a product (SaaS, app, platform) from one stack to another with behavioral parity: reference behavior capture → parity matrix → incremental port → regression → deploy probe → dual review.

### Typical workstreams

**Reference capture:**
- API surface inventory (endpoints, methods, responses)
- Behavioral snapshot (input→output, edge cases)
- Auth/session/state model

**Parity matrix:**
- Feature × platform matrix with priority
- Risk assessment per feature (breaking, cosmetic, unknown)
- Ordering: highest-risk first

**Incremental port:**
- Phase 0: scaffolding, CI, deploy pipeline
- Phase 1: core domain (auth, data model)
- Phase 2: API surface
- Phase 3: UX/UI

**Regression + deploy probe:**
- Automated parity tests
- Deploy probe: curl new endpoints, verify response codes
- Owner smoke: manual verification on production

**Dual review:**
- GLM: static parity (file:line matrix, code structure)
- Codex/equivalents: behavioral semantics (hosted behavior, cost regressions)
- Synthesis: stricter wins, all MAJOR closed before In Review

### Wave sizing
- One wave = one phase (P0–P3)
- P0 scaffolding always first
- P1 core domain before P2 API before P3 UX

### Anti-patterns
- Single-model fidelity review (must be dual)
- Writer = reviewer (banned for fidelity ports)
- Deploy without probe (RESIDUAL-RISK-OWNER-SMOKE)

---

## §4 SEO site program (optional domain)

Use when the program target is a content-heavy site (e.g. WordPress + WooCommerce) with SEO as a primary goal. This section is the **optional SEO domain** — demoted from core narrative, preserved for practitioners who need it.

### Typical workstreams

**Tech:**
- Access: WP admin, hosting, GSC, Metrika, server logs
- Crawl inventory (Screaming Frog / equivalent)
- robots.txt, XML sitemaps, index bloat, noindex, canonicals
- Redirects, HTTPS, www/apex, pagination, facets
- Hreflang / multi-region if relevant

**Performance:**
- CWV / PageSpeed baselines (mobile + desktop key templates)
- Theme/plugin weight, images, caching, CDN
- Critical templates: home, category, product, cart

**On-page / schema:**
- Title/meta patterns for product, category, CMS pages
- Heading structure, thin/duplicate content policy
- Schema: Organization, WebSite, Product, Breadcrumb, FAQ where real
- WooCommerce specific: product SEO fields, brand, availability

**Content:**
- Category/commercial texts (not AI-slop; brand voice)
- Content hubs vs SKU pages
- Blog only if it supports money queries / GEO — not default busywork

**GEO / AEO:**
- AI bot access (robots for GPTBot etc.) — only after baseline
- Citation-ready expert pages, FAQ with real answers
- Earned media vs own blog priority per market research

**Analytics:**
- GSC property + sitemap submit
- Metrika goals / ecommerce
- Baseline report + monthly cadence

### Wave sizing
- One wave = one primary stream + at most one supporting stream
- Prefer "baseline crawl + indexation decisions" before mass content
- Schema/templates before bulk product text rewrites
- GEO after technical readability and a content place to publish

### Anti-patterns
- Starting with "10 GEO prompts" without crawl/index baseline
- Rewriting all product descriptions before template SEO
- Parallel workers editing the same theme files
- Fake KPI targets without GSC/Metrika baseline
