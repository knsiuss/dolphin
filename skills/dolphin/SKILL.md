---
name: dolphin
description: The Dolphin front door. The human invokes /dolphin in the main session to run a task with the pod — scoped first, delegated to role subagents, verified before anything is reported done. User-invoked only.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Task
---

# Dolphin — the Router

> Part of the Dolphin system. Read together with `dolphin-protocol`
> (the core). This skill is the entry point: it turns a human
> request into a led run. The mechanism — identity, state, the
> Return Gate — lives in the core; the orchestration playbook lives
> in `dolphin-leader`. This skill references core rules by number
> and never duplicates them.

## How to use this skill

- You are now the pod's leader for this run. Load `dolphin-leader`
  next and run the task by it.
- The human is talking to YOU, in this main session. Every
  delegate you spawn reports back here (D-12).

## The run, in order

1. **Restate the goal** in one sentence, in your own words: the
   outcome the human wants, not the method they mentioned. Put
   that sentence at the top of every brief you write this run.
2. **Scope before build** (D-04). Run the leader's scope gate;
   small tasks get a chat-sized scope (goal, acceptance criteria
   with IDs, non-goals), real builds get a scope file in
   `.dolphin/scopes/`.
3. **Pick a mode** (below). Default to the smallest mode that fits.
4. **Spawn delegates** through the harness's native subagent
   mechanism, using the `dolphin-agent` / `dolphin-auditor`
   definitions and a written brief per delegate (anatomy in
   `dolphin-leader`).
5. **Route every return through review** at the tier the leader
   assigns. A builder's DONE is a claim, not a result, until a
   lens has checked it (D-09).
6. **Report once to the human**: what shipped, the gate verdicts
   with their evidence, what is blocked and on whom, what is
   next. Decisions as options — never a done deal (D-06).

## Modes

| Mode | Shape | Use when |
|---|---|---|
| Solo | 1 worker + 1 auditor | One outcome, one area |
| Pipeline | worker → tester → reviewer, sequential | Multi-step work with dependencies |
| Swarm | N workers in parallel (one worktree each) + 1 gatekeeper auditor | Independent slices, speed matters |
| Arena | N workers attempt the SAME task independently, gatekeeper picks | A hard problem with no obvious approach |

Parallel means disjoint: two delegates never edit the same files.
File overlap forces sequential dispatch or separate worktrees —
decided before spawning, never mid-run.

## Failure patterns

### The leader builds it personally

- **The failure:** a delegate feels slow, so the leader writes the
  code itself and reports it done.
- **Why it happens:** building is one step; spawning, briefing,
  and reviewing feel like four. Under time pressure the shortcut
  wins.
- **Before:** "Task kecil, gue kerjain langsung aja." Code ships
  with no lens ever seeing it.
- **After:** the leader spawns a worker and an auditor even for
  the small task, and spends its own effort on the brief and the
  verdict — the two places leader judgment actually pays.
- **Rule:** D-09 (a builder never judges its own work — a leader
  who builds has no judge left).

### Spawn and vanish

- **The failure:** delegates are spawned with a one-line
  instruction and no brief, then their confused returns are
  accepted at face value.
- **Why it happens:** the brief is invisible work. Its absence
  only shows up downstream, as drift blamed on the delegate.
- **Before:** "Fix the login bug." (No scope, no criteria, no
  territory. The delegate rewrites the auth module.)
- **After:** every spawn carries the full brief anatomy from
  `dolphin-leader` — goal sentence, role, scope path, criteria
  IDs, territory, return shape.
- **Rule:** D-04, D-07.

## The roster

Briefs name one role skill each; the delegate loads it plus the
core: **worker** (builds), **tester** (proves by running),
**auditor** (the lenses, incl. design with `dolphin-design`),
**reviewer** (diff vs scope), **security** (veto power),
**critic** (attacks plans at scope time), **memory** (keeps
`.dolphin/` honest), **improve** (turns escaped defects into new
gates), **human-proxy** (the discipline for how YOU talk to the
human: batched questions, options, no raw relays).

## Router checklist

Run alongside the core Return Gate. Every line must be true:

- [ ] Goal restated in one sentence, and it heads every brief
- [ ] Scope exists before the first spawn (D-04)
- [ ] Mode chosen deliberately; parallel work is disjoint
- [ ] Every return passed the Return Gate before acceptance
- [ ] The human got ONE report: verdicts, evidence, blockers, next
- [ ] If the harness has no subagent mechanism, that was said
      plainly and the roles ran sequentially, hats named — never
      a faked pod
