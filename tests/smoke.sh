#!/usr/bin/env bash
# Dolphin v4 smoke test — the pack's regression test.
# Run after ANY change to skills/, agents/, or scripts/. Proves:
# pack structure (router + 13 skills, ≤250 lines each, frontmatter
# names match) · agent definitions (auditor is read-only) · no dead
# v3 transport referenced anywhere in skills/agents · init scaffolds
# state only (no board) · deterministic scans (red on fixtures,
# green on clean, package existence fail-closed).
set -u
PACK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
S="$PACK/skills/dolphin-protocol/scripts"
TMP="$(mktemp -d)"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "ok   - $1"; }
bad() { FAIL=$((FAIL+1)); echo "FAIL - $1"; }
expect() { # expect <wanted-exit> <label> <cmd...>
  local want="$1" label="$2"; shift 2
  "$@" >/dev/null 2>&1
  local got=$?
  if [ "$got" -eq "$want" ]; then ok "$label"; else bad "$label (want $want, got $got)"; fi
}

# --- structure -------------------------------------------------------
N=$(find "$PACK/skills" -name SKILL.md | wc -l)
if [ "$N" -eq 13 ]; then ok "13 skills present"; else bad "13 skills present (got $N)"; fi

OVER=$(find "$PACK/skills" -name SKILL.md -exec wc -l {} + | awk '$2!="total" && $1>250 {print $2}')
if [ -z "$OVER" ]; then ok "every skill ≤250 lines"; else bad "every skill ≤250 lines ($OVER)"; fi

MISMATCH=0
for f in "$PACK"/skills/*/SKILL.md; do
  d="$(basename "$(dirname "$f")")"
  grep -q "^name: $d\$" "$f" || MISMATCH=1
done
if [ "$MISMATCH" -eq 0 ]; then ok "frontmatter name matches folder for all skills"; else bad "frontmatter name matches folder"; fi

if grep -q "disable-model-invocation: true" "$PACK/skills/dolphin/SKILL.md" \
   && grep -q "dolphin-leader" "$PACK/skills/dolphin/SKILL.md"; then
  ok "router /dolphin is user-invoked and loads the leader"
else bad "router /dolphin is user-invoked and loads the leader"; fi

if [ -f "$PACK/agents/dolphin-agent.md" ] && [ -f "$PACK/agents/dolphin-auditor.md" ]; then
  ok "agent definitions present (agent + auditor)"
else bad "agent definitions present"; fi

if grep -q "^tools:.*Write" "$PACK/agents/dolphin-auditor.md"; then
  bad "auditor definition is read-only"
else ok "auditor definition is read-only"; fi

# --- no dead v3 transport -------------------------------------------
if grep -r -q -E "dolphin-say|dolphin-secretary|dolphin-pod" "$PACK/skills" "$PACK/agents"; then
  bad "no skill/agent references the removed v3 transport"
else ok "no skill/agent references the removed v3 transport"; fi

# --- init scaffolds state only ---------------------------------------
export DOLPHIN_PROJECT="$TMP/proj"
mkdir -p "$DOLPHIN_PROJECT"
expect 0 "init scaffolds .dolphin" "$S/dolphin-init.sh"
if [ -x "$DOLPHIN_PROJECT/.dolphin/bin/dolphin-scan" ] \
   && [ -d "$DOLPHIN_PROJECT/.dolphin/scopes" ] \
   && [ -d "$DOLPHIN_PROJECT/.dolphin/evidence" ] \
   && [ -f "$DOLPHIN_PROJECT/.dolphin/outcomes.md" ]; then
  ok "init installs tools + state dirs"
else bad "init installs tools + state dirs"; fi
if [ -e "$DOLPHIN_PROJECT/.dolphin/board.md" ]; then
  bad "init creates NO board (v3 transport is gone)"
else ok "init creates NO board (v3 transport is gone)"; fi

# --- deterministic scans ----------------------------------------------
expect 2 "slop scan red on bad.ts"     "$S/dolphin-scan" slop "$PACK/tests/fixtures/bad.ts"
expect 0 "slop scan green on clean.ts" "$S/dolphin-scan" slop "$PACK/tests/fixtures/clean.ts"
expect 2 "slop scan red on bad.py (except-pass)" "$S/dolphin-scan" slop "$PACK/tests/fixtures/bad.py"
expect 2 "secrets scan red on bad.py"     "$S/dolphin-scan" secrets "$PACK/tests/fixtures/bad.py"
expect 0 "secrets scan green on clean.py" "$S/dolphin-scan" secrets "$PACK/tests/fixtures/clean.py"
expect 0 "pkg: react exists"              "$S/dolphin-scan" pkg npm react
expect 2 "pkg: hallucinated name rejected" "$S/dolphin-scan" pkg npm react-ultra-mega-fake-pkg-zzz

echo "smoke: $PASS passed, $FAIL failed (workdir kept at $TMP)"
[ "$FAIL" -eq 0 ]
