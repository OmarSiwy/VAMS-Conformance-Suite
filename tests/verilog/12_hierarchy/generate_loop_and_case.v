// IEEE 1364-2005 §12.4.1: "A loop generate construct permits a generate block
// to be instantiated multiple times ... Within the generate block ... there is
// an implicit localparam declaration ... its value within each instance of
// the generate block is the value of the index variable at the time the
// instance was elaborated", and a named block "is a declaration of an array of
// generate block instances. The index values in this array are the values
// assumed by the genvar". Each iteration is "a separate scope and a new level
// of hierarchy", so §17.1.1.6's %m names it `g[i]`.
//
// §12.4.2: in a case generate construct "the case_generate_item selected is
// the one whose expression matches the case expression"; the others are not
// instantiated.
//
// HAND DERIVATION. The loop runs i = 0, 1, 2 (i < 3), so three leaves exist,
// g[0].u, g[1].u and g[2].u, and each receives i * 10: 0, 10, 20. They print
// at t=1 in elaboration order. SEL = 2 selects the `2:` arm, so only module b
// exists and prints at t=2; modules a (arms `0, 1` and `default`) never run.
//! inherited IEEE 1364-2005 12.4.1 (loop generate, implicit localparam, block array)
//! inherited IEEE 1364-2005 12.4.2 (case generate)
`timescale 1ns/1ns
module leaf(input [7:0] v);
  initial #1 $display("%m v=%0d", v);
endmodule
module a; initial #2 $display("case arm a"); endmodule
module b; initial #2 $display("case arm b"); endmodule
module top;
  parameter SEL = 2;
  genvar i;
  generate
    for (i = 0; i < 3; i = i + 1) begin : g
      leaf u(i * 10);
    end
    case (SEL)
      0, 1: begin : c0 a u(); end
      2: begin : c1 b u(); end
      default: begin : cd a u(); end
    endcase
  endgenerate
endmodule
