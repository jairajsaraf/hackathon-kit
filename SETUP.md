# SETUP: install, step by step

Everything the installers do is listed here so you can do it by hand. Outputs marked *(docs)* come from Anthropic's Claude Code documentation; the rest is what to expect, not a recording.

## 0. Before you start

- Claude Code installed and signed in. Check: `claude --version`.
- `git` installed. Check: `git --version`.
- Node.js only for the web add-on (`node --version`). Python 3.10+ only for TokenEconomizer (`python3 --version`; on Windows try `python --version` or `py -3 --version`).
- Something not working? See `KNOWN-ISSUES.md`.
- **Keep this folder in place** after installing. Claude Code reads the kit's marketplace from it. If you move it later, see section 9.
- **On Claude Pro** your usage limit is shared between chat and Claude Code. Three habits that save it (Claude Code costs documentation): `/model sonnet` for most coding, `/clear` between unrelated tasks, and `/usage` to see which skills, plugins and MCP servers use your allowance.

## 1. One command

| System | Command |
|---|---|
| macOS / Linux / Git Bash | `bash install.sh` |
| Windows PowerShell | `powershell -ExecutionPolicy Bypass -File .\install.ps1` |

Options: `--dry-run` / `-DryRun` shows the commands without running them. `--with web,data` / `-With web,data` installs add-ons. `--scope user|project|local` / `-Scope` picks where it installs (default `user`, every project on this machine). `--skip-tokeneconomizer` / `-SkipTokenEconomizer` skips TokenEconomizer.

It is safe to run twice: it skips marketplaces that are already registered, and `claude plugin install` returns success for a plugin that is already installed *(docs)*.

## 2. By hand (what the installer runs)

Run these in a normal terminal, not inside Claude Code. Replace `<kit folder>` with this folder's full path.

```bash
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin marketplace add DietrichGebert/ponytail
claude plugin marketplace add "<kit folder>"
claude plugin install hackathon-core@hackathon-kit
```

Expect `Successfully added marketplace: <name>` after each add and `Successfully installed plugin: hackathon-core@hackathon-kit (scope: user)` after the install *(docs)*. Installing `hackathon-core` also installs `hackathon-skills`, `superpowers` and `ponytail`, because the kit's marketplace lists them as dependencies and allows those three marketplaces.

Check: `claude plugin list` should show `hackathon-core`, `hackathon-skills`, `superpowers` and `ponytail` as enabled. In a Claude Code session, type `/` and look for `/hackathon-skills:opt-in-picker`.

**If `superpowers` or `ponytail` is missing** after installing the core: Claude Code skipped a dependency. Install it yourself at the same scope, then run `/reload-plugins`:

```bash
claude plugin install superpowers@claude-plugins-official
claude plugin install ponytail@ponytail
```

## 3. Add-ons

**Web** (frontend-design, Playwright MCP):

```bash
claude plugin install hackathon-web@hackathon-kit
```

Needs Node.js. The Playwright MCP server starts with `npx @playwright/mcp@latest`, so the first use downloads it.

**Data** (Anthropic's `data` plugin, from the `knowledge-work-plugins` marketplace):

```bash
claude plugin marketplace add anthropics/knowledge-work-plugins
claude plugin install hackathon-data@hackathon-kit
```

The plugin's skills need nothing. Its bundled MCP servers (analytics and warehouse tools) need paid accounts; if you have none, run `/mcp` inside Claude Code and disable them so they do not show errors.

## 4. TokenEconomizer (optional, needs Python 3.10+)

```bash
claude plugin marketplace add microsoft/TokenEconomizer
claude plugin install tokeneconomizer@tokeneconomizer
```

Then, inside Claude Code: run `/tokeneconomizer:status` (allow its script if asked) and, once per machine, `/tokeneconomizer:toolprune refresh-catalog`, as the project's README says. It needs no API key.

The project's own README installs from a clone instead (`git clone https://github.com/microsoft/TokenEconomizer.git`, then `claude plugin marketplace add <path to the clone>`). **The GitHub shorthand above is expected to work but has not been tested here.** If it fails, use the clone route.

Its authors report 18.4 to 30.9% lower mean cost on SWE-Bench and 6 to 20% on benchmarks where every task is a new repository. These are the authors' own numbers; the gain in a brand-new hackathon repo is likely at the lower end.

## 5. Claude Desktop

| Where | What to do |
|---|---|
| **Code tab** | Reads the same settings and `~/.claude/skills` as the terminal. Install in a terminal as above (user scope), or click **+** next to the prompt box, then **Add plugins**. Not available in WSL sessions. |
| **Chat and Cowork** | Plugins and skills come from your claude.ai account, not from your terminal. Open **Customize > Plugins > Add > Add marketplace**, enter `jairajsaraf/hackathon-kit` (the public GitHub repo that hosts this kit), then enable `hackathon-skills`. Or **Add > Upload plugin** with a ZIP of `plugins/hackathon-skills` (the ZIP must hold one `.claude-plugin/plugin.json`). |

Limits in chat and Cowork: dependencies do not install automatically there, so superpowers, ponytail and the add-ons are not pulled in; hooks and agents do not run in chat. `hackathon-skills` has no dependencies, so it works. Menu names can differ between app versions.

Chat can also use MCP servers: local ones through **Settings > Developer > Edit Config** (`claude_desktop_config.json`, restart the app) or a `.mcpb` extension, remote ones through **Customize > Connectors**. The kit ships none.

## 6. Choosing opt-ins

In your plan phase, ask Claude: `which extra skills do we need for this plan?` The `opt-in-picker` skill asks at most three questions, recommends at most two items from the catalog with token cost, and waits for your yes. By hand, read `plugins/hackathon-skills/skills/opt-in-picker/catalog.md`: each entry has the install command, always-on tokens, when to choose it and when to skip it. After any install, run `/reload-plugins` between tasks, not in the middle of one.

## 7. Accounts and keys the kit cannot handle

Vercel login (for the vercel opt-in), Firecrawl account or key, OpenAI/Codex account, claude.ai connectors (alphaXiv and others). Do each yourself; never paste keys into chat.

## 8. Update and remove

```bash
claude plugin update hackathon-core@hackathon-kit      # restart Claude Code afterwards
claude plugin uninstall hackathon-core@hackathon-kit
claude plugin prune                                    # removes dependencies nothing else needs
claude plugin marketplace remove hackathon-kit         # also uninstalls plugins installed from it
```

## 9. Moved or re-extracted the folder?

Claude Code remembers the folder you registered. If you moved it, or extracted a new copy elsewhere, run `claude plugin marketplace remove hackathon-kit`, then run the installer again from the new location.

## 10. Status

Checked: the marketplace and plugin manifests pass `claude plugin validate` (Claude Code 2.1.319, 2026-11-07), the scripts parse, and the installer and doctor logic behaves correctly against a stand-in for the `claude` command. **Not yet checked:** a real install on a clean machine, on macOS, on a Pro account, or in Claude Desktop.
