<#
  Hackathon Kit doctor (Windows, PowerShell 5.1 or 7). READ-ONLY: it changes nothing.
  It reports what is installed, what is missing, and the exact command that fixes each problem.
  Usage: .\doctor.ps1        Exit code 1 if anything required is missing.
  If scripts are blocked:  powershell -ExecutionPolicy Bypass -File .\doctor.ps1
#>
$script:ok = 0; $script:warn = 0; $script:bad = 0
function Ok([string]$m)   { Write-Host "  [ok]   $m";   $script:ok++ }
function Warn([string]$m) { Write-Host "  [warn] $m";   $script:warn++ }
function Bad([string]$m)  { Write-Host "  [FAIL] $m";   $script:bad++ }

Write-Host '== Tools'
if (Get-Command claude -ErrorAction SilentlyContinue) { Ok ('claude ' + ((& claude --version 2>$null) -join ' ')) }
else { Bad 'Claude Code not on PATH. Install it and open a new terminal.'; Write-Host ''; Write-Host 'Cannot continue without Claude Code.'; exit 1 }
if (Get-Command git -ErrorAction SilentlyContinue) { Ok 'git' } else { Bad 'git missing (needed to fetch GitHub marketplaces)' }
if (Get-Command npx -ErrorAction SilentlyContinue) { Ok 'node/npx (Playwright MCP)' } else { Warn 'Node.js not found: only needed for the web add-on (Playwright MCP)' }
$py = $null
foreach ($c in @('python3', 'python', 'py')) {
  if (-not (Get-Command $c -ErrorAction SilentlyContinue)) { continue }
  try { & $c -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>$null; if ($LASTEXITCODE -eq 0) { $py = $c; break } } catch { }
}
if ($py) { Ok 'python >= 3.10 (TokenEconomizer)' } else { Warn 'Python 3.10+ not found: TokenEconomizer cannot run (optional)' }

Write-Host '== Marketplaces'
$mk = (& claude plugin marketplace list 2>$null | Out-String)
foreach ($pair in @(@('claude-plugins-official', 'anthropics/claude-plugins-official'), @('ponytail', 'DietrichGebert/ponytail'), @('hackathon-kit', '<path to this folder>'))) {
  if ($mk -match [regex]::Escape($pair[0])) { Ok "marketplace $($pair[0])" }
  else { Bad "marketplace $($pair[0]) missing. Fix: claude plugin marketplace add $($pair[1])" }
}

Write-Host '== Plugins'
$plugins = $null
try { $plugins = (& claude plugin list --json 2>$null | Out-String) | ConvertFrom-Json } catch { $plugins = $null }
function Get-State([string]$id) {
  if ($null -eq $plugins) { return 'unreadable' }
  $p = @($plugins) | Where-Object { $_.id -eq $id } | Select-Object -First 1
  if (-not $p) { return 'missing' }
  if ($p.errors) { return 'error' }
  if ($p.enabled) { return 'enabled' } else { return 'disabled' }
}
function Check([string]$id, [bool]$required) {
  switch (Get-State $id) {
    'enabled'    { Ok $id }
    'disabled'   { Warn "$id is disabled. Fix: claude plugin enable $id" }
    'error'      { Bad "$id failed to load. Run: claude plugin list   (read the error under it)" }
    'unreadable' { Warn "could not read 'claude plugin list --json'; run: claude plugin list" }
    'missing'    { if ($required) { Bad "$id missing. Fix: claude plugin install $id --scope user" } else { Warn "$id not installed (optional)" } }
  }
}
foreach ($id in @('hackathon-skills@hackathon-kit', 'hackathon-core@hackathon-kit', 'superpowers@claude-plugins-official', 'ponytail@ponytail')) { Check $id $true }
if ((Get-State 'hackathon-web@hackathon-kit') -ne 'missing') { Check 'hackathon-web@hackathon-kit' $true; Check 'frontend-design@claude-plugins-official' $true; Check 'playwright@claude-plugins-official' $true }
if ((Get-State 'hackathon-data@hackathon-kit') -ne 'missing') { Check 'hackathon-data@hackathon-kit' $true; Check 'data@knowledge-work-plugins' $true }
Check 'tokeneconomizer@tokeneconomizer' $false

Write-Host ''
Write-Host "Result: $($script:ok) ok, $($script:warn) warnings, $($script:bad) failures."
if ($script:bad -gt 0) {
  Write-Host 'If hackathon-core is installed but superpowers or ponytail are missing, Claude Code skipped a dependency.'
  Write-Host "Run the 'Fix' commands above, then /reload-plugins in Claude Code."
}
Write-Host ''
Write-Host 'Not checked (cannot be automated): sign-ins, API keys, claude.ai connectors, Claude Desktop chat/Cowork. See SETUP.md.'
if ($script:bad -gt 0) { exit 1 }
