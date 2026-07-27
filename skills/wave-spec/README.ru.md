# wave-spec

Портабельный plan-gate skill (vv-метод, мульти-CLI). INTENT → интервью → SPEC.xml + PLAN.xml → утверждение → брифинги воркеров → LAUNCH.md → STATUS/handoff → NEXT_SESSION. Универсальный: разработка, контент, порт скиллов, перевод, оркестрация, перестройка сайтов.

## Когда использовать

Используй при запуске спринта/волны или когда мультисессионная разработка/контент/порт скиллов/перевод не должна пропускать планирование. Работает в Grok, Claude Code, OpenCode, ZCode, Qwen Code — пишет файлы в проекте, не требует vv-opencode.

**НЕ используй** для тривиальных однострочных правок, уже одобренных пользователем.

## Ключевые возможности (v1.4)

- **Автогенерация LAUNCH.md (шаг 6b):** команды запуска воркеров из model-card.md + PLAN.xml roles, cross-family check (writer.family ≠ reviewer.family), шаблоны review brief по моделям (DeepSeek, GLM, Codex, Qwen Code), секция запретов, версионирование при смене ролей
- **Паттерн NEXT_SESSION (шаг 6c):** уникальные файлы `NEXT_SESSION_I{N}.md` на итерацию (никогда не перезаписывать), copy-paste блок с полным путём (формат по модели оркестратора), корневой указатель `NEXT_SESSION.md`, 10 итерационно-специфичных секций (без дублирования SKILL.md)
- **Итерационный handoff (шаг 7):** уникальные файлы `iterations/I{N}-<slug>.handoff.md`, корневой SESSION_HANDOFF.md только как указатель
- **Генерация linear-workflow (шаг 6d):** параметрический `.agents/rules/linear-workflow.md` из параметров волны, APPEND при новой волне в том же проекте
- **Чеклист валидации Linear:** проект, parent, формат title, русский язык, чеклисты, поток статусов
- **PLAN.xml `<roles>`:** оркестратор + экзекуторы с tool/agent/flags/effort/family + `<family_rule>`
- **Cross-family валидация:** writer.family ≠ reviewer.family в LAUNCH.md и anti-patterns
- **Post-mortem → skill update:** closeout checklist включает создание INTENT.md для улучшений скиллов

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
- `assets/templates/` — шаблоны INTENT, SPEC, PLAN, STATUS, брифа воркера, review synthesis, fix-round, ASSUMPTIONS, **LAUNCH.md**, **iteration-handoff.md**, **NEXT_SESSION.md**, **linear-workflow.md**
