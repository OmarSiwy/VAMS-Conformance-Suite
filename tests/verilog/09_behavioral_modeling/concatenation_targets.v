// IEEE 1364-2005 §9.3, p. 122: "The left-hand side of the assignment in the
// assign statement shall be a variable reference or a concatenation of
// variables." ... "In contrast, the left-hand side of the assignment in the
// force statement can be a variable reference or a net reference. It can be a
// concatenation of any of the above."
// §9.3.2, p. 125: "if any variable on the right-hand side of the assignment changes,
// the assignment shall be reevaluated while the assign or force is in effect."
//
//   s = 0: assign {x, y} = {s, ~s}    -> x 0, y 1
//   s = 1: reevaluated                -> x 1, y 0
//   deassign {x, y}; force {n1, n0} = {s, ~s}, n1 and n0 nets driven 0
//                                      -> n1 1, n0 0
//   s = 0: reevaluated                -> n1 0, n0 1
// Each concatenation is all variables or all nets: Syntax 9-3's
// variable_lvalue and net_lvalue concatenate only their own kind.
//! inherited IEEE 1364-2005 9.3 9.3.1 9.3.2
// native-required
`timescale 1ns/1ns
module b_9_3_concatenation_targets;
  reg s, x, y;
  wire n1, n0;
  assign n1 = 1'b0;
  assign n0 = 1'b0;

  initial begin
    s = 1'b0;
    assign {x, y} = {s, ~s};
    #1 $display("%b %b", x, y);
    s = 1'b1;
    #1 $display("%b %b", x, y);
    deassign {x, y};
    force {n1, n0} = {s, ~s};
    #1 $display("%b %b", n1, n0);
    s = 1'b0;
    #1 $display("%b %b", n1, n0);
    $finish(0);
  end
endmodule
