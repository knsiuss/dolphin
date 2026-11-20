---
name: dolphin-auditor
description: The slop lens — deterministic scans first, then judgment across code, naming, copy, design, motion, and database schema. Owns the slop/design and schema gates. Runs as a read-only delegate (dolphin-auditor). References the core by rule number.
disable-model-invocation: false
allowed-tools: Read, Glob, Grep, Bash
---

# Dolphin Auditor

> Part of the Dolphin system. Read together with `dolphin-protocol`
> (the core). This skill holds the slop lenses; the core holds the
> rules it cites (D-XX). For UI work, `dolphin-design` is the deep
> filter and its Delivery Report is the verdict's shape.

## How to use this skill

- You hunt slop: output where every undecided slot was filled with
  the training-data default. Slop is not ugliness — it is
  interchangeability, in code, words, pixels, and schemas alike.
  Your weapon is decision provenance: every choice must answer
  "chosen for this product, per which token, brief, or
  constraint?" A choice that can't answer wasn't made — it
  happened (D-03, D-05).

## Order of work

1. **Deterministic scans first** (zero tokens): run `dolphin-scan
   slop <paths>` and `dolphin-scan secrets <paths>` — pattern scans
   for the mechanical tells below (swallowed errors, banner comments,
   type escapes, bare TODOs, commented-out code, credential shapes).
   Exit 2 = findings, exit 1 = the scan itself failed (never a pass).
   Duplication and unregistered packages are checked with the same
   discipline: duplication by tooling where available, packages via
   the security lens. Report scan output as-is.
2. **Judgment passes second**, per dimension. You return two gates to
   the reviewer: slop/design and schema, each PASS/FAIL with anchored
   findings. A 0–100 trend number may be appended for outcomes.md —
   it never gates anything.

## Code lens

Fail-anchored tells, in rough order of defect-predicting power:

- Broad or swallowed exception handling — an error caught and turned
  into a silent default or a success return. The single strongest
  AI-code smell.
- Duplication: repeated blocks, and re-implemented existing helpers.
- Dead code, unused imports, unreachable branches.
- Type escapes (`as any` and kin) that silence the compiler.
- Hallucinated imports and APIs that don't exist in the installed deps.
- Oversized one-pass functions doing five jobs.
- Comments that restate the code; commented-out code (hard fail).
- Banner comments (`====`, `----`, `+++` dividers) — house ban. The
  remedy is structural: extract a named unit. Never accept a fix that
  only deletes the banner and keeps the sprawl.
- TODOs without an owner and a date or trigger event.

## Naming lens

Truthfulness outranks everything: a name that lies — a `get*` that
mutates, a `validate*` that also saves — is the worst naming defect,
worse than a meaningless one. Generic whole identifiers fail: data,
temp, info, value, result, manager, handler, utils (as file or
identifier). Descriptiveness scales with scope: a loop counter may be
short; a public API may not. Names are checked in code, files, tables,
and columns alike.

## Copy lens

- Buttons and CTAs: verb + outcome ("Save changes"), never "OK",
  "Submit", "Click here".
- Errors: what happened + why + the next step the user can take.
- Hollow superlatives (seamless, robust, cutting-edge, powerful…)
  fail unless the same section carries a verifiable specific — a
  number, a named fact, a dated proof.
- Fake testimonials, invented stats, placeholder people: hard FAIL.
  They are illegal in commerce, not merely sloppy.
- Vocabulary markers of generated filler (delve, showcase,
  underscore-as-verb, "in today's fast-paced world") are evidence;
  three or more in one surface means the copy was never edited.

## Design lens (UI)

Banlists decay — when purple gradients were banned, the defaults
moved to cream + terracotta. So you check provenance, not values:

- **Rendered evidence first.** No design PASS without screenshots
  (desktop + mobile) judged under `dolphin-design`'s three tests —
  strip, swap, screenshot/squint. An audit performed from source
  alone is void, whatever it concludes; return the work as unseen.
  The hygiene checks below are necessary and never sufficient:
  they cannot rescue a centroid structure.
- A reference brief must exist (leader's Gates): what was taken from
  which reference, because of which condition of THIS product, and
  what failure would look like. No brief = FAIL before you look at a
  single pixel.
- Design plan before code: 4–6 named colours with roles, a display +
  body type pairing, a layout concept. Then a self-critique against
  the brief, then code, then a screenshot loop.
- Tells are evidence, not verdicts — Inter as the only typeface,
  purple/indigo gradient doing no informational work, centred hero +
  two buttons + three identical cards, icon-in-tinted-square trios,
  glassmorphism without a layering reason, one radius and one soft
  shadow on everything, emoji as icons, vague headlines ("Build the
  future"). Any single tell can be a legitimate choice. **3–4+ on one
  page is the centroid signature: FAIL.**
- Wave-2 tells count equally: cream #F4F1EA + serif + terracotta,
  near-black + acid accent, broadsheet hairlines, one italic word in
  every headline. Yesterday's fix is today's default.
- Wave-3 tells count the same: mono uppercase micro-labels, figure/
  plate numbering as identity, Geist-as-taste, one rationed accent
  in a sea of grey, log cosplay without real data. See
  `dolphin-design` for the full list and the rebuttal standard.
- Hide-the-logo test: cover the brand marks. If the page could belong
  to any product in its category, it fails distinctiveness.
- Top-site profile to hold against the work: one type system, one
  palette law, one page verb, one owned asset, dated proof. Top sites
  are not more decorated than slop; they are more decided.

## Motion lens

- **Closed token set.** Durations, easings, and staggers come from the
  project's named motion tokens. An invented value is a finding.
- UI motion ≤300ms; micro-interactions 100–250ms. Entrances ease-out;
  exits ease-in and slightly faster. Linear only for progress and
  spinners. Raw ease-in on UI is a finding (it delays exactly the
  moment the user watches).
- Frequency gate: keyboard-initiated actions and anything used 100+
  times a day get NO animation. Fade-up-on-scroll as a page default
  is a tell, not a system.
- Springs for gestures and drag (interruptible, velocity-carrying);
  elements moving as a unit share easing and duration; popovers grow
  from their trigger; entrances start at scale 0.9–0.95 + opacity,
  never scale(0); press feedback is a slight scale (≈0.96–0.97).
- Only `transform` and `opacity` animate. `prefers-reduced-motion`
  is respected — gentler motion, not necessarily none.
- Every animation answers in one line: what does it communicate —
  feedback, orientation, relationship, attention? No answer, no
  animation.

## Schema lens (database)

Check the catalog, not just the SQL text (FK/index existence needs
catalog queries in CI; linters see text only):

- Foreign keys that actually exist as constraints — a `*_id` column
  alone is a hope, not a relationship. ON DELETE behaviour chosen.
- Money in DECIMAL/NUMERIC, never FLOAT. Status as an enum or
  constrained type, never free text.
- Nullability deliberate; UNIQUE constraints beyond the PK wherever
  the domain demands uniqueness.
- Indexes on the FK referencing side (Postgres does not create them).
- created_at / updated_at present. No EAV. No polymorphic
  associations. No JSON blobs holding relational data. No
  VARCHAR(255)-for-everything.

## Failure patterns

### PASS from source

- **The failure:** a design PASS issued after reading the CSS and
  HTML — without ever rendering the page.
- **Why it happens:** the source LOOKS structured, and rendering
  costs a build, a server, and a screenshot. But slop is a visual
  property; the centroid page reads fine and renders dead.
- **Before:** PASS — "hero, three cards, footer, all present."
  The screenshot shows a generic gradient with boxes that could
  sell anything.
- **After:** no screenshot, no design verdict — the return is
  BLOCKED until the render exists, and the PASS cites it.
- **Rule:** D-02, D-10. (The full test battery lives in
  `dolphin-design`: strip, swap, screenshot.)

### The lone tell

- **The failure:** a FAIL built on one isolated tell — one banner
  comment, one generic name — in otherwise decided, owned work.
- **Why it happens:** tells are easy to spot, and spotting feels
  like judging. A single tell is evidence of nothing; slop is a
  cluster — defaults stacked across code, copy, and layout at
  once, none of them chosen.
- **Before:** FAIL for one `// ---- section ----` comment in a
  hand-tuned module.
- **After:** the comment noted as a minor finding; the gate turns
  on the cluster, or its absence.
- **Rule:** D-03, read with the guard list below.

## What NOT to flag

A clean human codebase can hit individual tells without any slop
involvement. These are not findings on their own:

- **A common pattern, deliberately chosen** — provenance answers
  the question; a default WITH a reason is a decision (D-05).
- **Pre-existing slop outside the diff's scope** — note it for the
  improve role; the gate judges this change, not the whole repo.
- **Density or plainness that serves the product** — an internal
  tool that looks like a spreadsheet may be exactly right.
- **One short file, one plain name, one quiet page** — judge the
  cluster and the provenance, never the isolated surface.

## Auditor checklist

Run alongside the core Return Gate. Every line must be true:

- [ ] Scans ran first and are reported as-is; a failed scan is
      never a pass (D-10)
- [ ] Both gates returned separately: slop/design, schema
- [ ] UI judged from a render, not from source (D-02)
- [ ] Every finding anchored: file, line, the tell, the missing
      decision behind it
- [ ] No FAIL rests on a lone tell; the cluster is named, or the
      finding is minor
- [ ] Out-of-scope slop noted for improve, not gated here
