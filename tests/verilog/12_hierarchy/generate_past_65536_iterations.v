// IEEE 1364-2005 §12.4.1 unrolls a loop generate at elaboration and bounds
// nothing about the count. VerA gave up after 65536 iterations (E1100) until
// 2026-10 (#29); a loop that ends now runs to its end, and one that does not
// is caught by the clause's repeated-genvar rule
// (generate_nonterminating_rejected.v).
//
// HAND DERIVATION. i runs 0 to 65536, 65537 iterations, one past the old
// bound. Only the last iteration's conditional block (i == 65536) drives w,
// to 1; the other 65536 iterations are empty blocks. So w is 1 at #1.
//! inherited IEEE 1364-2005 12.4.1
//! expect stdout generate_past_65536_iterations.expected.txt
`timescale 1ns/1ns
module b_12_generate_past_65536_iterations;
  wire w;
  genvar i;
  generate for (i = 0; i <= 65536; i = i + 1) begin : g
    if (i == 65536) begin : last
      assign w = 1'b1;
    end
  end endgenerate
  initial #1 $display("%b", w);
endmodule
