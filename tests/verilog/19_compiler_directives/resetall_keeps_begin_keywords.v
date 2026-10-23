// IEEE 1364-2005 §19.6, p. 356: "When `resetall compiler directive is
// encountered during compilation, all compiler directives are set to the
// default values." §19.11, p. 364: "The pair of directives define a region of
// source code", and the reserved set holds "until the matching `end_keywords
// directive is encountered".
//
// The reading (specification/Vague_Decisions.md VD-043): a region closed only by its
// matching directive is not a setting with a "default value", so `resetall
// leaves it open. Otherwise §19.6's own recommended usage, `resetall at the
// head of each file, would break §19.11's pairing inside any region.
//
// Under "1364-1995" uwire (new in 1364-2005) is an ordinary identifier. If
// `resetall popped the region back to the default 1364-2005 set, `uwire`
// below would be a keyword and refused (E0208, as in the neighbour
// uwire_in_2005_rejected.v), and `end_keywords would be unmatched
// (E0136). It is a 64-bit net assigned 5 -> "uwire=5" at time 1.
//! inherited IEEE 1364-2005 19.6 19.11
`begin_keywords "1364-1995"
`resetall
module b_19_6_resetall_keeps_begin_keywords;
  wire [63:0] uwire = 64'd5;
  initial #1 $display("uwire=%0d", uwire);
endmodule
`end_keywords
