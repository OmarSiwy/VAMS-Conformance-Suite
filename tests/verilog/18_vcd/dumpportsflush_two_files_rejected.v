// IEEE 1364-2005 §18.3.5, p. 341, Syntax 18-25:
//   dumpportsflush_task ::= $dumpportsflush ( file_pathname ) ;
// One file_pathname or (§18.3.7) none; two is no dumpportsflush_task. Legal
// neighbours: `$dumpportsflush("...")` in dumpports_node_information.v
// and the bare `$dumpportsflush;` in dumpports_control_tasks.v.
//! inherited IEEE 1364-2005 18.3.5
//! reject E1100
//! reject argument
//! neighbour dumpports_control_tasks.v
//! neighbour dumpports_node_information.v
`timescale 1ns/1ns
module b_18_3_5_dumpportsflush_two_files_rejected_dev(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule

module b_18_3_5_dumpportsflush_two_files_rejected;
  reg a;
  wire y, w;
  b_18_3_5_dumpportsflush_two_files_rejected_dev u(a, y);
  b_18_3_5_dumpportsflush_two_files_rejected_dev v(a, w);
  initial begin
    a = 1'b0;
    $dumpports(u, "b_18_3_5_a.evcd");
    $dumpports(v, "b_18_3_5_b.evcd");
    #1 $dumpportsflush("b_18_3_5_a.evcd", "b_18_3_5_b.evcd");
    #1 a = 1'b1;
  end
endmodule
