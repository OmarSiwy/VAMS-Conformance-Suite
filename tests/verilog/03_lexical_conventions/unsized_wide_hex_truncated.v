//! inherited IEEE 1364-2005 3.5.1
// An unsized constant has at least 32 bits; VerA's documented choice is to
// truncate this 80-bit hex constant to 32, whose low word is zero
// (pr903).
module triage_unsized_wide_hex_truncated;
  initial $display("%h", 'h9000_0000_0000_0000_0000);
endmodule
