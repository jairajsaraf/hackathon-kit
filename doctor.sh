#!/usr/bin/env bash
# Hackathon Kit doctor. READ-ONLY: it changes nothing. It reports what is installed,
# what is missing, and the exact command that fixes each problem.
# Usage: ./doctor.sh        Exit code 1 if anything required is missing.
set -u
OK=0; WARN=0; BAD=0
ok()   { printf '  [ok]   %s\n' "$*"; OK=$((OK+1)); }
warn() { printf '  [warn] %s\n' "$*"; WARN=$((WARN+1)); }
bad()  { printf '  [FAIL] %s\n' "$*"; BAD=$((BAD+1)); }

echo "== Tools"
if command -v claude >/dev/null 2>&1; then ok "claude $(claude --version 2>/dev/null)"; else bad "Claude Code not on PATH. Install it and open a new terminal."; echo; echo "Cannot continue without Claude Code."; exit 1; fi
command -v git >/dev/null 2>&1 && ok "git" || bad "git missing (needed to fetch GitHub marketplaces)"
command -v npx >/dev/null 2>&1 && ok "node/npx (Playwright MCP)" || warn "Node.js not found: only needed for the web add-on (Playwright MCP)"
PYBIN=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import sys' 2>/dev/null; then PYBIN="$c"; break; fi
done
if [ -n "$PYBIN" ] && "$PYBIN" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then ok "python >= 3.10 (TokenEconomizer)"; else warn "Python 3.10+ not found: TokenEconomizer cannot run (optional)"; fi

echo "== Marketplaces"
MK="$(claude plugin marketplace list 2>/dev/null)"
for pair in "claude-plugins-official|anthropics/claude-plugins-official" "ponytail|DietrichGebert/ponytail" "hackathon-kit|<path to this folder>"; do
  name="${pair%%|*}"; src="${pair##*|}"
  if printf '%s' "$MK" | grep -qiF -- "$name"; then ok "marketplace $name"; else bad "marketplace $name missing. Fix: claude plugin marketplace add $src"; fi
done

echo "== Plugins"
JSON="$(claude plugin list --json 2>/dev/null)"
# Prints: missing | disabled | enabled | error | unreadable | present (no Python available)
state_of() {
  if [ -n "$PYBIN" ]; then
    printf '%s' "$JSON" | "$PYBIN" -c '
import sys, json
want = sys.argv[1]
try:
    data = json.load(sys.stdin)
except Exception:
    print("unreadable"); sys.exit(0)
for p in data:
    if p.get("id") == want:
        if p.get("errors"):
            print("error")
        else:
            print("enabled" if p.get("enabled") else "disabled")
        sys.exit(0)
print("missing")' "$1"
  elif printf '%s' "$JSON" | grep -qF "\"$1\""; then echo present; else echo missing; fi
}
check() { # id required(1/0)
  local id="$1" req="$2" s; s="$(state_of "$id")"
  case "$s" in
    enabled|present) ok "$id" ;;
    disabled) warn "$id is disabled. Fix: claude plugin enable $id" ;;
    error)    bad  "$id failed to load. Run: claude plugin list   (read the error under it)" ;;
    unreadable) warn "could not read 'claude plugin list --json'; run: claude plugin list" ;;
    missing)
      if [ "$req" = 1 ]; then bad "$id missing. Fix: claude plugin install $id --scope user"; else warn "$id not installed (optional)"; fi ;;
  esac
}
for id in hackathon-skills@hackathon-kit hackathon-core@hackathon-kit superpowers@claude-plugins-official ponytail@ponytail; do check "$id" 1; done
s_web="$(state_of hackathon-web@hackathon-kit)"
if [ "$s_web" != missing ]; then check hackathon-web@hackathon-kit 1; check frontend-design@claude-plugins-official 1; check playwright@claude-plugins-official 1; fi
s_data="$(state_of hackathon-data@hackathon-kit)"
if [ "$s_data" != missing ]; then check hackathon-data@hackathon-kit 1; check data@knowledge-work-plugins 1; fi
check tokeneconomizer@tokeneconomizer 0

echo
echo "Result: $OK ok, $WARN warnings, $BAD failures."
if [ "$BAD" -gt 0 ]; then
  echo "If hackathon-core is installed but superpowers or ponytail are missing, Claude Code skipped a dependency."
  echo "Run the 'Fix' commands above, then /reload-plugins in Claude Code."
fi
echo
echo "Not checked (cannot be automated): sign-ins, API keys, claude.ai connectors, Claude Desktop chat/Cowork. See SETUP.md."
[ "$BAD" -eq 0 ]
