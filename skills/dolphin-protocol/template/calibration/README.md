# Calibration Set

Frozen, human-labelled examples the judge lenses are measured
against: known-good work, known slop, known insecure work.

- Frozen means frozen. Additions and changes are proposed by the
  improve role, approved by the leader, applied by the memory keeper.
- New or changed lenses run report-only against this set until their
  agreement (and false-positive/negative rates) are recorded in
  outcomes.md. Only then may they gate.
- Agreement targets from the literature pipeline this follows:
  human inter-rater kappa ~0.88 is achievable; a judge lens ships as
  a gate at kappa >= 0.6 and should be tuned toward 0.7–0.8. Judging
  runs blind (authorship hidden), cross-family, with order swapped on
  pairwise comparisons. The judged sessions must not be able to read
  this directory — an oracle the builder can read is not an oracle.

## Seeds

`examples/` holds 9 starter seeds (3 good / 3 slop / 3 insecure),
each labelled with the traits that earn its label. This is a starter,
not a finished set: grow it toward ~60 seeds, then ~200, from the
pod's own escaped defects and near-misses — those are the examples
worth the most, because they are the failures this pod actually makes.
