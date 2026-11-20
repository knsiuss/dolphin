#!/usr/bin/env bash
# Dolphin end-to-end smoke test — the pod's regression test.
# Run after ANY change to scripts/. Proves: init · roster enforcement ·
# mechanical claim leases (conflict / prefix / renew / release) ·
# worktree board discovery via git-common-dir · deterministic scans
# (red on fixtures, green on clean, package existence fail-closed) ·
# pod launcher + a real secretary poke landing in a real tmux pane.
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

export DOLPHIN_PROJECT="$TMP/proj"
mkdir -p "$DOLPHIN_PROJECT"
cd "$DOLPHIN_PROJECT" && git init -q .

expect 0 "init creates .dolphin" "$S/dolphin-init.sh"
if [ -x "$DOLPHIN_PROJECT/.dolphin/bin/dolphin-say" ]; then ok "init installs tools into .dolphin/bin"; else bad "init installs tools into .dolphin/bin"; fi
"$S/dolphin-init.sh" --register Lead leader t0 >/dev/null
"$S/dolphin-init.sh" --register Forge worker t1 >/dev/null

expect 2 "unregistered author rejected" \
  "$S/dolphin-say" Ghost @Lead NOTE x -- hi

expect 0 "first claim lands" \
  "$S/dolphin-say" Forge @all CLAIM src/auth.ts -- mine
expect 3 "overlapping claim hard-rejected" \
  "$S/dolphin-say" Lead @all CLAIM src/auth.ts -- mine too
expect 3 "prefix-overlap claim rejected" \
  "$S/dolphin-say" Lead @all CLAIM src/auth.ts/deep -- nested
expect 0 "owner heartbeat renews own claim" \
  "$S/dolphin-say" Forge @all CLAIM src/auth.ts -- heartbeat
"$S/dolphin-say" Forge @all RELEASE src/auth.ts -- done >/dev/null
expect 0 "claim after release lands" \
  "$S/dolphin-say" Lead @all CLAIM src/auth.ts -- now mine

git add -A >/dev/null 2>&1
git -c user.email=t@t -c user.name=t commit -qm init >/dev/null 2>&1
git worktree add -q "$TMP/wt" >/dev/null 2>&1
BEFORE=$(grep -c "" .dolphin/board.md)
( cd "$TMP/wt" && env -u DOLPHIN_PROJECT "$S/dolphin-say" Forge @Lead NOTE board.md -- from worktree >/dev/null 2>&1 )
AFTER=$(grep -c "" .dolphin/board.md)
if [ "$AFTER" -gt "$BEFORE" ]; then ok "worktree session writes to MAIN board"; else bad "worktree session writes to MAIN board"; fi

expect 2 "slop scan red on bad.ts"     "$S/dolphin-scan" slop "$PACK/tests/fixtures/bad.ts"
expect 0 "slop scan green on clean.ts" "$S/dolphin-scan" slop "$PACK/tests/fixtures/clean.ts"
expect 2 "slop scan red on bad.py (except-pass)" "$S/dolphin-scan" slop "$PACK/tests/fixtures/bad.py"
expect 2 "secrets scan red on bad.py"     "$S/dolphin-scan" secrets "$PACK/tests/fixtures/bad.py"
expect 0 "secrets scan green on clean.py" "$S/dolphin-scan" secrets "$PACK/tests/fixtures/clean.py"
expect 0 "pkg: react exists"              "$S/dolphin-scan" pkg npm react
expect 2 "pkg: hallucinated name rejected" "$S/dolphin-scan" pkg npm react-ultra-mega-fake-pkg-zzz

if command -v tmux >/dev/null; then
  rm -f /tmp/dolphin-secretary-*.state
  DOLPHIN_CMD="cat" "$S/dolphin-pod.sh" up "$DOLPHIN_PROJECT" >/dev/null
  if "$S/dolphin-pod.sh" status "$DOLPHIN_PROJECT" | grep -q "Forge: session=up secretary=up"; then
    ok "pod up: Forge session + secretary"
  else
    bad "pod up: Forge session + secretary"
  fi
  "$S/dolphin-say" Lead @Forge TASK scope/x.md -- poke test >/dev/null
  sleep 8
  if tmux capture-pane -t Forge -p 2>/dev/null | grep -q "DOLPHIN:"; then
    ok "secretary poke landed in Forge's pane"
  else
    bad "secretary poke landed in Forge's pane"
  fi
  "$S/dolphin-pod.sh" down "$DOLPHIN_PROJECT" >/dev/null
else
  echo "skip - tmux unavailable, poke test not run"
fi

echo "smoke: $PASS passed, $FAIL failed (workdir kept at $TMP)"
[ "$FAIL" -eq 0 ]
