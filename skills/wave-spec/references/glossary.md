# Glossary — wave-spec (15 терминов)

> 15 терминов, которые использует wave-spec. Сейчас они встречаются в SKILL.md, но нигде не определялись. Для не-разработчика: читай этот файл, когда встречаешь незнакомый термин.

| Термин | Что это | Зачем |
|---|---|---|
| **INTENT** | Свободный markdown: «что я хочу, успех, out of scope». Пишет человек или агент-черновик. | Снять намерение ДО спеки, чтобы не строить не то. |
| **SPEC.xml** | Агентный контракт: goal + измеримые success criteria + scope in/out + constraints + sources + risks + acceptance. | Договориться ЧТО строим, до кода. Статусы: draft → approved. |
| **PLAN.xml** | Задачи: id / title / depends_on / owner / model_hint / artifact / done_when + gates + roles. | Как и в каком порядке строим; кто исполняет. |
| **STATUS.md** | Живая таблица задач: id / owner / state / artifact / notes. State = lifecycle enum. | Оркестратор видит прогресс; воркеры только дописывают notes. |
| **Hard gate (approve)** | Пока пользователь не скажет «approve/делай/утверждаю» — агент пишет только планирование, НЕ исполняет. | Защита от самоуправства; человек подтверждает скоуп. |
| **Mode (quick/wave/task/program)** | Режим по масштабу: quick (≤1 файл/≤30 мин/no deploy), wave (спринт 2–7 дней, default), task (атомарная задача внутри волны), program (много-волновой портфель). | Не тягать полный lifecycle на мелочь. |
| **Lifecycle states** | 8 состояний: Implement done → In Review → Commit → PR → Merge → Deploy gate → On prod → Done. Каждое — отдельный гейт. | «Writer сказал Done» ≠ «на проде». [TICKET]: агент пометил Done, код не был на проде. |
| **In Review** | Состояние после dual review: 0 MAJOR или все MAJOR закрыты; writer ≠ reviewer. | Не путать с «writer закончил» (Implement done). |
| **Cross-family rule** | `writer.family ≠ reviewer.family` (например Alibaba-Qwen пишет → Zhipu-GLM или DeepSeek ревьюит). | Разные семейства ловят слепые пятна друг друга. Кросс-аудит поймал потерю [X]% стока при миграции данных. |
| **Dual review** | Два ревьюера с разными линзами: static-parity (структура/file:line) ∥ behavioral-semantics (поведение/cost/state). Для fidelity — обязательно. | Одна линза пропускает целый класс багов. |
| **Deploy probe** | curl-проверка, что новый маршрут/артефакт СУЩЕСТВУЕТ на проде (307/302 = ок, 404 = нет). Не проверяет корректность — только наличие. | [TICKET]: непротреканные файлы давали 404 на проде. |
| **written≠persisted** | Gate перед worker_done: `git status`/`ls`/`wc -l` доказывает, что каждый заявленный путь реально на диске. Заявлено, но нет = FAIL. | «Отчёт есть, файла нет» — классический сбой ([TICKET]). |
| **RESIDUAL-RISK-OWNER-SMOKE** | Метка в handoff: «на проде не смоук-тестнуто, владелец/следующая сессия проверяет». Нельзя писать Done без deploy proof. | Честность: не утверждать «готово», если прод не проверен. |
| **worker_done** | CLI-команда `orca orchestration send --type worker_done` — рапорт воркера (3 предложения + SUMMARY/EVIDENCE/CHANGES/RISKS/BLOCKERS). Текст в чате НЕ заменяет команду. | Оркестратор ждёт именно команду, не текст ([RULE]). |
| **NEXT_SESSION** | Файл передачи между сессиями: pointer (`NEXT_SESSION.md`) + итерация (`NEXT_SESSION_I{N}.md`, шаги 0–8 с гейтами). Уникальный на итерацию, не перезаписывается. | Мульти-сессионная непрерывность; оркестратор выполняет шаги+гейты, не угадывает. |

## Связанные скиллы
- **project-bootstrap** — создаёт ДОМ (AGENTS.md/memory/rules). Точка входа для нового проекта.
- **multi-model-orchestration** — dispatch/review через Orca, роутинг моделей. Для ≥2 моделей.
- **operational-rules.md** (в project-bootstrap/references/) — [RULE]/2/3: `--to` на worker_done, global inbox вместо handle-scoped check, writer-swap при retry storm.
