// A header whose ONLY content is a compiler directive, for 01.
//
// §10.2 states the file-boundary rule in its own words rather than leaning on
// §10.1: the default applies "until either the end of the text stream or
// another `default_discipline directive with the qualifier (if applicable) is
// found in the subsequent text, EVEN ACROSS SOURCE FILE BOUNDARIES."
//
// An `include is the only way a one-file-per-invocation runner can put a file
// boundary inside a single compilation, so this file exists to be on the far
// side of one. Not a fixture: the harness walks `.va` only.
`include "disciplines.vams"
`default_discipline electrical
