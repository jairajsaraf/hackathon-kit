#!/usr/bin/env bash
# Hackathon Kit installer for macOS, Linux and Git Bash on Windows. Safe to re-run.
#
# Usage: ./install.sh [--dry-run] [--with web,data] [--scope user|project|local]
#                     [--source PATH_OR_OWNER/REPO] [--skip-tokeneconomizer]
#
#   --dry-run               print what would run; still runs read-only checks
#                           (versions, marketplace list)
#   --with web,data         also install add-on bundles
#   --scope                 Claude Code install scope (default: user)
#   --source                where the hackathon-kit marketplace comes from
#                           (default: this folder; keep it in place after install)
#   --skip-tokeneconomizer  do not install TokenEconomizer (it needs Python 3.10+)
#
# Needs: Claude Code ('claude' on PATH) and git. Exit code 1 if any step failed.
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0; SOURCE="$HERE"; SCOPE="user"; WITH=""; SKIP_TE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --with) WITH="${2:-}"; shift ;;
    --scope) SCOPE="${2:-}"; shift ;;
    --source) SOURCE="${2:-}"; shift ;;
    --skip-tokeneconomizer) SKIP_TE=1 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
  shift
done

case "$SCOPE" in user|project|local) ;; *) echo "--scope must be user, project or local" >&2; exit 2 ;; esac

DONE=(); FAILED=(); SKIPPED=()
say() { printf '%s\n' "$*"; }

# step "label" command args...   (prints the command; runs it unless --dry-run)
step() {
  local label="$1"; shift
  say "+ $*"
  if [ "$DRY" -eq 1 ]; then SKIPPED+=("$label (dry run)"); return 0; fi
  if "$@"; then DONE+=("$label"); else FAILED+=("$label"); fi
}

# Substring match on the registered marketplace names. Read-only.
has_marketplace() { claude plugin marketplace list 2>/dev/null | grep -qiF -- "$1"; }

add_marketplace() { # name source
  if has_marketplace "$1"; then say "= marketplace '$1' already registered"; return 0; fi
  step "add marketplace $1" claude plugin marketplace add "$2"
}

install_plugin() { step "install $1" claude plugin install "$1" --scope "$SCOPE"; }

# ---- prerequisites -------------------------------------------------------
command -v claude >/dev/null 2>&1 || { say "Claude Code ('claude') was not found on PATH. Install Claude Code, open a new terminal, then run this again."; exit 1; }
command -v git    >/dev/null 2>&1 || { say "git was not found on PATH. It is needed to fetch GitHub marketplaces. Install git, then run this again."; exit 1; }
say "Claude Code: $(claude --version 2>/dev/null || echo unknown)"
[ "$DRY" -eq 1 ] && say "DRY RUN: nothing will be changed."

PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then PY="$c"; break; fi
done

WANT_WEB=0; WANT_DATA=0
IFS=',' read -r -a _with <<< "$WITH"
for w in "${_with[@]:-}"; do
  case "$w" in
    web) WANT_WEB=1 ;;
    data) WANT_DATA=1 ;;
    "") ;;
    *) echo "--with accepts: web, data (got '$w')" >&2; exit 2 ;;
  esac
done

# A local source must be an absolute path Claude Code can read. Git Bash on Windows needs a Windows-style path.
if [ -d "$SOURCE" ]; then
  SOURCE="$(cd "$SOURCE" && pwd)"
  if command -v cygpath >/dev/null 2>&1; then SOURCE="$(cygpath -m "$SOURCE")"; fi
  say "Marketplace source: $SOURCE (keep this folder where it is)"
fi

# ---- 1. marketplaces ------------------------------------------------------
add_marketplace claude-plugins-official anthropics/claude-plugins-official
add_marketplace ponytail                DietrichGebert/ponytail
[ "$WANT_DATA" -eq 1 ] && add_marketplace knowledge-work-plugins anthropics/knowledge-work-plugins
add_marketplace hackathon-kit           "$SOURCE"

# ---- 2. core --------------------------------------------------------------
install_plugin hackathon-core@hackathon-kit

# ---- 3. add-ons -----------------------------------------------------------
if [ "$WANT_WEB" -eq 1 ]; then
  command -v npx >/dev/null 2>&1 || say "! Node.js (npx) not found: the Playwright MCP server will not start until you install Node.js."
  install_plugin hackathon-web@hackathon-kit
fi
[ "$WANT_DATA" -eq 1 ] && install_plugin hackathon-data@hackathon-kit

# ---- 4. TokenEconomizer (needs Python 3.10+) -------------------------------
if [ "$SKIP_TE" -eq 1 ]; then
  SKIPPED+=("TokenEconomizer (--skip-tokeneconomizer)")
elif [ -z "$PY" ]; then
  SKIPPED+=("TokenEconomizer (Python 3.10 or newer not found on PATH)")
else
  add_marketplace tokeneconomizer microsoft/TokenEconomizer
  install_plugin tokeneconomizer@tokeneconomizer
fi

# ---- summary --------------------------------------------------------------
say ""; say "==== Summary ===="
for x in "${DONE[@]:-}";    do [ -n "$x" ] && say "done:    $x"; done
for x in "${SKIPPED[@]:-}"; do [ -n "$x" ] && say "skipped: $x"; done
for x in "${FAILED[@]:-}";  do [ -n "$x" ] && say "FAILED:  $x"; done
say ""
say "Next: restart Claude Code (or run /reload-plugins in an open session), then run ./doctor.sh"
say "Not automated here: sign-ins, API keys, claude.ai connectors, Claude Desktop chat/Cowork. See SETUP.md."
[ "${#FAILED[@]}" -eq 0 ]
