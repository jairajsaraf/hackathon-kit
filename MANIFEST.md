# MANIFEST

Every item the kit installs or lists, with its source, licence and the version seen on 2026-11-07. Always-on tokens are projections from `claude plugin details` (rounded). Nothing third-party is copied into this repository.

Tested against: Claude Code 2.1.319. Plugin manifests validated with `claude plugin validate`. Real installs on a clean machine: **not yet done**.

## Installed by the kit

| Item | Route | Source | Version seen | Licence | Always-on tokens |
|---|---|---|---|---|---|
| hackathon-skills | this repo | `plugins/hackathon-skills` | 1.0.0 | MIT (copyright line is a placeholder) | small, **unmeasured** |
| hackathon-core | this repo | `plugins/hackathon-core` | 1.0.0 | MIT | holds dependencies only |
| superpowers | dependency | `claude-plugins-official` (author Jesse Vincent, github.com/obra/superpowers) | 7.0.0 | MIT | about 848 |
| ponytail | dependency | `ponytail` marketplace (github.com/DietrichGebert/ponytail) | 4.9.0 | LICENSE file present; SPDX not declared | about 985 |
| hackathon-web | this repo, optional | `plugins/hackathon-web` | 1.0.0 | MIT | holds dependencies only |
| frontend-design | dependency of web | `claude-plugins-official` (Anthropic) | 1.1.1 | LICENSE file present; SPDX not declared | about 80 |
| playwright | dependency of web | `claude-plugins-official` (Microsoft), runs `npx @playwright/mcp@latest` | commit-hash version | none declared | about 0 (MCP tools load on demand) |
| hackathon-data | this repo, optional | `plugins/hackathon-data` | 1.0.0 | MIT | holds dependencies only |
| data | dependency of data | `knowledge-work-plugins` marketplace (github.com/anthropics/knowledge-work-plugins, path `./data`) | not recorded | **not stated** in the marketplace entry | about 1,125, plus 8 MCP servers needing paid accounts |
| tokeneconomizer | installed by the script when Python 3.10+ exists | github.com/microsoft/TokenEconomizer | 0.1.0 | Apache-2.0 | about 317 |

Core total: about 2,150 tokens always-on plus the four own skills (**not yet measured**; run `claude plugin details hackathon-skills` after installing).

## Own skills (in `hackathon-skills`)

| Skill | Origin | Change from the author's original |
|---|---|---|
| model-advisor | author's own | Model names updated to Haiku 5.5, Sonnet 5.5, Opus 5.5, Fable 5.1 (Anthropic models page, 2026-11-07); removed a claim that a model tier is suspended, which the models page does not support; added a Pro cost note |
| session-handoff-maintenance | author's own | Rewritten as a generic `HANDOFF.md` skill; personal project details removed; the update and one-home-per-fact rules kept |
| deepen-task | author's own | Unchanged copy, including its reference example |
| opt-in-picker | written for this kit | New; reads `catalog.md` in the same folder |

## Opt-ins (listed, never installed automatically)

See `plugins/hackathon-skills/skills/opt-in-picker/catalog.md` for sources, costs and install commands: vercel, engineering-advanced-skills, codex, gstack, Firecrawl, alphaXiv.

## Version pinning

Marketplaces track the latest upstream release by default. For event day, pin the ones you depend on, for example `claude plugin marketplace add DietrichGebert/ponytail#<tag>` (GitHub `owner/repo#ref` is supported, Claude Code install docs). The kit does not pin them because no tags were verified.

## Known gaps

- The `data` plugin's licence and the Firecrawl plugin's licence are unverified.
- The shadcn CLI command is unverified and not used.
- Claude Desktop chat/Cowork behaviour was read from documentation and not tried.
