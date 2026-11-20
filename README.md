# Dolphin

A pod that lives inside one session. The main session leads: it
scopes the work, spawns short-lived delegates through the harness's
own subagent mechanism, routes every result through independent
verification lenses, and is the only voice the human hears. No
separate runtime, no message bus, no terminals to babysit — if the
harness can spawn a subagent, Dolphin runs.

Formerly Pear-to-Pear v1 (independent tmux sessions + a signal
board). v2 rebuilt the review system on published evidence
(per-dimension gates, two independent test oracles, deterministic
package checks, outcome-based reputation) and added full slop
lenses. v3 added the design filter architecture and the visual
carrier gate. **v4 moves the pod into the harness**: the board,
signal vocabulary, secretary, and tmux launcher are deleted, and
coordination rides the mechanism every modern harness already has —
subagents whose results return to the session that spawned them.
Full reasoning: `DESIGN.md`.

## Quick start

1. Install the skills — one line, any harness (Claude Code,
   OpenCode, Codex, Cursor, and 75+ others):

   ```
   npx skills add knsiuss/dolphin
   ```

   No npx? Unzip the pack and use the manual installer instead
   (details in `INSTALL.md`): `scripts/dolphin-install.sh claude .`
   — it also places the agent definitions where Claude Code reads
   them (`.claude/agents/`).

2. Per project, scaffold the pod's durable state once. The tools
   ship inside the `dolphin-protocol` skill; init copies the
   deterministic scanner into `.dolphin/bin/`:

   ```
   .agents/skills/dolphin-protocol/scripts/dolphin-init.sh
   ```

3. In your main session, type:

   ```
   /dolphin <the task>
   ```

   The router scopes the task, spawns worker and lens delegates
   with written briefs, collects their returns, and reports back
   once — verdicts with evidence, not a stream of chatter.

## The shape of it

The pack is a core + satellites (the antislop architecture):
`dolphin-protocol` is the core — the numbered rules D-01..D-12 and
the Return Gate — and every other skill cites those rules by
number instead of restating them, teaches its patterns as
failure / why / before / after, and closes with a checklist.

- `skills/dolphin/` — the router (`/dolphin`), the front door
- `skills/dolphin-protocol/` — citizenship: principles, file
  discipline, report shapes; ships the deterministic tools
  (`dolphin-scan`, `dolphin-metrics`) and the `.dolphin/` template
- `skills/dolphin-leader/` — the orchestrator's playbook: scope
  gate, brief anatomy, dispatch, review tiers
- 10 role skills — worker, tester, auditor, reviewer, security,
  critic, design, memory, human-proxy, improve
- `agents/` — two subagent definitions every delegate runs as:
  `dolphin-agent` (builders) and `dolphin-auditor` (read-only
  lenses — a judge whose hands were off the work)
- `.dolphin/` in your project — durable state only: `scopes/`,
  `evidence/`, `memory/`, `calibration/`, `outcomes.md`

## Rules of the pod

- Scope before build; references before UI; proof before "done".
- Files are written with file tools, never through the shell.
- A builder never judges its own work; security can veto anything.
- Delegates return evidence or they didn't finish. A gap is not a
  pass, and nobody is exempt from a gate.
- Decisions reach the human as options, through the leader, once.
