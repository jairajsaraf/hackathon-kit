<#
  Hackathon Kit installer for Windows (PowerShell 5.1 or 7). Safe to re-run.

  Usage:  .\install.ps1 [-DryRun] [-With web,data] [-Scope user|project|local]
                        [-Source PATH_OR_OWNER/REPO] [-SkipTokenEconomizer]

    -DryRun                 print what would run; still runs read-only checks
    -With web,data          also install add-on bundles
    -Scope                  Claude Code install scope (default: user)
    -Source                 where the hackathon-kit marketplace comes from
                            (default: this folder; keep it in place after install)
    -SkipTokenEconomizer    do not install TokenEconomizer (it needs Python 3.10+)

  Needs: Claude Code ('claude' on PATH) and git. Exit code 1 if any step failed.
  If scripts are blocked:  powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
[CmdletBinding()]
param(
  [switch]$DryRun,
  [string[]]$With = @(),
  [ValidateSet('user', 'project', 'local')][string]$Scope = 'user',
  [string]$Source = '',
  [switch]$SkipTokenEconomizer
)

# $PSScriptRoot is empty inside a param() default on Windows PowerShell 5.1 when run with -File, so set it here.
if (-not $Source) { $Source = $PSScriptRoot }
if (-not $Source) { $Source = Split-Path -Parent $MyInvocation.MyCommand.Path }

$script:done    = New-Object System.Collections.Generic.List[string]
$script:failed  = New-Object System.Collections.Generic.List[string]
$script:skipped = New-Object System.Collections.Generic.List[string]

function Say([string]$m) { Write-Host $m }

# Invoke-Step "label" @('plugin','install','x')  (prints the command; runs it unless -DryRun)
function Invoke-Step([string]$Label, [string[]]$CmdArgs) {
  Say ('+ claude ' + ($CmdArgs -join ' '))
  if ($DryRun) { $script:skipped.Add("$Label (dry run)"); return }
  & claude @CmdArgs
  if ($LASTEXITCODE -eq 0) { $script:done.Add($Label) } else { $script:failed.Add($Label) }
}

# Substring match on the registered marketplace names. Read-only.
function Test-Marketplace([string]$Name) {
  $out = (& claude plugin marketplace list 2>$null | Out-String)
  return ($out -match [regex]::Escape($Name))
}

function Add-Marketplace([string]$Name, [string]$From) {
  if (Test-Marketplace $Name) { Say "= marketplace '$Name' already registered"; return }
  Invoke-Step "add marketplace $Name" @('plugin', 'marketplace', 'add', $From)
}

function Install-Plugin([string]$Id) {
  Invoke-Step "install $Id" @('plugin', 'install', $Id, '--scope', $Scope)
}

function Find-Python310 {
  foreach ($c in @('python3', 'python', 'py')) {
    if (-not (Get-Command $c -ErrorAction SilentlyContinue)) { continue }
    try {
      & $c -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>$null
      if ($LASTEXITCODE -eq 0) { return $c }
    } catch { }
  }
  return $null
}

# ---- prerequisites -------------------------------------------------------
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Say "Claude Code ('claude') was not found on PATH. Install Claude Code, open a new terminal, then run this again."
  exit 1
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Say 'git was not found on PATH. It is needed to fetch GitHub marketplaces. Install git, then run this again.'
  exit 1
}
Say ('Claude Code: ' + ((& claude --version 2>$null) -join ' '))
if ($DryRun) { Say 'DRY RUN: nothing will be changed.' }

$wantWeb = $false; $wantData = $false
foreach ($w in ($With | ForEach-Object { $_ -split ',' } | Where-Object { $_ })) {
  switch ($w) {
    'web'   { $wantWeb = $true }
    'data'  { $wantData = $true }
    default { Say "-With accepts: web, data (got '$w')"; exit 2 }
  }
}

if (Test-Path -LiteralPath $Source -PathType Container) {
  $Source = (Resolve-Path -LiteralPath $Source).Path
  Say "Marketplace source: $Source (keep this folder where it is)"
}

# ---- 1. marketplaces ------------------------------------------------------
Add-Marketplace 'claude-plugins-official' 'anthropics/claude-plugins-official'
Add-Marketplace 'ponytail' 'DietrichGebert/ponytail'
if ($wantData) { Add-Marketplace 'knowledge-work-plugins' 'anthropics/knowledge-work-plugins' }
Add-Marketplace 'hackathon-kit' $Source

# ---- 2. core --------------------------------------------------------------
Install-Plugin 'hackathon-core@hackathon-kit'

# ---- 3. add-ons -----------------------------------------------------------
if ($wantWeb) {
  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { Say '! Node.js (npx) not found: the Playwright MCP server will not start until you install Node.js.' }
  Install-Plugin 'hackathon-web@hackathon-kit'
}
if ($wantData) { Install-Plugin 'hackathon-data@hackathon-kit' }

# ---- 4. TokenEconomizer (needs Python 3.10+) -------------------------------
if ($SkipTokenEconomizer) {
  $script:skipped.Add('TokenEconomizer (-SkipTokenEconomizer)')
} elseif (-not (Find-Python310)) {
  $script:skipped.Add('TokenEconomizer (Python 3.10 or newer not found on PATH)')
} else {
  Add-Marketplace 'tokeneconomizer' 'microsoft/TokenEconomizer'
  Install-Plugin 'tokeneconomizer@tokeneconomizer'
}

# ---- summary --------------------------------------------------------------
Say ''; Say '==== Summary ===='
foreach ($x in $script:done)    { Say "done:    $x" }
foreach ($x in $script:skipped) { Say "skipped: $x" }
foreach ($x in $script:failed)  { Say "FAILED:  $x" }
Say ''
Say 'Next: restart Claude Code (or run /reload-plugins in an open session), then run .\doctor.ps1'
Say 'Not automated here: sign-ins, API keys, claude.ai connectors, Claude Desktop chat/Cowork. See SETUP.md.'
if ($script:failed.Count -gt 0) { exit 1 }
