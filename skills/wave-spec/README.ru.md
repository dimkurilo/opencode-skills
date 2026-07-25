# wave-spec

Портабельный plan-gate skill (vv-метод, мульти-CLI). INTENT → интервью → SPEC.xml + PLAN.xml → утверждение → брифинги воркеров → STATUS/handoff. Универсальный: разработка, контент, порт скиллов, перевод, оркестрация, перестройка сайтов.

## Когда использовать

Используй при запуске спринта/волны или когда мультисессионная разработка/контент/порт скиллов/перевод не должна пропускать планирование. Работает в Grok, Claude Code, OpenCode, ZCode — пишет файлы в проекте, не требует vv-opencode.

**НЕ используй** для тривиальных однострочных правок, уже одобренных пользователем.

## SoT + Symlink Layout

**Source of Truth (SoT):** `<repo>/skills/wave-spec/` — git-tracked.

**Хостовые symlink'и** (заменяют реальные директории на `ln -s` к SoT):

- `~/.grok/skills/wave-spec` → `<repo>/skills/wave-spec`
- `~/.config/opencode/skills/wave-spec` → `<repo>/skills/wave-spec`
- `~/.claude/skills/wave-spec` → `<repo>/skills/wave-spec`

## Жизненный цикл (одной строкой)

Implement done → In Review (dual review) → Commit → PR → Merge → Deploy probe (curl ≠ 404) → On prod (owner smoke OR RESIDUAL-RISK-OWNER-SMOKE) → Done. Никакой передачи «NEXT product», пока Deploy gate не пройден.

## Ссылки

- `references/program-maps.md` — domain-specific program maps (4 меню: skill-port, перевод, fidelity port, SEO)
- `references/vv-portability.md` — маппинг на тэги vv-opencode
- `assets/templates/` — шаблоны INTENT, SPEC, PLAN, STATUS, брифа воркера
