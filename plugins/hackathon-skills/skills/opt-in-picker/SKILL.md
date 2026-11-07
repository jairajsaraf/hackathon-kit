---
name: opt-in-picker
description: Use in the plan phase, before building, or whenever the user asks which extra skills, plugins or MCP servers to add. Recommends the fewest opt-ins the project needs, shows token cost and install commands, and records the decision. Default is to add nothing.
---

# Opt-in Picker

Choose extra tooling once, at plan time. Reasons:

- Every always-on token is resent with each request, and on Claude Pro chat and Claude Code share the same five-hour and weekly limits.
- Enabling a plugin mid-session can invalidate the prompt cache (Claude Code docs, "Install and manage plugins"), so late additions cost twice.
- More tools also means more descriptions competing to trigger.

The kit's core set is already installed. This skill decides whether anything *beyond* it earns its cost.

## Procedure

1. **Read the catalog:** `${CLAUDE_PLUGIN_ROOT}/skills/opt-in-picker/catalog.md`. Recommend only items that are in it. If the project needs something the catalog does not cover, say so and stop; do not invent a recommendation.
2. **State the project in one sentence and its demo path** (what a judge will see). If the user has not said, ask.
3. **Ask at most three questions, in one message:**
   - Project type: web app, agent or MCP server, data or ML, other?
   - Where does it deploy, and which accounts or keys does the team already have (Vercel, OpenAI/Codex, Firecrawl, others)?
   - Is the usage limit a worry?
4. **Pick.** The default is nothing. Add an item only if (a) it maps to a named task in the plan and (b) the catalog's "Choose if" matches. Pick at most two. Prefer a CLI to an MCP server when the catalog lists one.
5. **Show the cost.** For each pick: name, always-on tokens, which task it serves, the exact install command, prerequisites, and anything to disable afterwards. Core is about 2,150 tokens always-on (measured 2026-11-07); warn if core plus the picks passes about 6,000.
6. **Do not install without a yes.** Show the command and wait. After installing, tell the user to run `/reload-plugins` between tasks, not in the middle of one.
7. **Record the decision** in the plan or in `HANDOFF.md` under "Tooling decisions": item, reason, cost, date.
8. **Re-run** only if the plan's scope changes or at the midpoint scope check.

## Output format

```
Project: <one sentence>   Demo path: <one sentence>

| Opt-in | Serves this task | Always-on tokens | Install | Needs |
|---|---|---|---|---|

Core + picks ≈ <n> tokens always-on (budget ~6,000).
Not adding: <items considered and why not>.
Reply "yes" to install <item>, or tell me what to change.
```

## Rules

- Label evidence the way the catalog does (measured, self-reported, mechanism-only, unverified) and never upgrade it.
- If a catalog entry says "unverified", tell the user and offer to check the upstream README first.
- Never run an install command from this skill without explicit confirmation.
- If the user names a plugin that is not in the catalog, read its README, and run `claude plugin details <name>` once the user has approved installing it, before recommending it further.
