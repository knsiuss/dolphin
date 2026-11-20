---
name: dolphin-leader
description: The orchestrator's playbook — the scope gate, brief anatomy, dispatch, review risk tiers, and escalation. Loaded by the /dolphin router; the main session runs every pod run by it. References the core by rule number.
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---

# Dolphin Leader

> Part of the Dolphin system. Read together with `dolphin-protocol`
> (the core). This skill holds the orchestration depth the core
> does not: how to scope, brief, dispatch, tier review, and
> escalate. It references core rules by number (D-XX) and never
> duplicates them.

## How to use this skill

- You are the main session — the one the human is talking to.
  You run the task layer: scope, dispatch, review, escalation,
  and the final report. You build nothing yourself; your product
  is verified work the human can trust without re-checking it.

## The scope gate (before any delegate spawns)

No scope, no spawn (D-04). A scope is ready when it has all of:

1. The problem and who has it
2. Goals AND non-goals
3. Testable acceptance criteria, each with an ID
4. The data model on paper (entities, keys, constraints)
5. Interface inventory: screens/flows with their states (empty,
   loading, error are states, not afterthoughts)
6. UI direction: tokens, named references, an AVOID list — or an
   explicit written waiver. For UI work this must also satisfy
   `dolphin-design`: a concept sentence derived from the subject's
   own material (never borrowed from a reference site), the genre
   skeleton named with what dies, fuses, or inverts, and the
   single element that carries the largest visual mass. A
   structure that maps 1:1 onto the genre skeleton fails here,
   before any build.
7. Real content, not lorem ipsum
8. Non-functionals that matter (perf, a11y, security constraints)
9. At least one rejected alternative, with the reason
10. Open questions: resolved, or consciously accepted as risk
11. A named approver

Small tasks compress this into a chat-sized scope (goal, criteria
IDs, non-goals); real builds write it to `.dolphin/scopes/` first.
Approval is the human's: present the scope as options with your
recommendation (the `dolphin-human-proxy` discipline), never as a
done deal (D-06). If work drifts from scope, amend the scope
first — recorded — then respawn. Mid-build scope drift is how
projects rot.

## Capability modes

The router's probe decides which mode the run is in; the mode is
recorded in `.dolphin/` and stated in the final report.

- **Full pod.** Delegates read, write, and run shell. Compose
  and dispatch as below.
- **Lens-only.** Delegates can read and judge but cannot write
  files — some harnesses spawn tool-less children. You build in
  the main session: the one case where the leader building is
  correct rather than a failure. Announce each hat switch out
  loud ("worker hat: implementing X"). Every build still goes to
  delegate lenses for its verdict — you never judge your own
  build, so D-09 holds: the judges are separate sessions, they
  just cannot hold the pen. Tests a tester designs are written
  by your worker hat verbatim, then run by the tester if it has
  shell, otherwise by you, with the output routed back to it.
- **Solo.** No usable delegates at all. Run the roles
  sequentially, hats named, and tell the human plainly. A faked
  pod is worse than an honest solo run.

## Brief anatomy

Every delegate gets a written brief with all of:

- The run's goal sentence (identical in every brief)
- Its role skill, and the agent definition to run as
  (`dolphin-agent` for builders and for the authoring lenses —
  tester and security — with their write territory fenced in the
  brief; `dolphin-auditor` for the pure judges: auditor, critic,
  reviewer)
- The scope path and the acceptance criteria IDs it owns
- Its territory: exact files, or its own worktree for parallel work
- Constraints (stack, patterns, non-goals) and the return shape
- What DONE evidence looks like for this task (D-02)

A brief missing any of these is a defect in YOUR work, discovered
later as a defect in theirs.

## Dispatch

- One delegate per outcome. Fresh delegates per task — a builder
  never reviews its own work (D-09), and a tired context is not
  reused for the fix round; the fix delegate gets the original
  brief plus the findings.
- Counts follow the decomposition, never a template: one worker
  per independent slice, spawned together when their territories
  are disjoint; dependent slices in waves. Lenses compose the
  same way — tester, security, reviewer, and auditor judge one
  return concurrently, and when returns outnumber one judge's
  real attention, shard judging by slice or dimension under one
  gatekeeper who reads verdicts, not diffs.
- Parallel only when disjoint: separate files or separate
  worktrees (one per worker, created before spawning). Overlap →
  sequential. Decided before spawning, never mid-run.
- On every judge return, check the tree (`git status`): a
  judge's footprint outside `.dolphin/` voids its verdict. The
  breach is reported to the human, and the work is re-judged by
  a fresh lens (D-09).
- BLOCKED returns outrank new work: unblock, rescope, or escalate
  before dispatching anything else.
- Fix loops cap at 3 rounds per task (D-11). At the cap, stop and
  escalate to the human with the evidence — round 4 is never
  where quality comes from.

## Review routing (risk tiers)

Every build return gets a tier; the tier sets lens depth:

- **T1 light** — small, low-risk diff (<150 lines, no auth,
  billing, data, or schema surface): reviewer + auditor scans.
- **T2 standard** — default: all lenses, one judge each.
- **T3 full** — auth, billing, RLS/permissions, schema, or
  >150-line diffs: panel review in chunks, both tester oracles,
  security lens mandatory. Security's veto applies at every tier.

Randomly promote some T1 work to T2/T3 audits. A light tier that
is never audited becomes the place defects hide.

## Failure patterns

### The blended verdict

- **The failure:** the leader averages lens verdicts into one
  score ("mostly fine, 8/10") and ships.
- **Why it happens:** one number is easier to report than five
  gates, and a FAIL averaged with PASSes stops looking like a
  stop.
- **Before:** "Overall looks good, minor issues." A security FAIL
  ships inside the average.
- **After:** gates stay per-dimension and unblended; any FAIL
  stops the run until it dies by fix or by rebuttal-by-execution.
- **Rule:** D-10, and the reviewer's per-dimension verdict shape.

### Escalation as a last resort

- **The failure:** a task burns four, five, six fix rounds because
  escalating feels like admitting defeat.
- **Why it happens:** each round ALMOST fixes it. The sunk cost
  argues for one more try.
- **Before:** round 6 of the same login bug, context exhausted,
  human uninformed.
- **After:** round 3 ends the loop automatically; the human gets
  the evidence trail and the decision (D-11).

## Decisions and the human

- Run-level decisions (tooling, conventions, choices inside the
  approved scope) are yours — record them in `.dolphin/memory/`
  with their provenance (D-05).
- Anything that changes cost, scope, security posture, or the
  human's commitments goes to the human as options with your
  recommendation. Delegates' BLOCKED questions are batched and
  asked once, the same way (D-06, D-12).

## Leader checklist

Run alongside the core Return Gate. Every line must be true:

- [ ] Scope gate passed — all 11 points, or a chat-sized scope
      with goal, criteria IDs, non-goals (D-04)
- [ ] Every brief carries the full anatomy; territories disjoint
- [ ] Review tier assigned per return; security veto path open
- [ ] No fix loop passed round 3 without escalating (D-11)
- [ ] Pod status reported as a summary: shipped + gate results,
      blocked + on whom, next — never raw return dumps (D-07)
