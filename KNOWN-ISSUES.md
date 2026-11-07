# KNOWN-ISSUES

What can go wrong, in plain terms, with the fix. Each entry says how sure we are:

- **docs**: stated in Anthropic's Claude Code documentation or the upstream README.
- **seen**: we hit it while building the kit on Windows 11 with Claude Code 2.1.319.
- **inferred**: follows from how the scripts or tools work; not reproduced.
- **untested**: we have not tried it.

We found no organizer or participant write-up about hackathon setup problems, so this list comes from the docs and from our own tests, not from reports. If you hit something new, tell the kit's maintainer.

Run `bash doctor.sh` (Windows: `powershell -ExecutionPolicy Bypass -File .\doctor.ps1`) first. It prints the fix for most install problems.

---

## Windows

| Symptom | Cause and fix | Evidence |
|---|---|---|
| `Python was not found; run without arguments to install from the Microsoft Store` | `python3` is a Microsoft Store stub, not a real Python. The real command may be `python` or `py`. The scripts try all three. To silence the stub: Settings > Apps > Advanced app settings > App execution aliases. If you have no Python 3.10+, the installer skips TokenEconomizer (by design) | seen |
| "Running scripts is disabled on this system" | Run with `powershell -ExecutionPolicy Bypass -File .\install.ps1` (the README commands already do) | inferred |
| `Failed to clone marketplace repository: Command 'git' not found or is in an unsafe location` | Install Git for Windows, open a new terminal, retry | docs |
| Git Bash: `claude` cannot find the kit folder | The script converts the path with `cygpath`. If it still fails, pass a Windows-style path: `bash install.sh --source C:/path/to/hackathon-kit` | inferred |
| Claude Desktop Code tab shows no plugins in a WSL session | Plugins are not available in WSL sessions. Use a normal Windows or macOS session | docs |

## macOS and Linux

| Symptom | Cause and fix | Evidence |
|---|---|---|
| `Permission denied` on `./install.sh` | Some unzip tools drop the executable bit. Use `bash install.sh` instead | inferred |
| Anything else on macOS | The kit has **not been tried on macOS or Linux at all**. The scripts are plain bash and parse cleanly, nothing more is known | untested |

## Network, proxies and managed machines

| Symptom | Cause and fix | Evidence |
|---|---|---|
| `git clone timed out after 120s` or marketplace add hangs | Slow or blocked GitHub access. Retry on another network. For GitHub shorthand, Claude Code tries SSH if your key authenticates to github.com and HTTPS otherwise; set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` to force HTTPS | docs |
| Behind a corporate proxy | Git and npm need your proxy settings (the Playwright MCP server downloads through npm on first use). Which settings Claude Code itself honours was not checked | untested |
| `Allowed sources: ...` or `No external marketplaces are allowed` | Your organization's managed settings restrict marketplaces. The kit cannot override that; ask your administrator to allow `anthropics/claude-plugins-official`, `DietrichGebert/ponytail`, `anthropics/knowledge-work-plugins` and this kit's source | docs |
| No Wi-Fi at the venue | Every install needs the network. Install the night before and start Claude Code once so everything loads. The Playwright server downloads on its first use, so run it once too | inferred |

## Missing prerequisites

| Symptom | Cause and fix | Evidence |
|---|---|---|
| Playwright MCP shows as failed in `/mcp` | Needs Node.js: it runs `npx @playwright/mcp@latest`. Install Node.js, restart Claude Code | docs (the plugin's own config) |
| TokenEconomizer was skipped | Python 3.10 or newer was not found on PATH. Install it and re-run the installer, or skip the plugin | docs (its README) |
| `claude: command not found` | Claude Code is not installed or not on PATH. Install it, open a new terminal | inferred |
| Install fails on an old Claude Code | The minimum version for plugin dependencies is **unknown**. Update Claude Code and retry | unknown |

## Install and dependencies

| Symptom | Cause and fix | Evidence |
|---|---|---|
| `hackathon-core` installed but `superpowers` or `ponytail` is missing | Claude Code skipped a dependency: its marketplace was not registered, or not on the kit's allow list. Run `claude plugin install superpowers@claude-plugins-official` and `claude plugin install ponytail@ponytail`, then `/reload-plugins` | docs |
| Error: `Dependency "x" ... is not in the allowlist` | Same cause; install that dependency yourself at the same `--scope`, then retry | docs |
| `Marketplace directory not found at path` | You moved or deleted the kit folder after installing. Run `claude plugin marketplace remove hackathon-kit`, put the folder somewhere permanent, run the installer again | docs |
| Installer says a marketplace is "already registered" but it points at an old folder | The installer matches marketplace names, not paths. Remove and re-add it as above | inferred |
| Installer skipped adding a marketplace you do not have | The check is a substring match on `claude plugin marketplace list`; a different marketplace whose name contains `ponytail` or `hackathon-kit` would fool it. Add the marketplace by hand (SETUP.md section 2) | inferred |
| New plugin not visible | Run `/reload-plugins` or restart Claude Code. A reload mid-session can warn that it will invalidate the prompt cache; `/reload-plugins --force` applies it anyway at the cost of one uncached request | docs |

## Tokens and your Pro allowance

| Symptom | Cause and fix | Evidence |
|---|---|---|
| Hitting the five-hour limit early | Long sessions resend all context every request. Use `/usage` (it attributes usage to skills, plugins and MCP servers), `/clear` between unrelated tasks and `/model sonnet` for most coding | docs |
| `data` add-on shows servers as failed or needing authentication | The plugin bundles MCP servers for paid analytics and warehouse accounts. Run `/mcp` and disable the ones you have no account for | seen |
| superpowers and ponytail seem to disagree | Both add instructions at session start: superpowers asks the agent to follow skill workflows, ponytail pushes for the shortest working change. **Whether they conflict in practice is untested.** If it slows you down, turn one off: `claude plugin disable ponytail@ponytail` | untested |
| TokenEconomizer shows little saving at first | Its authors say it learns per repository, so a brand-new hackathon repo gets the smaller gain. Run `/tokeneconomizer:toolprune refresh-catalog` once per machine | docs (its README) |
| `claude plugin marketplace add microsoft/TokenEconomizer` fails | The GitHub shorthand has not been tested. Use the README's route: clone the repo, then `claude plugin marketplace add <path to the clone>` | untested |

## Claude Desktop

| Symptom | Cause and fix | Evidence |
|---|---|---|
| In chat or Cowork only `hackathon-skills` works | Dependencies do not auto-install there, and hooks and agents do not run in chat. Install the other plugins through Claude Code in the same account, or ignore them | docs |
| Cannot find **Customize > Plugins** or **Add marketplace** | Menu names vary by app version. On Team or Enterprise plans an organization owner controls who can add marketplaces | docs |
| Uploaded skill ZIP is rejected | The ZIP must contain the skill folder at its top level, with a `SKILL.md` inside, and code execution must be enabled in Settings > Capabilities | docs (search summary) |
| Private GitHub marketplace will not add | Connect your GitHub account and give the Claude GitHub App access when the dialog asks. A public repo needs neither | docs |

## What the kit cannot fix

Sign-ins, API keys, account creation and claude.ai connectors. Do those yourself, and never paste a key into a chat.
