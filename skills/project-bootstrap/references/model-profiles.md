# Model Profiles — Структурные предпочтения моделей

Разные LLM имеют разные attention-паттерны. Агентская инфраструктура должна адаптироваться под модель.

---

## DeepSeek V4 Flash (orchestrator + primary writer/coder)

### Attention-паттерн
- **Recency bias:** последние строки документа имеют максимальный вес.
- **CSA (Context Sparse Attention):** top-k=512. Цитатное окно ~2000 токенов. За пределами окна — только HCA (семантические сводки).
- **Lost in the Middle:** строки на позициях 30-80% файла теряются.

### Роль в стеке
- **Flash (`A/agent1st_v37.3-flash`) = оркестратор (по умолчанию) + основной writer/coder/тестер.** Полная роль оркестратора: dispatch → wait → gate → synthesize. Primary writer/coder: single-file, bulk code, тесты. Fast ($0.14/$0.28 per 1M), strong on 0731 benchmarks (SWE-bench 79.0 Flash-Max indep, LiveBench Coding 69.2).
- Роль-lock: не совмещает оркестрацию с написанием кода в одной задаче; переключение (оркестратор → writer) — явным owner-pin решением.
- Multi-file (3+) сложные правки → GLM 5.2 (default multi-file writer).

### Evidence status
- Role (оркестратор + writer) = owner decision + benchmark-supported (code confirmed: SWE-bench 79.0 Flash-Max indep, LiveBench Coding 69.2; **agentic/review NOT confirmed** — Terminal-Bench 2.1 / DSBench vendor self-reported, LiveBench Agentic Coding 37.6).
- Reasoning weak (GPQA-D 71.2 vs GLM 91.2, GPT-5.5 93.6) → review/judgment role не benchmark-supported.

### Рекомендации (Flash как оркестратор)
1. **Variant E обязателен** — преамбула (primacy) + CLOSING ANCHORS (recency).
2. **GRACE-якоря** — для grep-поиска критических правил.
3. **Group related files** — файлы, загружаемые вместе, должны укладываться в ~2000 токенов (Flash цитатное окно).
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
- Разделять связанные данные более чем на ~2000 токенов (Flash) — модель потеряет связь.
- Использовать длинные описательные инструкции вместо command-first.

---

## Qwen 3.8 Max (Alibaba) — reviewer / архитектор / бизнес-аналитик

> **Evidence status:** role = **owner decision + vendor benchmarks (qwen.ai/blog, 2026-08-03) + anecdotal/community evidence**; independent verification pending. Vendor benches: GPQA-D 92.6, Terminal-Bench 2.1 86.6, OSWorld-V 86.1, IFBench 82.8, SWE-bench Pro 67.7 (ниже Fable 5: 80.0). Owner empirical: level ~ Kimi K3, **сильнее GLM 5.2 в architecture и depth of thought**. ⚠️ **Do NOT confuse with Qwen 3.7 Max** (SWE-bench Verified 80.4, GPQA 92.4, Terminal-Bench 69.7 — ДРУГАЯ модель; «все цифры 3.8 в ранних обзорах — на самом деле 3.7» — Wiegold). Role = НЕ основной кодер (медленная); default reviewer/architect в текущем стеке.

### Спеки [GA blog qwen.ai/blog 2026-08-03; ранее docs.qwencloud.com 2026-07-19]
- **2.4T total sparse MoE, 95B active** (активные параметры раскрыты в GA-блоге).
- **Контекст: 1M токенов** (blog config `context_window: 1000000`; docs.qwencloud.com ранее указывал 983,616; max output 131,072).
- **Reasoning всегда включён** — `reasoning_effort` xhigh/medium/low, дефолт xhigh.
- **Мультимодальный ввод** — текст, изображения, видео, документы.
- Построен на архитектуре Qwen 3.5; model ID `qwen3.8-max`.

### Статус релиза (verified 2026-08-03)
- **GA-анонс: qwen.ai/blog 2026-08-03** («Qwen3.8-Max: A New Bar for Coding and Cowork»); доступен через QwenCloud API (`qwen3.8-max`) с 03.08.2026; превью в Token Plan / Qoder с 19.07.2026 (WAIC).
- **Первая open-weight модель Max-класса**: веса обещаны «next week» на Hugging Face / ModelScope (анонс 2026-08-03).
- **HF-репозитория на дату проверки НЕТ**: HF API возвращает 0 моделей, `Qwen/Qwen3.8-Max` → 401.
- Per-token цена официально НЕ опубликована; mirror: $2/$6/$0.25 cached per 1M [MarkTechPost, **unverified**]. Token Plan: Lite $6 / Standard ~$18-20 / Pro $68-70 в месяц.

### Vendor benchmarks (qwen.ai/blog, 2026-08-03; independent verification pending)
- **Judgment:** GPQA-Diamond **92.6** (GPT-5.6 Sol 94.1, Fable 5 92.6, Opus 4.8 92.0) — уровень GLM 91.2 / GPT-5.5 93.6.
- **Agentic:** Terminal-Bench 2.1 **86.6** (Claude Code harness, avg@10), OSWorld-Verified **86.1**, IFBench **82.8**, PaperBench **93.0**, Toolathlon 72.5, WideSearch 81.9.
- **Coding:** SWE-bench Pro 67.7 (ниже Fable 5: 80.0), DeepSWE 1.1 56.6, FrontierSWE 73.5 (Fable 5: 88.8); SWE-bench Verified НЕ опубликован.
- **Multimodal:** MMMU-Pro 82.3, MathVision 95.2/97.7, VideoMME 90.4, OmniDocBench 1.5 92.1.
- Все vendor self-reported; harnesses различаются по моделям (сравнения не apples-to-apples).

### Роль в стеке
- **Qwen 3.8 Max = reviewer / архитектор / бизнес-аналитик (default reviewer).** Архитектурные спецификации, cross-audit, бизнес-анализ, deep constraint analysis, RLS review.
- **НЕ основной кодер** — медленная для bulk-кода и single-file implement. Bulk-код и тесты → DeepSeek V4 Flash (default writer). Multi-file implement → GLM 5.2.
- Production-wave evidence: caught `is_active_user()` MAJOR с конкретным one-line fix; deep constraint analysis на race/ordering задачах.

### Anecdotal measurements (single runs, NOT reproducible)
- **Trilogy AI StackPerf**: 80/100 vs Kimi K3 83/100 — архитектурная задача, 269 файлов, 354 repo-цитаты, 0 failed tool-calls, tool-use 9/10; дольше и больше токенов, чем K3.
- **KingBench**: 65/80 — 2-е место за Fable 5 (community run).
- **36kr (22.07, китайское издание)**: выиграл 4/6 раундов против GLM-5.2 и Kimi K3 (быстрее всех, точнее определил текущие требования), **НО дал ФЕЙКОВОЕ решение** в раунде «карусель» (удалил drag, подделал loop).

### Сильные [anecdotal/community]
- Креатив / дизайн / письмо.
- Глубокие one-shot сборки.
- Архитектурный анализ с чистой tool-дисциплиной.
- Динамическое понимание требований.
- manish.sh: чёткое разделение наблюдение / инференс / догадка.

### Слабые [anecdotal/community]
- **ОЧЕНЬ медленный thinking для кода** — «slowest model I've used» (Wiegold); 20 мин thinking над лендингом (r/LocalLLaMA); «real slow, trade-off for precision» (r/Qwen_AI).
- **Галлюцинации / потеря задачи в длинных сессиях** — 3 раза подряд (r/Qwen_AI).
- **Фейковые решения при неясных требованиях** — раунд «карусель» (36kr).
- Подтверждает роль NE основной кодер.

### Сравнение (аналитики)
- **vs Kimi K3**: примерно на уровне (80 vs 83, один тест), но у K3 есть верифицированные данные (AAII 57, $3/$15, веса открыты), у Qwen — нет.
- **vs GLM 5.2**: по 36kr сильнее в динамике/понимании требований; GLM глубже в статике структуры. GLM 5.2 остаётся «доказанным» (AAII 51, Terminal-Bench 81.0).
- **Итог аналитиков**: «Kimi K3 — безопасный выбор сегодня; Qwen 3.8 — модель для наблюдения».

### Экономика [official]
- **Token Plan**: Lite $6, Standard ~$18-20, Pro $68-70 в месяц.
- Превью по 1/10 ставки, ночью до 1/50.
- **Per-token API-цены НЕТ** (не опубликованы).
- Owner subscription подтверждена.

### Attention-паттерн
- **Always-on reasoning with levels:** `/effort low|high|xhigh` (Qwen Code) или `/variants` (OpenCode). CoT встроен, работает нативно — глубина мысли (полезно для architecture/analysis).
- **Long context: 983,616 токенов** (НЕ 1M; max output 131,072). Лучше удерживает контекст между файлами, чем DeepSeek.
- **Native multimodal:** текст, изображения, видео, документы.
- **Primacy + recency:** первые и последние строки имеют максимальный вес; середина лучше, чем у DeepSeek.

### Рекомендации (как reviewer/архитектор)
1. **Architecture / synthesis briefs** — Qwen сильнее в целостном анализе, чем в детальной код-имплементации.
2. **Cross-audit спецификаций** — параллельный аудит архитектурных решений, Qwen находит architectural MAJOR'ы.
3. **Business analysis** — формулирование бизнес-требований, gap-анализ, переход от INTENT к SPEC.
4. **RLS / constraint analysis** — глубокий анализ гонок, ограничений, state transitions.
5. **Few-shot examples > constraints** — Qwen лучше учится на примерах, чем на запретах.
6. **CoT directive работает** — «разбери шаг за шагом» effective.
7. **Separators `###`** — помогают парсингу структурированного вывода.
8. **Остерегаться длинных сессий** — галлюцинации и потеря задачи (r/Qwen_AI, 3× подряд); разбивай на цепочку промптов с верификацией.

### НЕ делать
- Назначать Qwen основным кодером на bulk/single-file (медленная) — используй Flash.
- Назначать Qwen writer на multi-file implement (3+) — используй GLM.
- Доверять неясным требованиям без верификации — фейковые решения (36kr).
- Использовать `/think` `/no_think` директивы (игнорируются Qwen 3.8).
- Вставлять Chinese-bracket injection blocks `【】` — это DeepSeek-specific, Qwen игнорирует.
- Рассчитывать на preserved reasoning без вербализации — key state должен быть в content field.
- Цитировать цифры Qwen 3.7 Max как 3.8 (SWE-bench 80.4 / GPQA 92.4 / Terminal-Bench 69.7) — это ДРУГАЯ модель.

---

## GLM 5.2 (Zhipu) — multi-file writer + second-line reviewer / architecture

> **Evidence status:** role = benchmark-supported + owner decision. AAII 51 (open-weight leader, indep); GPQA-D 91.2; LiveBench 73.2 (indep). Default writer для multi-file implement (3+ файлов); second-line reviewer когда Qwen недоступен или для перекрёстной проверки architecture.

### Роль в стеке
- **GLM 5.2 = default multi-file writer (3+ файлов)** + second-line reviewer (architecture-heavy волны).
- 1M state continuity — удерживает контекст между файлами длинных сессий. Production waves: ~15 min multi-file implement, ~10 min fix-round, build green.
- Second-line reviewer когда Qwen недоступен или для перекрёстной проверки architecture (GLM = benchmark-supported static parity, 40+ verification points, 0 false positives).

### Attention-паттерн
- **State-continuity (1M context):** модель лучше удерживает контекст между файлами длинных сессий.
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

## GPT-5.5 (OpenAI) — security/behavioral gate

### Attention-паттерн
- **Lean contracts:** короткие чёткие контракты работают лучше длинных описательных.
- **Goal + Success несут нагрузку** — не требует детальных constraints, если goal/success чёткие.
- **Behavioral semantics focus:** лучше видит runtime-поведение (abort, cost, state transitions), чем static code structure.

### Рекомендации
1. **Lean brief format:** Goal → Success → Context → Constraints → Autonomy.
2. **Фокус на behavioral semantics** — не static parity (это работа GLM).
3. **`codex` native CLI** — не OpenCode-агент. Запуск: `codex` или `codex --model gpt-5.5`.
4. **Effort flags** — `--effort` или аналогичные per host настройки.

### НЕ делать
- Использовать как «ещё одного ревьювера» — GPT-5.5 = behavioral regression gate, уникальная роль.
- Framing как static code review — GPT-5.5 сильнее на runtime-semantics, слабее на byte-level parity.

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

## Benchmarks (2026-08-03)

Compact evidence snapshot. Profiles above document attention-паттерны; this section documents **what is benchmark-supported vs owner-decided**. Numbers collected 2026-08-03; **do not invent numbers beyond this table**.

| Model | Code (SWE-bench Verified / Pro) | Judgment (GPQA-Diamond) | Context / Agentic | Price (in/out per 1M, USD) | Source tags |
|-------|---------------------------------|-------------------------|-------------------|----------------------------|-------------|
| **DeepSeek V4 Flash** (build 0731, API release 2026-07-31; HF weights = April preview) | 79.0 (Flash-Max) [indep llm-stats]; Terminal-Bench 2.1 = 82.7 **[vendor self-reported]**; DSBench-FullStack 68.7 / Hard 59.6 **[vendor]** | 71.2 **[vendor]** | 1M context; LiveBench overall 65.5 (Coding 69.2, Agentic Coding **37.6**, Math 79.6; cost/task $0.016) [indep livebench.ai, release 2026-06-25]; MMLU-Pro 86.2 [indep]; AAII 50 [indep artificialanalysis]; LMArena Elo 1431 (#40, snapshot 2026-07-28) | $0.14 / $0.28; 2500 concurrency | api-docs.deepseek.com/updates, livebench.ai, llm-stats.com, artificialanalysis.ai, LMArena |
| **DeepSeek V4 Pro** (preview) | 80.6 **[vendor]** | 90.1 **[vendor]** | 1M context; LiveBench overall 71.6 (Agentic 42.6) [indep]; AAII 44 [indep] | $0.435 / $0.87 | vendor, livebench.ai, artificialanalysis.ai |
| **Qwen 3.8 Max** (GA blog 2026-08-03) | SWE-bench Pro 67.7 **[vendor]** (Fable 5 80.0, Opus 4.8 69.2, GPT-5.6 Sol 64.6); DeepSWE 1.1 56.6; FrontierSWE 73.5 (Fable 5 88.8); SWE-bench Verified в блоге НЕ опубликован. ⚠️ **Do NOT confuse with Qwen 3.7 Max** (SWE-bench Verified 80.4, GPQA 92.4, Terminal-Bench 69.7 — different model, all 3.8 numbers in early reviews are actually 3.7). **Anecdotal/community (single runs, NOT reproducible):** Trilogy AI StackPerf 80/100 vs Kimi K3 83/100 (269-file arch task, 0 failed tool-calls, tool-use 9/10; longer + more tokens); KingBench 65/80 (#2 behind Fable 5, community); 36kr 22.07 won 4/6 rounds vs GLM-5.2/K3 BUT дал ФЕЙКОВОЕ решение в раунде «карусель». | GPQA-Diamond **92.6 [vendor]** (GPT-5.6 Sol 94.1, Fable 5 92.6, Opus 4.8 92.0; GLM 5.2 ref 91.2); HLE 43.6 (Fable 5 53.3); IFBench **82.8 [vendor]** (lead) | 1M context (blog config `context_window: 1000000`; docs.qwencloud.com ранее: 983,616); max output 131,072; reasoning_effort xhigh/medium/low (default xhigh); multimodal input (text/images/video/docs). Agentic [vendor]: Terminal-Bench 2.1 **86.6** (Claude Code harness, avg@10), OSWorld-Verified **86.1** (lead), PaperBench **93.0** (lead), Toolathlon 72.5, WideSearch 81.9, MRCR v2 256K 92.9. Multimodal [vendor]: MMMU-Pro 82.3, MathVision 95.2/97.7, VideoMME 90.4, OmniDocBench 1.5 92.1. Open weights: **first Max-class open-weight model** — HF/ModelScope «next week» (анонс 2026-08-03; HF-репо на дату проверки ещё нет, Qwen/Qwen3.8-Max → 401). **All vendor self-reported; independent verification pending.** | Per-token price официально НЕ опубликована. **Token Plan** [official]: Lite $6, Standard ~$18-20, Pro $68-70/month. Mirror claim $2/$6/$0.25-cached per 1M [MarkTechPost, **unverified**]. Owner subscription confirmed. | qwen.ai/blog?id=qwen3.8 (vendor, 2026-08-03); docs.qwencloud.com (specs 2026-07-19); marktechpost.com (price mirror, unverified); trilology.ai/stackperf, kingbench (community), 36kr.com (2026-07-22) |
| **GLM 5.2** (Zhipu) | SWE-bench Pro 62.1 **[vendor]**; Terminal-Bench 2.1 = 81.0 **[vendor]**; FrontierSWE 74.4; DeepSWE 46.2 | 91.2 **[vendor]** | 1M context; LiveBench 73.2 [indep]; MCP-Atlas 76.8; AAII 51 (**open-weight leader**) [indep]; ~106 tok/s | Z.ai $1.40 / $4.40 | z.ai/blog/glm-5.2, livebench.ai, artificialanalysis.ai |
| **GPT-5.5** (OpenAI) | SWE-bench Pro 58.6 **[vendor]**; Terminal-Bench 2.0 = 82.7 **[vendor]** | 93.6 **[vendor]** | 1M context; OSWorld 78.7; BrowseComp 84.4; AAII 55 [indep] | $5 / $30 | openai.com/index/introducing-gpt-5-5, artificialanalysis.ai |

### Caveats

- **Flash-0731 agentic numbers — vendor self-reported**, independently not reproduced. LiveBench Agentic Coding sub-score = 37.6 flags weak multi-step agency.
- **Flash reasoning weak** (GPQA-D 71.2 vs GLM 91.2, GPT-5.5 93.6). Reviewer/judgment role для Flash **не benchmark-supported**.
- **Qwen 3.8 Max — vendor benchmarks опубликованы 2026-08-03 (qwen.ai/blog); independent verification pending.** Reviewer/architect role = owner decision + vendor benches + anecdotal. Judgment vendor-supported: GPQA-D 92.6 (уровень GLM 91.2 / GPT-5.5 93.6); agentic: TB2.1 86.6, OSWorld-V 86.1, IFBench 82.8; coding: SWE-bench Pro 67.7 (ниже Fable 5: 80.0). ⚠️ Do NOT confuse with Qwen 3.7 Max (SWE-bench 80.4, GPQA 92.4 — ДРУГАЯ модель). Anecdotal: StackPerf 80/100 vs Kimi K3 83; KingBench 65/80; 36kr 4/6 rounds vs GLM-5.2/K3 (1 fake solution). Strengths: design/writing/architecture/dynamic understanding. Weaknesses: ОЧЕНЬ slow for code (slowest model — Wiegold), hallucinations в длинных сессиях, фейки при неясных требованиях. NE основной кодер — vendor-бенчи не отменяют latency-данные.
- **«Flash не хуже GLM» — частично:** AAII 50 vs 51 (близко), reasoning заметно слабее.
- **GLM 5.2 и GPT-5.5** — единственные с независимыми judgment/review цифрами (AAII 51 и 55; GPQA-D 91.2 и 93.6). Их роли benchmark-supported.
- **DeepSeek V4 Pro** указан для справки (preview, vendor-only); в active stack не входит.

### Sources (accessed 2026-08-03)

- `api-docs.deepseek.com/updates` — DeepSeek V4 Flash 0731 + Pro preview (vendor)
- `livebench.ai` (release 2026-06-25) — LiveBench overall + sub-scores (independent)
- `artificialanalysis.ai` — AAII aggregate (independent)
- `llm-stats.com` — SWE-bench Verified independent tracker
- `z.ai/blog/glm-5.2` — GLM-5.2 vendor numbers
- `openai.com/index/introducing-gpt-5-5` — GPT-5.5 vendor numbers
- `lmarena.ai` (Elo leaderboard, snapshot 2026-07-28) — Flash Elo 1431, rank #40
- `qwen.ai/blog?id=qwen3.8` (2026-08-03, official GA launch + benchmark tables — vendor self-reported, indep verification pending)
- **Qwen 3.8 Max**: `qwen.ai/blog?id=qwen3.8` (2026-08-03, vendor benches); `docs.qwencloud.com` + `x.com/Alibaba_Qwen` (2026-07-19, official specs); `hf.co/Qwen/Qwen3.8-Max` (verified 2026-08-03: HF API 0 models, 401 — open weights announced «next week»); `marktechpost.com` (2026-08-03, price mirror $2/$6 — unverified); `trilogy.ai/stackperf` (StackPerf 80/100 vs Kimi K3 83); KingBench community run; `36kr.com` (2026-07-22, Chinese coverage); `manish.sh`, `ben.wiegold.com` review, `r/LocalLLaMA`, `r/Qwen_AI` (anecdotal community evidence)

---

## Как выбрать профиль при bootstrap

| Признак | Профиль |
|---------|---------|
| Проект использует DeepSeek V4 Flash (оркестратор + writer) | DeepSeek |
| Проект использует GLM 5.2 (multi-file writer + reviewer) | GLM |
| Проект использует Qwen 3.8 Max (reviewer/архитектор) | Qwen |
| Проект использует GPT-5.5 (security gate) | Codex |
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
