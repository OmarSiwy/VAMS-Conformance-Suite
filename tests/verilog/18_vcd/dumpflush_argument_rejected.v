// IEEE 1364-2005 §18.1.6, p. 328, Syntax 18-7:
//   dumpflush_task ::= $dumpflush ;
// The one dump file is flushed; the task takes no argument, so
// `$dumpflush(a)` is no dumpflush_task. Legal neighbour: the bare $dumpflush
// of version_names_dumpfile_literal.v.
//! inherited IEEE 1364-2005 18.1.6
//! reject E1100
//! reject $dumpoff, $dumpon, $dumpall and $dumpflush take no arguments
//! neighbour version_names_dumpfile_literal.v
`timescale 1ns/1ns
module b_18_1_6_dumpflush_argument_rejected;
  reg a;
  reg [7:0] v;
  initial begin
    $dumpvars(0, b_18_1_6_dumpflush_argument_rejected);
    $dumpflush(a);
    a = 1'b0;
    v = 8'h00;
    #1 a = 1'b1;
  end
endmodule
