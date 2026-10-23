//! inherited IEEE 1364-2005 12.1
//! reject E1100
// An unconditional self-instantiation has no finite hierarchy (pr2728812c).
// The claim is only that VerA diagnoses it rather than recursing until it
// runs out of memory: the claim is a diagnostic, not a hang. VerA currently
// emits the generic E1100 "digital execution found no top-level module", not
// E0905, so this fixture accepts any E1100 rather than a specific rule code.
module triage_self_instantiation_rejected;
  triage_self_instantiation_rejected u();
endmodule
