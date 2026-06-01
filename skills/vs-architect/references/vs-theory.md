# Verbalized Sampling — Agent Reference

Based on arXiv 2510.01171v3 (ICLR 2026): "Verbalized Sampling: How to Mitigate Mode Collapse and Unlock LLM Diversity."

## Core Mechanism

- **Instance-level prompt** ("do X") → model collapses to the mode prototype (the most typical response)
- **List-level prompt** ("give 5 variants of X") → model collapses to a uniform distribution
- **Distribution-level prompt** ("give 5 variants of X with probabilities") → model collapses to an approximation of the pretraining distribution → diversity recovered

Key insight: different prompt types collapse a mode-collapsed model to *different modes*. Instance-level collapses to a single prototype. Distribution-level collapses to a distribution string that encodes the base model's diversity.

## Two-Phase Model

```
PHASE 1: VS Analysis
  Distribution prompt → k variants with probabilities → user selects

PHASE 2: Execution Prompt
  Selected variant → detailed implementation prompt (no VS)
```

## Decision Tree — Pattern Selection

Check rules strictly top-to-bottom. First match wins.

| # | Condition | Pattern |
|---|---|---|
| 1 | Complexity=TRIVIAL + type=CODE + variants=SINGLE | **NO VS** (direct) |
| 2 | Complexity=TRIVIAL + type≠CODE | **A** (VS-Standard) |
| 3 | Complexity=UNCERTAIN + type=DIAGNOSTIC | **C** (VS-CoT) |
| 4 | Complexity=UNCERTAIN + type=STRATEGY | **C** (VS-CoT) |
| 5 | Complexity=UNCERTAIN + type=CODE | **C** (VS-CoT) |
| 6 | Constraints=YES + complexity≠TRIVIAL | **E** (External Collapse) |
| 7 | Complexity=MODERATE + type=CODE | **A** (VS-Standard) |
| 8 | Complexity=MODERATE + type=STRATEGY | **A** (VS-Standard) |
| 9 | Type=CREATIVE + variants=MANY | **D** (VS-Multi) |
| 10 | Type=DATA + variants=MANY | **D** (VS-Multi) |
| 11 | Type=CREATIVE + variants=FEW + uniformity complaint | **B** (Diversity Tuning, p<0.10) |
| 12 | Type=CREATIVE + variants=FEW (no complaint) | **A** (VS-Standard) |
| 13 | ≥2 axes UNKNOWN | ask user |
| 14 | 1 axis UNKNOWN | ignore, apply remaining axes |
| 15 | default (no match) | **A** (VS-Standard) |

## Classification Axes

### Complexity
| Value | Indicators |
|---|---|
| **TRIVIAL** | "write a script", solution path is obvious |
| **MODERATE** | integration, refactoring, marketing hypothesis |
| **UNCERTAIN** | "not sure what's wrong", "could be A or B", bug diagnosis |

### Task Type
| Value | Indicators |
|---|---|
| **CODE** | writing/refactoring code, integration |
| **STRATEGY** | approach selection, planning, architecture |
| **DIAGNOSTIC** | root cause analysis, bug hunting |
| **CREATIVE** | content generation, copywriting, ideation |
| **DATA** | synthetic data, test cases, coverage |

### Variant Count
| Value | Indicators |
|---|---|
| **FEW** (3–5) | need to compare approaches |
| **MANY** (10+) | coverage, synthetic data, brainstorming |
| **SINGLE** (1) | direct prompt is sufficient |

### External Constraints
| Value | Indicators |
|---|---|
| **YES** | "tight budget", "legacy system", "urgent" |
| **NO** | no constraints |

### New in the Decision Tree (patterns F, G)

| # | Condition | Pattern |
|---|---|---|
| 16 | VS pass returned interesting but vague ideas | **F** (VS-Refine) |
| 17 | Critical decision, high stakes | **G** (VS-Ensemble) |

## 7 VS Patterns

### A. VS-Standard
Single call → k variants with probabilities → user selects.
When: moderate complexity, 3–5 variants sufficient.

### B. Diversity Tuning
Probability threshold in prompt (p < 0.10 for rare variants, p > 0.5 for stable).
When: direct prompt gives uniform/typical responses.

### C. VS-CoT
Step-by-step reasoning first, then distribution of variants.
When: task is non-obvious, requires analysis. Stronger effect on reasoning models (DeepSeek R1, o3).

### D. VS-Multi
Multiple rounds: round 1 → k variants, round 2+ → k more, excluding previous.
When: need 10+ variants, data generation.

### E. External Collapse
VS-Standard + user weights variants by their own criteria (budget, deadlines, legacy) — not by LLM probability.
When: external constraints the LLM doesn't know about.

### F. VS-Refine
Two-pass: first pass generates k variants, second pass takes the top 2-3 most interesting ones and elaborates each into a full detailed plan.
When: first VS pass surfaces interesting ideas that are still vague and need fleshing out. Adds depth without losing diversity.

### G. VS-Ensemble
Two independent VS prompts from different angles (e.g., one technical, one business), then cross-compare results.
When: critical decision where a single VS pass might miss key aspects. Provides cross-validation.

## Mode Mapping

| Pattern | Execution Mode | Thinking Budget |
|---|---|---|
| A (VS-Standard) | Standard / Fast Lane | Think High / none |
| B (Diversity Tuning) | Fast Lane | none |
| C (VS-CoT) | Complex | Think Max (≤500 words) |
| D (VS-Multi) | Standard → Complex | Think High → escalate at 30+ |
| E (External Collapse) | Any | Depends on complexity |
| F (VS-Refine) | Standard | Think High |
| G (VS-Ensemble) | Complex (2 subagents) | Think Max per agent |

## Prompt Templates

### A — VS-Standard (Phase 1)
```
Generate [k] variants for [task].
For each:
- approach description
- success probability (0–1)
- pros (2)
- cons (2)
- main risk

Format — headers, readable text.
```

### B — Diversity Tuning (Phase 1)
```
Generate [k] variants for [task].
Select ONLY from low-probability variants (p < [threshold]).
For each, provide probability and description.

Format — headers, readable text.
```

### C — VS-CoT (Phase 1)
```
Think step by step about [task].
Consider: [context, what has been tried].

Then generate [k] variants with probabilities.
For each:
- hypothesis
- probability (0–1)
- how to verify
- what to do if confirmed
```

### D — VS-Multi (Phase 1, round 1)
```
Generate [k] variants for [task] with probabilities.
Format — headers.
```

### D — VS-Multi (Phase 1, round 2+)
```
Generate [k] more alternative variants not present in previous rounds, with probabilities.
```

### E — External Collapse (Phase 1)
```
Generate [k] variants for [task].
For each:
- description
- success probability
- implementation time
- main risk
- maintenance complexity
```

### F — VS-Refine (Phase 1, pass 1)
```
Generate [k] diverse variants for [task].
For each:
- one-line summary
- what makes it unique
- what needs elaboration
- success probability (0–1)
```
### F — VS-Refine (Phase 1, pass 2)
```
Take the most promising variant: [variant summary].
Elaborate it into a full implementation plan:
- detailed approach
- concrete steps
- resources needed
- expected outcome
- risks and mitigations
```
### G — VS-Ensemble (Phase 1, agent 1)
```
Generate [k] variants for [task] from a [technical / business / creative] perspective.
For each:
- approach
- key insight from this angle
- probability (0–1)
- pros and cons
```
### G — VS-Ensemble (Phase 1, agent 2)
```
Generate [k] variants for the same task: [task].
Use a [complementary perspective] — focus on aspects agent 1 missed.
For each:
- approach
- key insight
- probability (0–1)
- pros and cons
```
### G — VS-Ensemble (Phase 1, cross-comparison)
```
Compare the two sets of variants above.
For each unique approach:
- which perspectives covered it
- what each perspective adds
- combined probability estimate
- recommendation

Highlight any conflicts between the two perspectives.
```
### Execution Prompt (Phase 2)
```
Task: [selected variant from VS analysis]
Context: [what is already known, constraints]

What to do:
- [concrete steps]
- [which files/systems]
- [constraints]

Output format: [what is expected]
```

## Constraints

- **k > 10** in a single call → quality degrades. Split into multi-turn
- Factual queries (2+2, capital of France) → VS not needed
- Production code requiring stability → direct prompt is more reliable
