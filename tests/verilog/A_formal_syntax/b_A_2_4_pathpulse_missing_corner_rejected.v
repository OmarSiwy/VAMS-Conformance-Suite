// IEEE 1364-2005 A.2.4 derives a PATHPULSE$ limit through a constant
// mintypmax expression. A.8.3 requires all three expressions in its colon
// form; the missing typical expression below cannot derive that grammar.
// E0209 pins the missing-expression refusal. The legal neighbour
// b_A_2_4_pathpulse_mintypmax.v supplies all three and runs its buffer.
//! inherited IEEE 1364-2005 A.2.4
//! reject E0209
//! neighbour b_A_2_4_pathpulse_mintypmax.v
module b_A_2_4_pathpulse_missing_corner_rejected(input a, output y);
  assign y = a;
  specify
    specparam PATHPULSE$ = (1::3);
    (a => y) = 1;
  endspecify
endmodule
