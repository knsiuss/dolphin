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
3. **Probe before you trust the pod.** Spawn ONE throwaway
   delegate whose whole brief is: read a file in the project,
   write a scratch file at `<project>/.dolphin/probe.txt` — in
   the REAL project path, so workspace-root and path problems
   surface now, not mid-wave — run one trivial shell command,
   and return the three results verbatim. Record the outcome in
   `.dolphin/` and reuse it for this project and harness;
   re-probe when either changes. Compose for the capability you
   actually have:
   - **Full pod** — delegates read, write, and run: compose as
     below.
   - **Lens-only** — delegates read (and maybe run) but cannot
     write: YOU build in this session, announcing each hat
     switch, and delegates judge the diffs as read-only lenses.
     The builder still never judges (D-09) — the judges are
     separate sessions; they simply cannot hold the pen.
   - **Solo** — no usable delegate mechanism: run the roles
     sequentially yourself, hats named, and say so plainly.
     Never fake a pod that isn't running.
4. **Compose the pod** (below). There is no fixed team size:
   the decomposition of the work decides how many delegates
   spawn, and when.
5. **Spawn delegates** through the harness's native subagent
   mechanism, using the `dolphin-agent` / `dolphin-auditor`
   definitions and a written brief per delegate (anatomy in
   `dolphin-leader`).
6. **Route every return through review** at the tier the leader
   assigns. A builder's DONE is a claim, not a result, until a
   lens has checked it (D-09).
7. **Report once to the human**: what shipped, the gate verdicts
   with their evidence, what is blocked and on whom, what is
   next. Decisions as options — never a done deal (D-06).

## Composing the pod

There are no fixed modes and no fixed team size. The leader
composes the pod from the scoped work, under four invariants:

1. **One worker per independent slice.** Decompose the scope;
   every slice that can run now gets its own worker, in parallel.
   One slice → one worker. Nine slices → nine workers. Slices
   with dependencies run in waves, in dependency order.
2. **Every build is judged by a lens that didn't build it**
   (D-09). Lenses parallelise too: on one return, tester,
   security, reviewer, and auditor can run concurrently — they
   read the same diff independently.
3. **Gatekeeping scales with volume.** One auditor is a
   bottleneck and then a rubber stamp. When returns outnumber
   what one judge can actually check, shard the judging: one
   lens per slice or per dimension, plus a gatekeeper who reads
   verdicts, not diffs.
4. **Parallel means disjoint.** Two delegates never edit the same
   files; overlap forces sequential waves or separate worktrees
   — decided before spawning, never mid-run.

Shapes that recur — examples, not a menu: a lone worker + one
auditor for a single outcome; a worker → tester → reviewer chain
when steps depend on each other; a fan-out of workers with
sharded lenses when speed matters; several workers attempting
the SAME hard problem independently, with a gatekeeper picking
the survivor, when no approach is obviously right. Compose
freely between and beyond these. What never changes is the
invariants — and the Return Gate every result passes through.

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
  who builds has no judge left). The one sanctioned exception is
  lens-only mode (step 3): there the leader builds with named
  hats because no delegate can — and the judging still leaves
  the builder's hands.

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
- [ ] Delegate capabilities probed in the real project path
      (read / write / shell); the composition matches the result
- [ ] Pod composed from the decomposition — counts follow the
      work, parallel work is disjoint, judging scales with volume
- [ ] Every return passed the Return Gate before acceptance
- [ ] The human got ONE report: verdicts, evidence, blockers, next
- [ ] If the harness has no subagent mechanism, that was said
      plainly and the roles ran sequentially, hats named — never
      a faked pod
