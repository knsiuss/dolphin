---
name: dolphin-design
description: The UI design law — a numbered filter with tiers and a mandatory PASS/FAIL delivery report, judged on rendered screenshots, never on source. Direction comes from the subject's material and a written reference brief; this skill supplies the filter, never the direction. Load in any session that builds or audits UI, alongside its role skill.
disable-model-invocation: false
---

# Dolphin Design

Slop is a structural failure, not a styling failure. A page can pass
every token, palette, and provenance check and still be the genre
default wearing a costume. This skill exists because Dolphin pilot
pages did exactly that — every gate PASS, and the owner still read
them instantly as AI slop. So this skill is a filter with a memory:
numbered rules in three tiers, a brief before code, a liveliness
gate, and one mandatory report that closes every UI task.

A filter is not a direction. Direction comes from the subject's own
material and from references studied for principles. A filter
without direction produces clean, dead pages; that failure is named
and gated below (the Liveliness Gate), because it has happened here.

Load `dolphin-protocol` first. Its principles bind you; security first.

## Gate 0 — the reference brief (no brief, no code)

- Before any UI code, a brief exists (REFERENCE.md in the project,
  or a brief section in the scope) naming 1–3 references, and for
  each: the principle taken, stated as a decision rule ("Enter is
  primary, Cmd+K is everything else"), never as a look ("like
  Linear"); why it fits *this* subject; and what is explicitly
  NOT being taken, and why.
- For flow work at least one reference must be a real shipped
  product. Award/concept galleries may set ambition for a surface;
  they are never the sole evidence for a flow.
- Provenance test, one sentence per reference: "We take X from
  [reference] because [our subject/task] shares [the condition
  that made X work there]; we will know it failed if [observable]."
  If the because is "it looks premium", it is copying. Stop.
- The brief names the page's **visual carrier** — what the eye
  actually lands on: real artwork, the real product, or type
  itself. If the subject's own language is pictorial (games,
  film, places, worlds), the carrier is artwork made for this
  subject, and the brief lists the pieces (a hero, plus one per
  state or major section). Layout does not start until the
  carrier exists as files: designing around a placeholder is
  designing a different, worse page.

## The three tests (they outrank every checklist)

1. **Strip test.** Mentally delete every label, badge, figure
   number, caption, and class name. If the remaining structure —
   section order, proportions, mass, rhythm — still reads as a
   generic page of its genre, there is no design, only decoration.
   A signature must live in the structure.
2. **Swap test.** Replace the subject's name, photo, and content
   with another person's. If the design still works, it is a
   template. A real design breaks under swapped content, because
   it was built *from* this content and no other.
3. **Screenshot test.** Design is judged on rendered screenshots —
   desktop and mobile widths — never on source code. Squint: one
   mass must dominate and the hierarchy must survive. Shrink to a
   thumbnail: it must still not look like the genre default. An
   audit performed without looking at a rendering is void.

## Concept provenance: from the subject, not from a reference

- The concept is derived from the subject's own material: their
  product's real interface, their data, their documents, their
  artefacts, their habits, the physical thing itself. References
  teach craft — type behaviour, spacing discipline, motion values.
  They never supply the concept. "Linear does it" is not
  provenance; it is borrowing an identity.
- The scope records three things in plain words: the concept in
  one sentence; the subject-material it is derived from; the
  observable in the rendered page that proves it is there.
- If the concept sentence could describe another person's page in
  the same genre, it is not a concept yet. Rewrite until it can't.

## The rules — cite them by number in every report

### Tier 1 — hard rules. Any one failure fails the gate.

- **R1 · No invented evidence.** Statistics, testimonials, logos,
  dates, and counts are real or absent. Undated, unsourced numbers
  are slop even when the layout is honest.
- **R2 · Concept on record.** The scope carries the concept
  sentence, its subject-material, and its observable proof
  (see above). No record, no build.
- **R3 · Kill the centroid skeleton.** Every genre has a default
  skeleton (a portfolio: person → featured work → work list → log
  → experience → skills → contact). The scope names it, then
  states what the concept does to it: which sections die, which
  fuse, which invert, and which single element carries the
  largest visual mass. A structure that maps 1:1 onto the genre
  skeleton fails, regardless of styling.
- **R4 · States are deliverables.** Empty, loading, and error
  states — plus offline/permission where relevant — are designed,
  not defaulted. The states a gallery never shows are the ones
  users actually meet.
- **R5 · One verb, one primary action.** Each view has one
  primary action; the page is built around one repeated verb.
- **R6 · Colour is behaviour.** Every colour states where it may
  appear and what it means there. A gradient is an owned,
  specific asset confined to its zone, or it is absent. A generic
  indigo-to-violet wash is an automatic fail.
- **R7 · No artefact cosplay.** A product's real surface may
  appear as evidence — one artefact, shown properly. Its skin is
  never the page's skin. (Evidence: a company profile typeset
  entirely as terminal panels — every section a box — was
  rejected as stiff on sight. The artefact was true; the costume
  was the failure.)
- **R8 · No render, no verdict.** Building or auditing without
  current screenshots of the actual artefact is incomplete work.

### Tier 2 — tells. Two or more on one page is a presumption of
slop; the only rebuttal is structure (the three tests, shown).

- **R9 · The current tells, cumulative:** mono uppercase
  micro-labels on every block · figure/plate numbering as
  identity · lab-report / evidence-plate cosplay · timestamp or
  log cosplay without real data behind it · Geist or Inter named
  as "the tasteful choice" · one rationed accent in a sea of
  grey · hairline everything · neo-brutalist sharp boxes with
  hard offset shadows worn as a default skin (a system the visitor
  can see is a system that has failed) · the same gap rhythm down
  the whole page · three identical cards in a row · a centred hero floating
  over a generic gradient · abstract blob or stock-style hero
  illustration · copy that could belong to three competitors
  ("supercharge your workflow") · a colophon bragging about the
  stack.
- **R10 · Type is argued, not fashionable.** A pairing is argued
  from the subject's voice and material — what their documents,
  product, or trade look like — never from what award sites
  currently run. The defaults of the year are a tell, not a taste.
- **R11 · One moment of chosen scale.** The most important fact
  or artefact gets the most mass: full-bleed, oversized type
  (display at least ~3–4× body), or deliberate emptiness around
  it. Uniform treatment of unequal things is the tell of an
  undecided page. Timid evenness is not taste.
- **R12 · Restricted palette.** At most ~3 meaningful hues
  unless the subject's own material demands more, and the brief
  says why.

### Tier 3 — polish values. Checked last, as values, not vibes.

- **R13 · Motion is specified, not felt.** Every animation lists:
  purpose (feedback / spatial consistency / state change /
  continuity / explanation / delight), duration (≤300ms for UI;
  one-shot entrance choreography may run longer and says so),
  easing (never `ease-in` on UI), transform/opacity only,
  interruptible where the user can act mid-flight, keyboard-
  initiated actions unanimated, `prefers-reduced-motion` honoured.
- **R14 · Exact details.** Concentric radii (outer = inner +
  padding) · optical alignment over geometric · shadow-as-border
  before drawn borders · tabular numerals for data · hit areas
  ≥44px · press scale 0.96–0.98 · one interactive colour, and it
  appears nowhere else.

## The Liveliness Gate

Passing R1–R14 is necessary. It is not sufficient.

- A page with **no owned asset** and **no purposeful motion** is
  a FAIL with the finding "clean, but dead" — however well it
  filters. (Evidence: a profile that passed structure and hygiene
  was rejected with "the design and the motion are simply not
  there." The rebuild kept the skeleton and added the two missing
  things; nothing else changed.)
- **Owned asset:** one thing only this subject could have — their
  artefact, their data's natural form, a motif drawn from their
  material (an orbit, for a product named for the far point of
  one) — pushed hard enough that the page passes hide-the-logo:
  cover the name and it still cannot be a competitor's page.
- **Motion:** surfaces that are alive (marketing, profiles,
  consumer pages) must move with purpose per R13. Tool surfaces
  (dense product UI) ration motion — but the rationing is a
  decision recorded in the brief, not an omission. Stillness
  chosen is a pass. Stillness by default is a fail.
- **The owned asset may have to be real artwork.** When the
  subject's own language is pictorial (games, film, places,
  products with a world), CSS-drawn scenery — gradient skies,
  SVG silhouettes, abstract shapes — is itself a slop dialect
  (the retrowave look), however clean the layout over it. The
  fix is real artwork, made or commissioned for the subject,
  with type going quiet on top of it. (Evidence: a game page
  failed twice on CSS scenery and passed the owner's eye only
  when rebuilt over original paintings.)

## Modes

- **DURING** (default for builds): the brief, rules, and tests
  guide the work while it is built; the task closes with the
  Delivery Report below.
- **AFTER** (audits of existing work): produce a numbered
  findings list, by rule, from screenshots. The owner approves
  which findings get fixed. Never silently rewrite in audit mode;
  close with a follow-up report on what changed.

## Builder process

1. Reference brief (Gate 0) + concept sentence and its material.
   If the carrier is artwork, the pieces exist as files first.
2. Structural sketch in plain boxes — no colours, no fonts. Run
   the strip and swap tests on the sketch. If it fails in boxes,
   it fails dressed; do not proceed.
3. Build.
4. Screenshot loop, at least two iterations: render desktop +
   mobile, look, name what is wrong in structural words (mass,
   order, rhythm — not "spacing feels off"), change it, re-render.
5. Hand the auditor the screenshots with the build, and close
   with the Delivery Report. Source-only handoff is incomplete.

## The Delivery Report — mandatory, closes every UI task

```
DESIGN GATE — <artefact name>
Brief:      present / missing · concept: "<one sentence>"
Carrier:    artwork | product | type — <the files; "CSS scenery"
            on a pictorial subject is an automatic FAIL>
Tests:      STRIP pass|fail — <what structure survives>
            SWAP pass|fail — <what breaks>
            SCREENSHOT pass|fail — <what dominates, desktop+mobile seen>
Tier 1:     R1..R8 pass|fail each, one line of evidence per fail
Tier 2:     tells found: <list, or "none">
Tier 3:     checked / not checked
Liveliness: owned asset = <what> · motion = <what, or the recorded
            reason for stillness> · verdict ALIVE / DEAD
Verdict:    PASS / FAIL — <one sentence>
```

- The PASS sentence must name the structural signature in words
  that could not describe another page in the genre. If the
  auditor cannot write that sentence, the verdict is FAIL and
  that is the finding.
- No screenshots attached, no PASS — the work is returned as
  unseen, not failed-by-default and never as passed.
- Hygiene (Tier 3) is checked after the three tests and the
  Liveliness Gate, never instead of them. Hygiene cannot rescue
  a centroid structure, and a filter pass cannot rescue a dead
  page.
