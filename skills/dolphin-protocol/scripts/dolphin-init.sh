#!/usr/bin/env bash
# dolphin-init.sh — scaffold .dolphin/ durable state in the current
# project (or $DOLPHIN_PROJECT) from the template, and install the
# pod's deterministic tools into .dolphin/bin/.
#
# v4: state only. There is no registry, no board, no pod to start —
# the leader session creates .dolphin/ once per project and the
# harness does everything else.
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../template"
PROJECT="${DOLPHIN_PROJECT:-$PWD}"
DOT="$PROJECT/.dolphin"

[ -d "$TEMPLATE" ] || { echo "dolphin-init: template not found next to the scripts — run init from the dolphin-protocol skill folder" >&2; exit 1; }

mkdir -p "$DOT/scopes" "$DOT/evidence" "$DOT/memory/runs" "$DOT/calibration"
cp -n "$TEMPLATE/outcomes.md" "$DOT/outcomes.md"
cp -n "$TEMPLATE/memory/README.md" "$DOT/memory/README.md"
# calibration set travels whole (README + labelled examples)
find "$TEMPLATE/calibration" -type f | while IFS= read -r f; do
  rel="${f#"$TEMPLATE"/calibration/}"
  mkdir -p "$DOT/calibration/$(dirname "$rel")"
  cp -n "$f" "$DOT/calibration/$rel"
done

# The pod's deterministic tools live project-local: .dolphin/bin/ is
# the stable path the skills mean by a dolphin-* tool, independent of
# where the skills themselves are installed or which harness runs.
mkdir -p "$DOT/bin"
for s in dolphin-scan dolphin-metrics dolphin-init.sh; do
  cp "$SCRIPT_DIR/$s" "$DOT/bin/$s"
done
chmod +x "$DOT/bin"/*

GITIGNORE="$PROJECT/.gitignore"
touch "$GITIGNORE"
grep -qx ".dolphin/" "$GITIGNORE" || echo ".dolphin/" >> "$GITIGNORE"

echo "dolphin: .dolphin/ ready in $PROJECT (tools in .dolphin/bin/)"
