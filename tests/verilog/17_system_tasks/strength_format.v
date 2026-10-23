// IEEE 1364-2005 §17.1.1.5, pp. 283-284: "The %v format specification is
// used to display the strength of scalar nets. ... The strength of a scalar
// net is reported in a three-character format. The first two characters
// indicate the strength. The third character indicates the current logic
// value of the scalar" (Table 17-4: 0, 1, X, Z, L, H). "For the logic values
// 0 and 1, a mnemonic is used when there is no range of strengths in the
// signal." "For the unknown value, a mnemonic is used when both the 0 and 1
// strength components are at the same strength level." "The high-impedance
// strength cannot have a known logic value; the only logic value allowed for
// this level is Z." Table 17-5 (p. 284): Su supply drive 7, St strong drive
// 6, Pu pull drive 5, ..., Hi high impedance 0.
//
// Each net has one strength, so every value is a mnemonic:
//   s1  `assign s1 = 1'b1`, a continuous assignment's default strong drive
//       (§6.1.4: "If drive strength is not specified, it shall default to
//       (strong1, strong0).") -> St1
//   p1  `assign (pull1, pull0) p1 = 1'b1` -> Pu1
//   s0  a supply0 net (§4.6.6: supply strength) -> Su0
//   hz  a wire with no driver: high impedance -> HiZ
//   sx  two strong drivers, 0 and 1: both components at level 6 -> StX
// Printed at #1, after every continuous assignment has settled.
// §17.1.1.2's example (p. 281) is not reused: it prints "StX" for a net
// driven only by `pulldown (pd)`, which §7.8 (p. 86: "The signals that these
// sources place on nets shall have pull strength") makes Pu0, and it reads
// pd at time 0, racing the gate's first evaluation.
//! inherited IEEE 1364-2005 17.1.1.5
// native-required
`timescale 1ns/1ns
module b_17_1_1_5_strength_format;
  wire s1, p1, hz, sx;
  supply0 s0;
  assign s1 = 1'b1;
  assign (pull1, pull0) p1 = 1'b1;
  assign sx = 1'b0;
  assign sx = 1'b1;
  initial begin
    #1 $display("%v %v %v %v %v", s1, p1, s0, hz, sx);
    $finish(0);
  end
endmodule
