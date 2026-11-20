#!/usr/bin/env bash
# Dolphin v4 smoke test — the pack's regression test.
# Run after ANY change to skills/, agents/, or scripts/. Proves:
# pack structure (router + 13 skills, ≤250 lines each, frontmatter
# names match, frontmatter parses as valid YAML) · agent definitions
# (judge fence stated) · no dead v3 transport referenced anywhere
# in skills/agents · init scaffolds
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

# Frontmatter must parse as YAML. An unquoted ": " inside a
# description makes installers SKIP the skill silently — in
# v4.1/v4.1.1 the CORE itself failed this, so clean installs got
# no core at all. Caught by an outside review, now mechanical.
if python3 -c 'import yaml' >/dev/null 2>&1; then
  BADFM=$(python3 - "$PACK" <<'PYEOF'
import re, sys, glob, yaml
bad = []
for f in glob.glob(sys.argv[1] + '/skills/*/SKILL.md') + glob.glob(sys.argv[1] + '/agents/*.md'):
    m = re.match(r'^---\n(.*?)\n---', open(f).read(), re.S)
    try:
        d = yaml.safe_load(m.group(1)) if m else None
        if not isinstance(d, dict) or 'name' not in d:
            bad.append(f)
    except Exception:
        bad.append(f)
print('\n'.join(bad))
PYEOF
)
  if [ -z "$BADFM" ]; then ok "all frontmatter parses as YAML"; else bad "all frontmatter parses as YAML ($BADFM)"; fi
else
  echo "skip - frontmatter YAML check (python3+yaml unavailable)"
fi

# Every role holds Write — capability is never the fence,
# territory is (v4.1.5). Judges are fenced by the D-09 rule plus
# the leader's tree check, not by stripped tools.
WRITE_OK=1
for f in "$PACK"/skills/*/SKILL.md "$PACK"/agents/*.md; do
  grep -qE "^(allowed-)?tools:.*Write" "$f" || WRITE_OK=0
done
grep -q "voids" "$PACK/skills/dolphin-protocol/SKILL.md" || WRITE_OK=0
if [ "$WRITE_OK" -eq 1 ]; then ok "every role can write; judge fence is a stated rule"; else bad "every role can write; judge fence is a stated rule"; fi

# The capability probe is load-bearing: harnesses differ in what
# spawned delegates can do, and the pod must compose for the
# capability it actually has (full / lens-only / solo).
if grep -q "Probe before you trust the pod" "$PACK/skills/dolphin/SKILL.md" \
   && grep -q "Lens-only" "$PACK/skills/dolphin-leader/SKILL.md"; then
  ok "capability probe + lens-only mode present"
else bad "capability probe + lens-only mode present"; fi

if grep -q "disable-model-invocation: true" "$PACK/skills/dolphin/SKILL.md" \
   && grep -q "dolphin-leader" "$PACK/skills/dolphin/SKILL.md"; then
  ok "router /dolphin is user-invoked and loads the leader"
else bad "router /dolphin is user-invoked and loads the leader"; fi

if [ -f "$PACK/agents/dolphin-agent.md" ] && [ -f "$PACK/agents/dolphin-auditor.md" ]; then
  ok "agent definitions present (agent + auditor)"
else bad "agent definitions present"; fi

if grep -q "^tools:.*Write" "$PACK/agents/dolphin-auditor.md" \
   && grep -q "voids" "$PACK/agents/dolphin-auditor.md"; then
  ok "auditor definition can write, fence stated"
else bad "auditor definition can write, fence stated"; fi

# --- no dead v3 transport -------------------------------------------
if grep -r -q -E "dolphin-say|dolphin-secretary|dolphin-pod" "$PACK/skills" "$PACK/agents"; then
  bad "no skill/agent references the removed v3 transport"
else ok "no skill/agent references the removed v3 transport"; fi

# --- v4.1 core + satellite structure ----------------------------------
CORE="$PACK/skills/dolphin-protocol/SKILL.md"
MISSING=""
for n in 01 02 03 04 05 06 07 08 09 10 11 12; do
  grep -q "\*\*D-$n" "$CORE" || MISSING="$MISSING D-$n"
done
if [ -z "$MISSING" ] && grep -q "Return Gate" "$CORE"; then
  ok "core carries D-01..D-12 + the Return Gate"
else bad "core carries D-01..D-12 + the Return Gate (missing:$MISSING)"; fi

SATFAIL=""
for f in "$PACK"/skills/*/SKILL.md; do
  [ "$f" = "$CORE" ] && continue
  grep -q "dolphin-protocol" "$f" || SATFAIL="$SATFAIL $(basename "$(dirname "$f")"):no-core-ref"
  grep -q "^allowed-tools:" "$f" || SATFAIL="$SATFAIL $(basename "$(dirname "$f")"):no-allowed-tools"
done
if [ -z "$SATFAIL" ]; then ok "every satellite cites the core + declares allowed-tools"; else bad "satellite structure ($SATFAIL)"; fi

CHKFAIL=""
for f in "$PACK"/skills/*/SKILL.md; do
  case "$f" in *dolphin-protocol*|*dolphin-design*) continue ;; esac
  grep -q -i "^## .*checklist" "$f" || CHKFAIL="$CHKFAIL $(basename "$(dirname "$f")")"
done
if [ -z "$CHKFAIL" ] && grep -q "Delivery Report" "$PACK/skills/dolphin-design/SKILL.md"; then
  ok "every satellite ends in a checklist (design: Delivery Report)"
else bad "satellite checklists (missing:$CHKFAIL)"; fi

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
