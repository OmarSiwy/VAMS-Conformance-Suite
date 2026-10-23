// IEEE 1364-2005 §18.1.3, p. 327, Syntax 18-4:
//   dumpoff_task ::= $dumpoff ;
//   dumpon_task ::= $dumpon ;
// Neither task takes an argument; `$dumpoff(a)` is neither production.
// Legal neighbour: the bare $dumpoff and $dumpon of
// example_value_changes.v.
//! inherited IEEE 1364-2005 18.1.3
//! reject E1100
//! reject $dumpoff, $dumpon, $dumpall and $dumpflush take no arguments
//! neighbour example_value_changes.v
`timescale 1ns/1ns
module b_18_1_3_dumpoff_argument_rejected;
  reg a;
  reg [7:0] v;
  initial begin
    $dumpvars(0, b_18_1_3_dumpoff_argument_rejected);
    $dumpoff(a);
    a = 1'b0;
    v = 8'h00;
    #1 a = 1'b1;
  end
endmodule
