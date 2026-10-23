// A header whose ONLY content is a compiler directive, for 57.
//
// §10.1: "The scope of compiler directives extends from the point where it is
// processed, ACROSS ALL FILES PROCESSED, to the point where another compiler
// directive supersedes it or the processing completes." An `include is how this
// suite can put a file boundary in the middle of one compilation, so this file
// exists to be on the far side of one.
//
// Not a fixture: tests/suite.zig walks `.va` only.
`default_nettype none
