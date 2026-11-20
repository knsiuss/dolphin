#!/usr/bin/env bash
# dolphin-init.sh — create .dolphin/ in the current project (or
# $DOLPHIN_PROJECT) from the template, and register pod sessions.
#
#   dolphin-init.sh                              # initialise
#   dolphin-init.sh --register <tag> <role> [terminal]
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../template"
PROJECT="${DOLPHIN_PROJECT:-$PWD}"
DOT="$PROJECT/.dolphin"

if [ "${1:-}" = "--register" ]; then
  TAG="${2:?usage: --register <tag> <role> [terminal]}"
  ROLE="${3:?usage: --register <tag> <role> [terminal]}"
  TERM="${4:-}"
  AGENTS="$DOT/agents.md"
  [ -f "$AGENTS" ] || { echo "dolphin-init: no .dolphin/agents.md — run init first" >&2; exit 1; }
  ROW="| $TAG | $ROLE | $TERM | active |"
  if grep -q "register with dolphin-init" "$AGENTS"; then
    sed -i "s#| _(register with dolphin-init.sh --register)_ | | | |#$ROW#" "$AGENTS"
  else
    sed -i "/^|---/a $ROW" "$AGENTS"
  fi
  echo "registered: $TAG ($ROLE)"
  exit 0
fi

[ -d "$TEMPLATE" ] || { echo "dolphin-init: template not found next to the scripts — run init from the dolphin-protocol skill folder" >&2; exit 1; }

mkdir -p "$DOT/memory" "$DOT/calibration" "$DOT/archive"
for f in board.md agents.md outcomes.md; do
  cp -n "$TEMPLATE/$f" "$DOT/$f"
done
cp -n "$TEMPLATE/memory/README.md" "$DOT/memory/README.md"
cp -n "$TEMPLATE/archive/README.md" "$DOT/archive/README.md"
# calibration set travels whole (README + labelled examples)
find "$TEMPLATE/calibration" -type f | while IFS= read -r f; do
  rel="${f#"$TEMPLATE"/calibration/}"
  mkdir -p "$DOT/calibration/$(dirname "$rel")"
  cp -n "$f" "$DOT/calibration/$rel"
done

# The pod's tools live project-local from now on: .dolphin/bin/ is the
# stable path every skill means by a dolphin-* command, independent of
# where the skills themselves are installed or which harness runs them.
mkdir -p "$DOT/bin"
for s in dolphin-say dolphin-secretary.sh dolphin-scan dolphin-pod.sh dolphin-metrics dolphin-init.sh; do
  cp "$SCRIPT_DIR/$s" "$DOT/bin/$s"
done
chmod +x "$DOT/bin"/*

GITIGNORE="$PROJECT/.gitignore"
touch "$GITIGNORE"
grep -qx ".dolphin/" "$GITIGNORE" || echo ".dolphin/" >> "$GITIGNORE"

echo "dolphin: .dolphin/ ready in $PROJECT (tools in .dolphin/bin/)"
