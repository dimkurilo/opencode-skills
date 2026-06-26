# GRACE Anchors — Семантические якоря для MD-файлов

GRACE (GRepable Anchor Comments for Engineering) — inline-разметка внутри Markdown-файлов для машинного поиска. Позволяет `grep`'ать критические правила, триггер-контексты и модельно-специфичные блоки без чтения всего файла.

---

## Зачем

Агенты игнорируют MD-документацию до 50% времени (исследование: длинные MD-файлы теряют приоритет в attention). Inline-разметка читается 100% времени, потому что это часть основного текста, а не отдельный документ.

## Схема

### @rule — критическое правило

```markdown
<!-- @rule id="F-01" priority="critical" triggers="docker, restart, compose" model="deepseek" -->
## Правило: Всегда используй прямые docker-команды
docker-compose restart/logs/ps сломаны. Используй docker restart/logs/ps напрямую.
<!-- @rule-end -->
```

**Обязательные атрибуты:**
- `id` — уникальный идентификатор правила (формат: `X-NN` где X = категория, NN = номер)
- `priority` — `critical` | `high` | `medium` | `low`

**Опциональные атрибуты:**
- `triggers` — comma-separated ключевые слова для grep-поиска
- `model` — `deepseek` | `glm` | `universal` — для какой модели правило
- `applies_to` — glob-маски файлов

### @anchor — ссылочный якорь

```markdown
<!-- @anchor id="mysql-gotcha" triggers="MySQL, restart, force-recreate" -->
| Меняешь MySQL | Только `docker restart`, не `--force-recreate` |
<!-- @anchor-end -->
```

**Обязательные атрибуты:**
- `id` — уникальный идентификатор якоря

**Опциональные атрибуты:**
- `triggers` — comma-separated ключевые слова
- `model` — `deepseek` | `glm` | `universal`

### @section — структурная секция

```markdown
<!-- @section id="loaded-context" priority="high" -->
## Loaded Context — Progressive Disclosure
...
<!-- @section-end -->
```

## Grep-команды

```bash
# Все критические правила
grep -n '@rule.*priority="critical"' AGENTS.md MEMORY.md .agents/rules/*.md

# Всё про MySQL
grep -n '@anchor.*triggers=".*MySQL.*"\|@rule.*triggers=".*MySQL.*"' AGENTS.md .agents/rules/*.md

# Все правила для DeepSeek
grep -n '@rule.*model="deepseek"' AGENTS.md

# Все якоря с триггерами
grep -rn '@anchor.*triggers=' .agents/

# Валидация: проверить, что все @rule имеют @rule-end
diff <(grep -c '@rule ' AGENTS.md) <(grep -c '@rule-end' AGENTS.md)
```

## Где применять

| Файл | Якоря |
|------|-------|
| AGENTS.md | @rule (критические правила), @anchor (gotcha's), @section (структурные секции) |
| MEMORY.md | @anchor (CONFIRMED_FACTS, инструменты), @section (секции памяти) |
| general-rule.md | @rule (базовые правила), @anchor (анти-паттерны) |
| SESSION_HANDOFF.md | @anchor (ENVIRONMENT_NOTES, FILE:LINE_ANCHORS) |
| plan.md | @section (фазы) |

## Соответствие спецификации AGENTS.md

Спецификация AGENTS.md (Linux Foundation) гласит: «Agents MUST NOT require additional structure, metadata, or parsing beyond reading the file as text.»

**GRACE-якоря этому требованию соответствуют:**
- Якоря находятся внутри HTML-комментариев (`<!-- -->`) — это валидный Markdown, не требующий специального парсинга.
- При удалении всех HTML-комментариев (SMAC-стриппинг) файл остаётся полностью читабельным как обычный Markdown — ни одна инструкция не теряется.
- Якоря — это **grep-подсказки для людей**, а не требования к парсингу для агентов. Агент может игнорировать все `<!-- @rule -->` блоки и читать только видимый Markdown-текст.
- Наличие `@rule`/`@anchor` проверяется при верификации как рекомендация, а не как жёсткое требование.

## Ограничения

- Якоря — HTML-комментарии (`<!-- -->`), не видны в рендеринге.
- Не более 20 якорей на файл (перегрузка снижает эффективность).
- `id` должен быть уникален в пределах проекта.
- Не вставлять якоря внутрь кодовых блоков.
