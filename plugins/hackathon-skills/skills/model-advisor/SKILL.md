---
name: model-advisor
description: >
  Trigger this skill immediately and without exception whenever the user's message begins with "/model?" — this is their explicit signal that they are unsure which Claude model and effort level to use. Read the prompt that follows the prefix, assess its complexity, and output a model + effort recommendation with brief reasoning. Then pause — do not answer the underlying prompt yet. On the user's next turn (after they signal they've switched), verify your own model identity against the recommendation, confirm or flag a mismatch, and then answer the original prompt. Always trigger on /model? regardless of what follows it.
---

# Model Advisor

Triggered exclusively when the user's message begins with `/model?`.

> Adapted for the hackathon kit. Model names were updated on 2026-11-07 to match Anthropic's models page (Haiku 5.5, Sonnet 5.5, Opus 5.5, Fable 5.1). If a model is not in the user's `/model` picker (availability depends on plan), recommend the next one down.

**Cost rule:** on Claude Pro, chat and Claude Code share five-hour and weekly usage limits, so choose the cheapest model that fits. Anthropic's Claude Code costs page says Sonnet handles most coding tasks and costs less than Opus.

---

## Turn 1 — Recommendation

Read everything after `/model?` as the actual prompt. Do not answer it yet.

Output only this block:

```
📊 Model Recommendation
──────────────────────────────
Model:  [Haiku 5.5 / Sonnet 5.5 / Opus 5.5 / Fable 5.1]
Effort: [Low / Medium / High / Max]
Why:    [1–2 sentences on complexity and why this model+effort fits]
──────────────────────────────
Switch to [Model] at [Effort] effort, then let me know — I'll confirm the switch and answer your prompt.
```

Stop here. Do not answer the underlying prompt in this turn.

---

## Turn 2 — Confirmation + Answer

When the user signals they've switched (e.g., "switched", "done", "ok", "ready"):

1. **Check your own model identity** from your system context.
2. **Compare** it to what was recommended.
3. Output a brief status line:
   - ✅ Match: `Confirmed — running on [Model]. Continuing.`
   - ⚠️ Mismatch: `I'm currently [Actual Model], not [Recommended Model]. You can continue here or switch and re-ask.`
4. **Effort caveat** (always include): `I can't directly verify your effort setting — please confirm it's set to [Effort].`
5. Then immediately answer the original prompt from Turn 1.

---

## Complexity Heuristics

| Task Type | Model | Effort |
|---|---|---|
| Quick factual lookup, simple Q&A, one-liner rewrites | Haiku 5.5 | Low |
| Moderate coding, summarization, structured writing, light analysis | Sonnet 5.5 | Medium |
| Boilerplate SQL or Python, short drafts | Sonnet 5.5 | Low |
| Long-form creative writing, nuanced editing | Sonnet 5.5 | Medium–High |
| Well-scoped harder tasks: moderate reasoning, contained architecture questions, focused debugging | Opus 5.5 | Medium |
| Token-sensitive hard tasks: solid reasoning needed but output length is bounded | Opus 5.5 | High |
| Complex SQL/Python pipelines, data modeling, broad architecture decisions | Opus 5.5 | High |
| Multi-step reasoning, ambiguous research, argument analysis | Opus 5.5 | High |
| Technical deep-dives, novel debugging | Opus 5.5 | High |
| Maximally hard problems: open-ended research, deeply ambiguous specs, novel algorithm design | Fable 5.1 if available, otherwise Opus 5.5 | High–Max |

These are heuristics — use judgment for edge cases.

---

## Effort Levels

Set with `/effort` in Claude Code (levels: low, medium, high, max; some models also offer xhigh).

- **Low** — fast, surface response; minimal reasoning depth
- **Medium** — balanced depth and speed; good for most tasks
- **High** — deeper reasoning; for complex or multi-part tasks
- **Max** — maximum reasoning budget; reserve for the hardest problems

---

## Key Constraints

- Claude knows its own model identity from system context → model confirmation is reliable.
- Claude cannot read the user's UI effort setting → always ask the user to manually confirm effort.
- Never answer the underlying prompt during Turn 1. The whole point is to pause.
- Keep the recommendation block short. The user is making a quick operational decision.
- Do not claim a model is unavailable or suspended unless the user's own `/model` picker shows that.
