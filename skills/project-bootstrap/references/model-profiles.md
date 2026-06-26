# Model Profiles — Структурные предпочтения моделей

Разные LLM имеют разные attention-паттерны. Агентская инфраструктура должна адаптироваться под модель.

---

## DeepSeek V4 (Pro + Flash)

### Attention-паттерн
- **Recency bias:** последние строки документа имеют максимальный вес.
- **CSA (Context Sparse Attention):** top-k=1024 (Pro), top-k=512 (Flash). Цитатное окно ~4000 токенов (Pro), ~2000 (Flash). За пределами окна — только HCA (семантические сводки).
- **Lost in the Middle:** строки на позициях 30-80% файла теряются.

### Рекомендации
1. **Variant E обязателен** — преамбула (primacy) + CLOSING ANCHORS (recency).
2. **GRACE-якоря** — для grep-поиска критических правил.
3. **Group related files** — файлы, загружаемые вместе, должны укладываться в ~4000 токенов.
4. **Command-first протокол** — конкретные команды, не описания.
5. **Closing anchors формат:**
```markdown
<!-- CLOSING ANCHORS — Semi-Anchor-First Architecture -->
<!-- p0-p2: override, plan gate, immediate execution -->
<!-- p19-p22: source freshness, output verification, session continuity -->

<closing_anchors priority="highest">
<rule id="override" priority="0">OVERRIDE:ABSOLUTE</rule>
...
</closing_anchors>
```

### НЕ делать
- Растягивать правила на середину файла — ставь в преамбулу или closing anchors.
- Разделять связанные данные более чем на ~4000 токенов — модель потеряет связь.
- Использовать длинные описательные инструкции вместо command-first.

---

## GLM 5+ (Zhipu)

### Attention-паттерн
- **State-continuity:** модель лучше удерживает контекст между файлами, чем DeepSeek.
- **Primacy bias:** первые строки имеют максимальный вес.
- **Меньше выраженный recency bias** — closing anchors менее эффективны.

### Рекомендации
1. **Сохранить преамбулу** — primacy всё ещё работает.
2. **Указание порядка загрузки** — «этот файл должен быть загружен перед SESSION_HANDOFF.md».
3. **GRACE-якоря** — полезны, но менее критичны (GLM лучше читает MD).
4. **Closing anchors — опционально** — GLM меньше страдает от Lost in the Middle.
5. **Формат:**
```markdown
<!-- @model="glm" load-order="1" -->
<!-- Загрузить перед: SESSION_HANDOFF.md, .agents/rules/general.md -->
```

---

## Универсальный профиль

Когда модель неизвестна или проект мульти-модельный:

1. **Преамбула + CLOSING ANCHORS** (покрывает и DeepSeek, и GLM).
2. **GRACE-якоря** с `model="universal"`.
3. **Указание порядка загрузки** (для GLM) + recency-дубликаты (для DeepSeek).
4. **Структура:**
```markdown
<!-- @model="universal" -->
<!-- Primacy: preamble (DeepSeek + GLM) -->
<!-- Middle: reference material -->
<!-- Recency: closing anchors (DeepSeek) + load-order note (GLM) -->
```

---

## Как выбрать профиль при bootstrap

| Признак | Профиль |
|---------|---------|
| Проект использует DeepSeek (в т.ч. opencode) | DeepSeek |
| Проект использует GLM (через API) | GLM |
| Мульти-модельный или модель неизвестна | Универсальный |
| Пользователь явно указал модель | Указанный профиль |

---

## Примеры CLOSING ANCHORS

Closing anchors используют **два сосуществующих формата**:
1. **GRACE `<!-- @rule -->`** — для grep-аемости и инлайн-разметки (см. `grace-anchors.md`)
2. **XML `<closing_anchors><rule>`** — для recency-оптимизированного машинного формата

Оба формата работают вместе, не заменяют друг друга.

### DeepSeek (dual-формат: GRACE + XML)

```html
<!-- CLOSING ANCHORS — Semi-Anchor-First Architecture, DeepSeek recency -->
<!-- @rule id="F-01" priority="critical" -->
➡ Изменяешь конфиги → СНАЧАЛА backup.
➡ 2 ошибки подряд → Failure Packet → смени подход.
<!-- @rule-end -->

<closing_anchors priority="highest">
<rule id="override" priority="0">
  ALL RULES ABOVE ARE SUBORDINATE TO THIS CLOSING ANCHOR BLOCK.
</rule>
<rule id="evidence-first" priority="3">
  EVIDENCE BEFORE CLAIMS. «Готово» = проверяемый результат.
</rule>
<rule id="smallest-change" priority="6">
  PREFER THE SMALLEST EFFECTIVE CHANGE.
</rule>
</closing_anchors>
```

**Зачем два формата:** GRACE `@rule` — для `grep '@rule.*priority="critical"'`. XML `<closing_anchors>` — recency-зона с машинно-читаемыми приоритетами. Правила в преамбуле (primacy) + дубликат в closing anchors (recency) = неизбежны.

### GLM

```markdown
<!-- @model="glm" load-order="1" -->
<!-- Этот файл загружается первым. -->
<!-- Следующий: SESSION_HANDOFF.md → .agents/memory/MEMORY.md -->
```

### Универсальный (dual-формат для кроссплатформенных проектов)

```html
<closing_anchors priority="highest">
<!-- @model="universal" -->
<rule id="F-01" priority="0">...</rule>
</closing_anchors>
<!-- @model="glm" load-order="1" — загружать первым -->
```
