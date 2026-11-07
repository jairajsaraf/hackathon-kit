# Hackathon Kit

A small Claude Code starter set for AI, agent and data hackathons, built to ship faster while spending fewer tokens. The core set adds about 2,150 tokens to every session; everything else is opt-in, chosen once in your plan phase. It works for Claude Code in the terminal, the Claude Desktop Code tab, and (for the kit's own skills) Claude Desktop chat and Cowork.

## Install

Pick one. All three end in the same place.

**1. Let Claude Code do it.** Unzip the kit, or run `git clone https://github.com/jairajsaraf/hackathon-kit.git`, somewhere permanent (keep the folder; Claude Code reads the kit from it), open Claude Code in that folder and say: `Install this kit.` It reads `AGENTS.md`, shows you a dry run, and asks before changing anything.

**2. Run the installer yourself.**

```bash
# macOS / Linux / Git Bash
bash install.sh --dry-run          # look first
bash install.sh                    # core set
bash install.sh --with web,data    # add-ons, only what you need
```

```powershell
# Windows PowerShell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1 -With web,data
```

**3. Do it by hand.** `SETUP.md` lists every command with the output to expect.

Then restart Claude Code (or run `/reload-plugins`) and check:

```bash
bash doctor.sh          # Windows: powershell -ExecutionPolicy Bypass -File .\doctor.ps1
```

Something not working? `KNOWN-ISSUES.md` lists the common problems with fixes and how sure we are of each.

## What you get

| Piece | What it is | Always-on tokens |
|---|---|---|
| `hackathon-core` | `hackathon-skills` + superpowers + ponytail | about 2,150 + the four skills |
| `hackathon-web` (add-on) | frontend-design + Playwright MCP (needs Node.js) | about 80 |
| `hackathon-data` (add-on) | Anthropic's `data` plugin; its bundled MCP servers need paid accounts | about 1,125 |
| TokenEconomizer | cost-saving plugin, installed if Python 3.10+ is present | about 317 |

The four skills: `model-advisor` (type `/model?` before a task), `session-handoff-maintenance` (a `HANDOFF.md` for the next session), `deepen-task` (turn a vague task into a rigorous one) and `opt-in-picker`.

**Choosing extras.** Ask Claude `which extra skills do we need for this plan?` during planning. The `opt-in-picker` skill reads `plugins/hackathon-skills/skills/opt-in-picker/catalog.md`, recommends at most two, shows the token cost and waits for your yes. Doing it at plan time matters: enabling plugins mid-session can invalidate the prompt cache.

## Requirements

Claude Code and git. Node.js for the web add-on. Python 3.10 or newer for TokenEconomizer. No API keys are needed for anything in the core set.

## What this kit does not do

It cannot sign you in, create accounts, add claude.ai connectors or click through Claude Desktop screens. `SETUP.md` has the steps for those.

## Licence

The kit's own files are MIT (see `LICENSE`; the copyright holder line is a placeholder). The third-party plugins it installs (superpowers, ponytail, frontend-design, playwright, data, TokenEconomizer) keep their own licences and are fetched from their publishers, not bundled here. `MANIFEST.md` lists each source and version.
