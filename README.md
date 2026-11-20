# Dolphin

Independent AI sessions working as one pod — coordinated by short
structured signals on a shared board, not by chat. Each session sleeps at
zero cost until its name is called, wakes, ACKs, works, reports, sleeps.

Formerly Pear-to-Pear v1. v2 rebuilds the review system on published
evidence (per-dimension gates, two independent test oracles, deterministic
package checks, outcome-based reputation) and adds full slop lenses for
code, copy, design, motion, naming, and database schema, plus a scope
gate and a reference-driven UI workflow. Full reasoning: `DESIGN.md`.

## Quick start

1. Install the skills — one line, any harness (Claude Code, OpenCode,
   Codex, Cursor, and 75+ others):

   ```
   npx skills add knsiuss/dolphin
   ```

   Or use Dolphin's own CLI (same result, plus the pod commands):

   ```
   npx dolphin-pod install claude .      # claude | opencode | codex | cursor | agents
   ```

   No npx? Unzip the pack and use the manual installer instead
   (details in `INSTALL.md`): `scripts/dolphin-install.sh opencode .`

2. In the MAIN checkout of your project, initialise the board. The
   pod's scripts ship inside the `dolphin-protocol` skill; init copies
   them into `.dolphin/bin/`, the stable path from then on:

   ```
   npx dolphin-pod init
   npx dolphin-pod register Lead leader "claude: leader"
   ```

   Without the CLI, run `.agents/skills/dolphin-protocol/scripts/dolphin-init.sh`
   directly (adjust the path if your harness put the skill elsewhere),
   then `.dolphin/bin/dolphin-init.sh --register ...`.

3. Start the pod from the roster (one tmux session + one secretary
   per registered agent):

   ```
   npx dolphin-pod pod up /path/to/project
   npx dolphin-pod pod status /path/to/project
   ```

   Tell each session: its name, its role skill, and to load
   `dolphin-protocol` first. `DOLPHIN_CMD` sets the harness command
   started in each session (default `claude`).

4. Sessions talk only through the board:

   ```
   npx dolphin-pod say Lead @all CLAIM src/auth.ts -- taking the auth fix
   ```

> The pod's scripts are bash (the launcher also needs tmux). On Windows,
> run everything inside WSL.

## The shape of it

- `.dolphin/board.md` — live signals, current state only
- `.dolphin/agents.md` — who exists: name, role, terminal, status
- `.dolphin/outcomes.md` — gate history and outcome metrics (no gate
  is ever a single score)
- `.dolphin/memory/` — shared + per-session memory, tightly budgeted
- `.dolphin/calibration/` — frozen human-labelled examples for judges
- `.dolphin/archive/` — the transcript, for the human's eyes

## Rules of the pod

- Signals are one line, closed vocabulary, pointer not payload.
- No ACK = not received. The secretary re-pokes until ACK.
- State signals are peer-to-peer; tasks flow through the leader.
- Security can veto anything. Nobody is exempt from a gate.
- Scope before build; references before UI; proof before "done".
