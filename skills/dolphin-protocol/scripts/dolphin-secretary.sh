#!/usr/bin/env bash
# dolphin-secretary.sh — one per session. Zero tokens, plain script.
# Watches the board and pokes its session (tmux send-keys, one line)
# when the session is mentioned. v3: reminders are PER-SIGNAL — an ACK
# only settles the signal whose object it names — with exponential
# backoff per signal.
#
#   DOLPHIN_AGENT=<tag> [DOLPHIN_PANE=<tmux-target>] \
#   [DOLPHIN_WAKE=focused|all|off] dolphin-secretary.sh <project-dir>
#
# Wake modes (operator-owned, set by the human):
#   focused — poke only on direct @<tag> mentions
#   all     — poke on @<tag> and @all (default)
#   off     — never poke (the script exits)
# DOLPHIN_PANE defaults to the agent tag (a tmux session named by tag).
# DOLPHIN_POLL default 5s · DOLPHIN_REPOKE default 900s (base interval;
# per-signal interval doubles each poke, capped at 8x).
set -u

PROJECT="${1:?usage: dolphin-secretary.sh <project-dir>}"
AGENT="${DOLPHIN_AGENT:?set DOLPHIN_AGENT=<tag>}"
POLL="${DOLPHIN_POLL:-5}"
REPOKE="${DOLPHIN_REPOKE:-900}"
PANE="${DOLPHIN_PANE:-$AGENT}"
WAKE="${DOLPHIN_WAKE:-all}"
BOARD="$PROJECT/.dolphin/board.md"
STATE="/tmp/dolphin-secretary-$AGENT.state"
touch "$STATE"

[ "$WAKE" = "off" ] && exit 0

poke() {
  tmux send-keys -t "$PANE" "DOLPHIN: $1" Enter 2>/dev/null || true
}

# acked OBJECT — true if the board holds an ACK from $AGENT naming $1
acked() {
  grep -q " ACK $1 | .*\[from:$AGENT " "$BOARD"
}

while true; do
  if [ -f "$BOARD" ]; then
    now="$(date +%s)"
    while IFS= read -r line; do
      case "$WAKE" in
        focused) case "$line" in *"@$AGENT "*) ;; *) continue ;; esac ;;
        *)       case "$line" in *"@$AGENT "*|*"@all "*) ;; *) continue ;; esac ;;
      esac
      verb="$(printf '%s' "$line" | awk '{print $2}')"
      object="$(printf '%s' "$line" | awk '{print $3}')"
      h="$(printf '%s' "$line" | md5sum | cut -d' ' -f1)"
      rec="$(awk -v h="$h" '$1==h' "$STATE" | tail -1)"
      if [ -z "$rec" ]; then
        poke "new $verb for @$AGENT on the board — read the delta and ACK"
        echo "$h $now 1" >> "$STATE"
        continue
      fi
      case "$verb" in
        TASK|HANDOFF|REVIEW|BLOCKED)
          acked "$object" && continue
          last="$(printf '%s' "$rec" | awk '{print $2}')"
          count="$(printf '%s' "$rec" | awk '{print $3}')"
          interval=$(( REPOKE * (1 << (count - 1)) ))
          [ "$interval" -gt $(( REPOKE * 8 )) ] && interval=$(( REPOKE * 8 ))
          if [ $((now - last)) -ge "$interval" ]; then
            poke "reminder: $verb $object still unACKed — ACK or act"
            sed -i "s/^$h .*/$h $now $((count + 1))/" "$STATE"
          fi
          ;;
      esac
    done < "$BOARD"
  fi
  sleep "$POLL"
done
