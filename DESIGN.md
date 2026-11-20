# Dolphin — Design Decisions

Dolphin is a cross-session agent-coordination stack. Independent AI sessions
(Claude Code, or any terminal agent) work as one pod: they coordinate through
short structured signals on a shared board, never through token-burning chat.
Dolphin v2 supersedes Pear-to-Pear v1 (20 Nov 2026): renamed at the owner's
request, and rebuilt around three research rounds on review quality, slop
causes, and top-tier UI references (reports in ~/workspace/research_notes/).

## Why "Dolphin"

A group of dolphins is a pod. Dolphins coordinate hunts across distance with
a closed vocabulary of clicks and whistles, and each dolphin answers to a
unique signature whistle — its name. That is this architecture: closed-vocab
signals, name-tag mentions, one pod per project. No fruit was harmed.

## The unit is the session

- Every role is its own session in its own terminal, started by the human.
- A session has an identity: a name/tag, one role, and that role's skill.
- Lifecycle: sleep (zero cost) → mention → wake → read board delta + own
  memory → ACK → work → DONE or BLOCKED → sleep.
- Sessions may spawn subagents internally; coordination is between sessions.

## Communication: signals, not chat

- One board per project: `.dolphin/board.md` in the MAIN checkout (worktrees
  point to it; the folder is gitignored). The board holds current state only.
- Closed vocabulary: TASK, HANDOFF, CLAIM, RELEASE, REVIEW, DONE, BLOCKED,
  ACK, NOTE. One line per signal, sent only via the `dolphin-say` script so
  the format can never drift: `@target VERB target | one-line note`.
- A signal carries a pointer, never a payload. Payloads live in files.
- A signal without an ACK is not received. ACK is a protocol duty.
- Topology: state signals (CLAIM/RELEASE/DONE/BLOCKED) are peer-to-peer;
  the task layer (dispatch, handoff, decisions) flows through the leader.
  HANDOFF + ACK = ownership has officially moved.
- Claims are binding, first-claim-wins — and since v3 they are
  mechanical: `dolphin-say` holds leases with a TTL, hard-rejects
  overlapping claims, and reaps expired ones. The leader arbitrates
  only what the mechanism cannot.
- Archive (`.dolphin/archive/`) is the human-readable transcript. Agents
  never read it; they read current state, not history.

## The secretary (per session, zero tokens)

A plain script, not an LLM. It watches the board and pokes its own session
(tmux send-keys, one line) when the session's tag or @all is mentioned.
UnACKed TASK/HANDOFF/REVIEW/BLOCKED signals re-poke on an interval until
ACKed or resolved. A dolphin's click, on a timer.

## Roles (one skill each, every skill under 250 lines)

Leader, Worker, Memory Keeper, Tester, Reviewer, Critic, Auditor,
Security Reviewer, Human Proxy, Self-Improvement — plus the shared
Dolphin Protocol skill every session loads. Skills are per-role on purpose:
each session carries only the judgment its job needs.

## Dolphin Review v2 — what the research changed

v1 gated on a single 0–100 score at 75. The literature has no basis for any
such threshold, absolute judge scores are the least calibratable signal, and
a composite average lets style points cancel out correctness or security
failures. v2 replaces it:

1. **Per-dimension gates, not one score.** Correctness, spec-fit, security,
   slop/design, and schema each return PASS or FAIL against anchored
   criteria. A 0–100 figure survives only as a dashboard trend in
   outcomes.md — it never gates anything.
2. **Two independent oracles (Tester).** Tests derived from the spec by a
   session that did not write the code, plus a held-out oracle set the
   builder cannot see or touch, run in an isolated environment. Tests
   written after faulty code detect far fewer faults; mutation gates are
   valid only against spec-derived suites.
3. **Deterministic before judgment, everywhere.** Scanners (slop patterns,
   secrets, package existence) run first at zero token cost. Every new
   dependency is verified in its official registry before install —
   roughly 1 in 5 LLM-suggested packages is hallucinated, and agreement
   between models does not validate a package. Only a registry check does.
4. **Cross-family judging.** A judge must come from a different model
   family than the builder; self-preference is measured and causal.
5. **Proof-only critique.** Critic and Reviewer findings must carry proof
   (a run, a counterexample, a spec clause). The builder may kill a finding
   by execution. Unproven findings are logged but never consume fix rounds.
   Fix loop capped at 3, then the leader escalates with evidence.
6. **Risk-tiered depth.** Review accuracy collapses as diffs grow, so diffs
   over ~150 lines are reviewed in chunks/panels, low-risk work gets light
   lenses, and random full audits keep the light tier honest.
7. **Security holds a veto.** ~45% of AI code choices are insecure in
   vendor measurement; the veto overrides every other gate.
8. **Outcome-based reputation.** Standing comes from outcomes — escaped
   defects, reverts, 14-day churn — never from judge scores (circular,
   Goodhart-bait). Reputation steers routing and scrutiny depth only;
   it never exempts anyone from a gate.
9. **Calibration before gating.** New lenses run report-only against a
   frozen, human-labelled example set until their agreement is measured.
   Judge health (false-positive rate, cross-lens disagreement) is tracked
   like any other metric.

## The slop lenses (Auditor)

Slop is distributional convergence: every undecided slot filled with the
training-data default. So the lenses check decisions, not decoration.

- **Code:** broad or swallowed exceptions (the strongest defect predictor),
  duplication, dead code, `as any`, hallucinated imports, oversized
  one-pass functions, comments that restate code, commented-out code.
  Banner comments (`====`, `----`) are a house ban — and the remedy is
  structural: extract a named unit, don't just delete the line.
- **Naming:** truthfulness outranks cleverness — a `get*` that mutates is
  the worst defect class. Generic whole-identifier names (data, temp,
  info, value, manager, handler, utils) fail. Descriptiveness scales
  with scope.
- **Copy:** buttons are verb + outcome; errors say what + why + next step;
  hollow superlatives fail unless the same section holds a verifiable
  specific; fake testimonials or stats are a hard fail (they are illegal,
  not merely sloppy).
- **Design:** decision provenance, not banlists — banlists decay (banning
  purple gradients produced the cream-and-terracotta wave). Every major
  visual choice must answer "chosen for this product, per which token or
  brief?" Tells (Inter-only type, purposeless purple gradient, centred
  hero + two buttons + three identical cards, icon-in-tinted-square,
  cream #F4F1EA + terracotta, near-black + acid accent, broadsheet
  layouts) are evidence of unmade decisions; 3–4+ on one page is the
  centroid signature and fails. The hide-the-logo test must pass.
- **Motion:** a closed token set — named durations, easings, staggers;
  no invented values. UI motion ≤300ms; entrances ease-out, exits
  ease-in and faster; linear is for progress only; keyboard-initiated
  and 100+-times-a-day actions get no animation; transform and opacity
  only; springs for gestures; prefers-reduced-motion respected. Every
  animation states in one line what it communicates.
- **Database:** FK constraints that actually exist, deliberate ON DELETE,
  DECIMAL for money (never FLOAT), deliberate nullability, UNIQUE beyond
  the PK where the domain demands it, indexes on the FK referencing side
  (Postgres does not add them), created_at/updated_at, no EAV, no
  polymorphic associations, no JSON blobs for relational data. Verified
  with catalog queries, not by reading SQL text.

## Scope gate (Leader)

No build TASK exists before a scope doc passes the checklist: problem and
user; goals AND non-goals; testable acceptance criteria with IDs; data
model on paper; interface and screen/state inventory; UI direction
(tokens, named references, AVOID list — or an explicit waiver); real
content, not lorem; non-functionals; at least one rejected alternative
with its reason; open questions resolved or consciously accepted; a named
approver. Amend the spec first, then the code. Approval routes through
the Human Proxy.

## UI work: reference-driven (Gates 0–6, condensed)

Reference brief with provenance before code ("we take X from [reference]
because [our condition], and we'll know it failed if [observable]") →
system before screens (tokens first) → states are deliverables (empty,
loading, error) → motion specified, not vibes → screenshot critique loop
→ exact-value polish pass → provenance repeated in the final report.
Top sites are not more decorated than slop; they are more decided: one
type system, one palette law, one page verb, one owned asset, dated proof.

## v3.1 — the pilot verdict that changed the design gate

The first live pilot's portfolio v2 passed every gate — scope,
slop/design, functional tests, an amendment loop — and the owner
still read it instantly as AI slop. He was right. Post-mortem found
two structural causes, neither visible to a textual audit:

1. **The signature was a label, not a structure.** Figure numbering
   (borrowed from Linear's teardown) renamed the standard portfolio
   skeleton — person → featured work → list → log → experience →
   skills → certifications → contact — without changing it. The
   concept was borrowed identity, and its provenance paperwork was
   in order the whole time.
2. **Nobody ever looked at the page.** The auditor measured the
   source (pixel arithmetic on layout); the tester verified
   function. A design gate that never renders cannot see design.

The fix is a dedicated skill, `dolphin-design`, binding on any
session that builds or audits UI: the concept must derive from the
subject's own material; the genre skeleton must be named and
broken (sections die, fuse, or invert; one element carries the
mass); and the design gate is judged on rendered screenshots under
three tests — strip (structure survives labelling), swap (design
breaks under another person's content), squint/thumbnail (one mass
dominates). Hygiene checks remain, demoted to after the tests. The
auditor may not PASS what it has not seen rendered, and a PASS must
name the structural signature in a sentence that fits no other page
in the genre.

## Shared principles (in every role skill)

Security first — it wins every conflict. Prove it by running the real
thing. No slop in code, copy, design, naming, or schema. Scope before
build. Decisions carry provenance. Big choices are offered as options,
not executed silently. Signals are short; payloads live in files.

## v3 — what the landscape research changed

A November 2026 survey of the most-starred agent-skill systems
(mattpocock/skills, obra/superpowers, ECC, anthropics/skills, gstack,
Hallmark, Impeccable, pstack, and the cross-session coordinators
agmsg, MCP Agent Mail, Beads, Symphony) found one dominant failure
across nearly all of them: guarantees written as prose to the model,
not enforced by mechanism — and measured token blowups wherever
context is loaded always-on. Dolphin v3 therefore spent its budget
on mechanism, not more prose:

- **Mechanical claim leases** in `dolphin-say` (atomic check, TTL,
  heartbeat-by-renew, auto-reap, hard reject on overlap) — Beads'
  claim semantics, but blocking where Agent Mail's leases are
  advisory.
- **Deterministic scanners as scripts** (`dolphin-scan`): package
  existence fail-closed (the Spracklen defence), config/slop/secrets
  rules, Impeccable's exit-code convention (0 clean / 2 findings /
  1 scan-failed — a failed scan is never a pass), and mutation
  fixtures that must turn the scanner red.
- **Worktree board discovery** via `git rev-parse --git-common-dir`:
  a worktree session finds the main checkout's board with no env
  config.
- **A launcher** (`dolphin-pod.sh up|status|down`) driven by the
  roster file — gstack's status UX, without silent auto-update.
- **Per-signal reminders**: an ACK settles only the signal whose
  object it names; backoff doubles per poke. Wake relevance is the
  operator's setting (focused/all/off), after aboard.
- **Calibration seeds**: 9 labelled examples ship in the template,
  with kappa gates (ship at ≥0.6, tune toward 0.7–0.8), blind +
  cross-family + order-swapped judging, and the set unreadable by
  judged sessions.
- **Outcome metrics from git** (`dolphin-metrics`): reverts and
  14-day churn computed, escapes and kappa honestly left manual.
- **A scripted end-to-end smoke test** (`tests/smoke.sh`) kept as
  the pod's regression test — the "never run live" gap is closed by
  making the live run repeatable.

Explicitly NOT adopted, with reasons recorded in the research:
always-on mega-packs (measured 41k tokens/session of standing
context), prose-only enforcement, self-grading, polling wake-ups
(blocked receive costs ~0 tokens; polling costs millions per hour),
shared-credential coworker computers (identity/authority unsolved —
their own builders admit it), and chat-style free-form messaging.

## Per-harness contract

- **Full** (tmux + a terminal agent): secretaries poke, sessions
  wake on mention, all gates available.
- **Degraded** (no tmux): the board, leases, and scanners still work;
  sessions check the board when the human nudges them. Nothing about
  correctness depends on the poke.
- **Minimal** (board only): signals and claims still enforce format
  and ownership through `dolphin-say`. A harness that cannot run the
  scripts at all is out of the pod — prose-only membership is the
  failure mode this design exists to avoid.

## dolphin-design v2 — the filter architecture (20 Nov 2026)

The design skill was rebuilt as a numbered filter, after the
Aphelion company-profile rounds supplied two new failures the old
prose gates had no names for: a page built without ever opening
the reference research (fixed by Gate 0, the written reference
brief — the same Gate 0 the reference-canon workflow specifies),
and a page that passed every structural check yet was dead on
arrival — no owned asset, no motion (fixed by the Liveliness
Gate). The skill now carries: tiered rules R1–R14 cited by number
(Tier 1 hard, Tier 2 tells, Tier 3 exact polish values), DURING /
AFTER modes, and a mandatory Delivery Report that closes every UI
task — a PASS must name the structural signature in one sentence
or it is void. The three tests, concept provenance, and the
centroid-skeleton ban are unchanged; they were already Dolphin's.
The tiered-filter + closing-report architecture was studied from
the public antislop rulebook (miqdadbadjuber/anti-slop, MIT) and
rewritten from Dolphin's own evidence — no text or rule wording
was taken from it.

## Layout

```
dolphin/
  DESIGN.md  README.md
  skills/    dolphin-protocol + 10 role skills + dolphin-design
  template/  .dolphin/ skeleton (board, agents, outcomes, memory,
             calibration, archive)
  scripts/   dolphin-init.sh, dolphin-say, dolphin-secretary.sh
```
