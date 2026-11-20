#!/usr/bin/env bash
# dolphin-pod.sh — the pod launcher. Reads the roster from
# .dolphin/agents.md and starts one tmux session per agent (named by
# tag) plus one secretary per agent. No silent auto-update, no magic:
# up starts exactly what the roster says, down stops exactly that.
#
#   dolphin-pod.sh up|status|down [project-dir]
#
# The command run in each session is $DOLPHIN_CMD (default: claude).
# Set DOLPHIN_CMD to your harness's start command per machine.
set -u

ACTION="${1:?usage: dolphin-pod.sh up|status|down [project-dir]}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="${2:-${DOLPHIN_PROJECT:-$PWD}}"
AGENTS="$PROJECT/.dolphin/agents.md"
RUN="$PROJECT/.dolphin/run"
CMD="${DOLPHIN_CMD:-claude}"

[ -f "$AGENTS" ] || { echo "dolphin-pod: no .dolphin/agents.md in $PROJECT (run dolphin-init.sh)" >&2; exit 1; }

# roster tags: table rows under "## Agents", skipping header/separator/placeholder
tags() {
  awk '/^## Agents/{on=1; next} /^## /{on=0} on && /^\| [A-Za-z]/ && $0 !~ /Tag/ {print $2}' "$AGENTS"
}

case "$ACTION" in
  up)
    mkdir -p "$RUN"
    for tag in $(tags); do
      if tmux has-session -t "$tag" 2>/dev/null; then
        echo "up: $tag already running"
      else
        tmux new-session -d -s "$tag" -c "$PROJECT" "$CMD"
        echo "up: session $tag ($CMD)"
      fi
      pidf="$RUN/secretary-$tag.pid"
      if [ -f "$pidf" ] && kill -0 "$(cat "$pidf")" 2>/dev/null; then
        echo "up: secretary $tag already running"
      else
        DOLPHIN_AGENT="$tag" DOLPHIN_PANE="$tag" \
          nohup "$SCRIPT_DIR/dolphin-secretary.sh" "$PROJECT" \
          >> "$RUN/secretary-$tag.log" 2>&1 &
        echo $! > "$pidf"
        echo "up: secretary $tag (pid $!)"
      fi
    done
    ;;
  status)
    for tag in $(tags); do
      sess="down"; tmux has-session -t "$tag" 2>/dev/null && sess="up"
      sec="down"
      pidf="$RUN/secretary-$tag.pid"
      [ -f "$pidf" ] && kill -0 "$(cat "$pidf")" 2>/dev/null && sec="up"
      echo "$tag: session=$sess secretary=$sec"
    done
    ;;
  down)
    for tag in $(tags); do
      pidf="$RUN/secretary-$tag.pid"
      if [ -f "$pidf" ]; then
        kill "$(cat "$pidf")" 2>/dev/null && echo "down: secretary $tag"
        rm -f "$pidf"
      fi
      if tmux has-session -t "$tag" 2>/dev/null; then
        tmux kill-session -t "$tag" && echo "down: session $tag"
      fi
    done
    ;;
  *) echo "usage: dolphin-pod.sh up|status|down [project-dir]" >&2; exit 2 ;;
esac
