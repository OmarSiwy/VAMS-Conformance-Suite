//! inherited IEEE 1364-2005 17.1.1.5
// %v displays the strength of a scalar net: the strong continuous driver of
// w makes the text St0 (multi_bit_strength; the clause defines no %v text
// for a multi-bit net).
module triage_strength_scalar;
  wire w;

  assign w = 1'b0;

  initial #1 $display("%v", w);
endmodule
