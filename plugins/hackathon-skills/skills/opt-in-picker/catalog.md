# Opt-in catalog

Read by the `opt-in-picker` skill and by people choosing by hand. **One home:** this file is the only copy; SETUP.md links to it.

How to read the numbers
- **Always-on tokens** come from `claude plugin details <name>` on 2026-11-07 (projected, rounded). Re-measure after install with the same command.
- **Evidence** grades: *measured* (a number from a tool), *self-reported* (the authors' own benchmark), *mechanism-only* (what it does, no outcome data), *unverified* (not checked against the upstream repo).
- No source measures how any of these affect hackathon results. The "Choose if" lines are judgment, not proof.
- The kit's core (superpowers, ponytail, the four hackathon skills) is already installed. Budget: core plus opt-ins under about 6,000 always-on tokens.

Marketplaces the installer already registered: `claude-plugins-official`, `ponytail`, `knowledge-work-plugins`, `hackathon-kit`. Any other marketplace below needs its `marketplace add` line first.

---

## vercel
- **Install:** `claude plugin install vercel@claude-plugins-official`
- **Always-on:** about 3,989 tokens for 35 skills (measured on v0.49.2 from another listing; re-measure).
- **Helps with:** deploying a live demo URL; AI SDK, agent, AI Gateway, sandbox and workflow skills. Roughly 6-8 of the 35 skills matter for a typical agent or web project (my count from skill names).
- **Choose if:** the plan deploys a web app or agent UI on Vercel, or builds with the AI SDK.
- **Skip if:** CLI, notebook or data-only project, or deploying elsewhere.
- **Needs:** a Vercel account for its MCP server and CLI login.
- **Evidence:** mechanism-only.

## engineering-advanced-skills (rank last)
- **Install:** `claude plugin marketplace add alirezarezvani/claude-skills` then `claude plugin install engineering-advanced-skills@claude-code-skills`
- **Always-on:** about 5,332 tokens for 38 skills (measured).
- **Helps with:** about 8 relevant skills: agent-designer, agent-workflow-designer, mcp-server-builder, rag-architect, spec-driven-workflow, ship-gate, focused-fix, self-eval (my count from skill names).
- **Choose if:** the plan includes designing an agent workflow, an MCP server or a RAG pipeline and nobody on the team has done it before.
- **Skip if:** anything else. Poor relevance ratio: you pay for 38 skills to use about 8.
- **Needs:** nothing. **Evidence:** mechanism-only.

## codex (cross-model second opinion)
- **Install:** `claude plugin marketplace add openai/codex-plugin-cc` then `claude plugin install codex@openai-codex`
- **Always-on:** about 451 tokens (measured).
- **Helps with:** an independent review from a different model at a milestone.
- **Choose if:** the team already has an OpenAI/Codex account and wants a review before the demo.
- **Skip if:** no account.
- **Needs:** the Codex CLI and an OpenAI or ChatGPT account (inferred; check the plugin README).
- **Evidence:** mechanism-only.

## gstack (heavy, manual)
- **Install (from the upstream README):** `git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack`, then run `./setup` inside that folder. The README says a bare `./setup` installs for Claude Code only.
- **Always-on:** about 7,000 tokens estimated for 63 skills (frontmatter characters divided by 4, a proxy; measure with `/skill-doctor`).
- **Helps with:** guardrails against destructive commands (careful, guard, freeze) and review / qa / ship workflows.
- **Choose if:** one teammate already uses it and the team accepts the cost.
- **Skip if:** you are a team of newcomers in a 24-48 hour event.
- **Needs:** Git and Bun v1.4.2 or newer. Windows support: **unknown**, read the README.
- **Evidence:** mechanism-only.

## Firecrawl (web data)
- **Install:** the official route per the upstream README mirror is the `firecrawl` plugin from `firecrawl/firecrawl-claude-plugin` plus `npm install -g firecrawl-cli`; find it with `/plugin` and search `firecrawl`. Sign in with `firecrawl login --browser` or set `FIRECRAWL_API_KEY`.
- **Always-on:** unknown for the official plugin. Do not install the 33-skill local set the kit's author uses.
- **Helps with:** scraping, crawling and searching the web for your project's data.
- **Choose if:** the plan's data comes from the web and nothing in the team's data is provided. Prefer the CLI to an MCP server.
- **Skip if:** the hackathon supplies the data.
- **Needs:** a Firecrawl account or key. Free tier: **unknown**. Licence stated as AGPL-3.0 in a search snippet: **verify**.
- **Evidence:** unverified.

## alphaXiv connector (papers)
- **Install:** in Claude Desktop or claude.ai, **Customize > Connectors**, find alphaXiv, connect with your own account. This is not a Claude Code plugin step.
- **Always-on:** unknown (connector tools load on demand).
- **Choose if:** research-heavy AI project that needs paper lookup.
- **Skip if:** otherwise. **Evidence:** unverified.

---

## Not needed or not recommended
| Item | Why |
|---|---|
| ecc (everything-claude-code) | about 47,600 always-on tokens, 408 skills across unrelated domains |
| engineering-skills | about 5,350 tokens, broad and not agent-focused |
| github plugin (MCP) | Anthropic's costs page says CLI tools such as `gh` use less context than an MCP server |
| shadcn MCP | use the shadcn CLI instead; the exact CLI command is **unverified** |
| code-review plugin | overlaps with Claude Code's built-in review skill (check your `/skills` list) |

## After the hackathon
| Item | Install | Why later |
|---|---|---|
| understand-anything | `claude plugin marketplace add Egonex-AI/Understand-Anything` then `claude plugin install understand-anything@understand-anything` | about 1,150 tokens; helps you learn a codebase, not ship in 24 hours |
