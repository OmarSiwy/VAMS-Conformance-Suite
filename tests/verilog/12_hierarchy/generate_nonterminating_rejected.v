// IEEE 1364-2005 §12.4.1: "It shall be an error if a genvar value is repeated
// during the evaluation of the loop generate scheme", and VAMS §6.6.1: "It
// shall be an error if the loop does not terminate." A genvar is an integer,
// so a loop that never ends repeats a value; VerA detects the repeat rather
// than counting iterations (it gave up at 65536 until 2026-10, #29; the legal
// neighbour generate_past_65536_iterations.v runs past that).
//
// HAND DERIVATION. i steps 0, 1, 2, then (2 + 1) % 3 = 0 again while i < 5
// always holds: the fourth evaluation of the scheme repeats 0.
//! lrm 6.6.1
//! lrm 6.6.1:6
//! lrm 6.6.1:7
//! inherited IEEE 1364-2005 12.4.1
//! reject E1100
//! reject a genvar value is repeated, so this loop generate does not terminate
//! neighbour generate_past_65536_iterations.v
module b_12_generate_nonterminating_rejected;
  genvar i;
  generate for (i = 0; i < 5; i = (i + 1) % 3) begin : g end endgenerate
  initial $display("accepted");
endmodule
