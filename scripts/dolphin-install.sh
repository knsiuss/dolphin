#!/usr/bin/env bash
# dolphin-install.sh — install the Dolphin skills into a harness's
# skill directory. The skills are standard Agent Skills (a folder with
# SKILL.md: name + description frontmatter), so the same files serve
# Claude Code, OpenCode, Codex and Cursor unchanged. Only the target
# directory differs per harness. v4 has no pod to start: the main
# session is the runtime, delegates are subagents.
#
# Usage:
#   dolphin-install.sh <harness> [project-dir] [--global]
#
#   harness:  claude | opencode | codex | cursor | agents
#   project-dir defaults to the current directory.
#   --global installs into your home directory instead of a project.
#
# Targets:
#   claude    project .claude/skills/      global ~/.claude/skills/
#   opencode  project .opencode/skills/    global ~/.config/opencode/skills/
#   codex     project .agents/skills/      global ~/.agents/skills/
#   cursor    project .cursor/skills/      global ~/.cursor/skills/
#   agents    project .agents/skills/      global ~/.agents/skills/
#             (neutral path: OpenCode, Codex and Cursor all read it)
#
# Note: OpenCode also reads .claude/skills/ and .agents/skills/
# directly, so a Claude Code install is already visible to OpenCode.
set -euo pipefail

HARNESS="${1:-}"
PROJECT="."
GLOBAL=0
for arg in "${@:2}"; do
  case "$arg" in
    --global) GLOBAL=1 ;;
    *) PROJECT="$arg" ;;
  esac
done

case "$HARNESS" in
  claude)   SUB=".claude/skills";   GLOB="$HOME/.claude/skills";            CMD="claude" ;;
  opencode) SUB=".opencode/skills"; GLOB="$HOME/.config/opencode/skills";   CMD="opencode" ;;
  codex)    SUB=".agents/skills";   GLOB="$HOME/.agents/skills";            CMD="codex" ;;
  cursor)   SUB=".cursor/skills";   GLOB="$HOME/.cursor/skills";            CMD="cursor-agent" ;;
  agents)   SUB=".agents/skills";   GLOB="$HOME/.agents/skills";            CMD="<your harness command>" ;;
  *) echo "usage: dolphin-install.sh <claude|opencode|codex|cursor|agents> [project-dir] [--global]" >&2; exit 1 ;;
esac

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills"
[ -d "$SRC" ] || { echo "dolphin-install: skills/ not found next to the pack" >&2; exit 1; }

if [ "$GLOBAL" -eq 1 ]; then DEST="$GLOB"; else DEST="$PROJECT/$SUB"; fi
mkdir -p "$DEST"

count=0
for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  rm -rf "${DEST:?}/$name"
  cp -r "$skill" "$DEST/$name"
  count=$((count + 1))
done

# Agent definitions: Claude Code reads .claude/agents/. Other
# harnesses adapt the same two files to their subagent format;
# they are copied alongside the skills either way so nothing is lost.
AGENTS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/agents"
if [ "$HARNESS" = "claude" ] && [ -d "$AGENTS_SRC" ]; then
  if [ "$GLOBAL" -eq 1 ]; then ADEST="$HOME/.claude/agents"; else ADEST="$PROJECT/.claude/agents"; fi
  mkdir -p "$ADEST"
  cp "$AGENTS_SRC"/*.md "$ADEST/"
  echo "dolphin: agent definitions installed -> $ADEST"
fi

echo "dolphin: $count skills installed -> $DEST"
echo "next steps:"
echo "  1. in the MAIN checkout, run dolphin-init.sh from the installed"
echo "     dolphin-protocol skill's scripts/ folder (scaffolds .dolphin/)"
echo "  2. in your main session, type: /dolphin <the task>"
