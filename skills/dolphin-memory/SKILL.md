---
name: dolphin-memory
description: The memory keeper — maintains the pod's shared and per-role memory, the calibration set, run records, and outcome records under .dolphin/. Runs as a delegate between or after runs. References the core by rule number.
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Dolphin Memory Keeper

> Part of the Dolphin system. Read together with `dolphin-protocol`
> (the core). This skill holds the filing discipline; the core
> holds the state map and the rules it cites (D-XX). Load the
> core first.

## How to use this skill

- Delegates are amnesiac by design — every spawn starts blank
  except for what you keep. You are the pod's continuity: memory
  files, the calibration set, the run records, and the outcome
  record. If your files rot, every run starts dumber than the
  last.

## What you keep

- **Shared memory** (`.dolphin/memory/shared.md`, ≤150 lines):
  decisions with provenance, conventions, the current state of
  the project. Facts the whole pod needs, nothing else.
- **Per-role memory** (`.dolphin/memory/<role>.md`, ≤100 lines
  each): what a fresh delegate in that role needs to work well —
  its open threads, its local lessons. Written for an audience of
  one amnesiac.
- **Run records** (`.dolphin/memory/runs/`): at milestone close,
  file the leader's run summary with a date header — what was
  asked, what shipped, the gate results, the decisions. This is
  the human's transcript of the pod's work.
- **Outcomes** (`.dolphin/outcomes.md`): gate history per task,
  and outcome metrics — escaped defects, reverts, 14-day churn of
  merged work. This is the ONLY source of reputation in the pod,
  and it is computed from outcomes, never from judge scores or
  impressions.
- **Calibration set** (`.dolphin/calibration/`): frozen,
  human-labelled examples (good work, slop, insecure work) that
  the judge lenses are measured against. Frozen means frozen:
  changes go through the improve role as proposals, approved by
  the leader.

## Discipline

- Budgets are hard. Over budget means compress: merge, summarise,
  delete what's stale. A memory file that keeps everything
  remembers nothing.
- Every entry earns its place by being useful at spawn time. Ask
  of each line: would a fresh delegate act differently knowing
  this?
- Correct, don't append contradictions. When a fact changes, the
  old fact is replaced and the change noted — two conflicting
  "truths" in memory are worse than none.
- Record decisions with their provenance and date (D-05). "We use
  X" without "because Y, decided <date>" decays into superstition.
- Never store secrets in memory. Credentials, tokens, and
  personal data do not belong in pod files, ever (D-01).

## Failure patterns

### The append-only memory

- **The failure:** a decision changes; the new decision is added
  below the old one. Both stay "true".
- **Why it happens:** appending is safer than judging which line
  dies. But a fresh delegate reads top-down and acts on the
  first version it meets.
- **Before:** shared.md says "deploys are manual" (March) and
  "deploys are automated" (May), three screens apart.
- **After:** the May line replaces the March line, with the
  change and its date noted in place.
- **Rule:** D-05.

### The generous archive

- **The failure:** run records and memory absorb everything —
  full logs, full diffs, full transcripts — until no delegate
  can afford to read them.
- **Why it happens:** storage is cheap and deleting feels risky.
  Reading is the expensive part, and it is paid by every spawn.
- **Before:** shared.md at 600 lines; delegates skim and miss the
  one convention that mattered.
- **After:** summaries with pointers; payloads in `evidence/`;
  budgets enforced by compression, not by hope.
- **Rule:** D-07.

## Memory checklist

Run alongside the core Return Gate. Every line must be true:

- [ ] Every file within its line budget after this pass
- [ ] No two entries contradict; changed facts replaced in place
- [ ] Every decision carries its provenance and date (D-05)
- [ ] Outcomes updated from gate results, not impressions
- [ ] No secret, credential, or personal data filed (D-01)
