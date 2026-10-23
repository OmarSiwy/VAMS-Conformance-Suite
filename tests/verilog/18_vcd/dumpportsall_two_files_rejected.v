// IEEE 1364-2005 §18.3.3, p. 340, Syntax 18-23:
//   dumpportsall_task ::= $dumpportsall ( file_pathname ) ;
// One file_pathname or (§18.3.7) none; two is no dumpportsall_task. Legal
// neighbour: `$dumpportsall("b_18_3_2_control.evcd")` in
// dumpports_control_tasks.v.
//! inherited IEEE 1364-2005 18.3.3
//! reject E1100
//! reject argument
//! neighbour dumpports_control_tasks.v
`timescale 1ns/1ns
module b_18_3_3_dumpportsall_two_files_rejected_dev(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule

module b_18_3_3_dumpportsall_two_files_rejected;
  reg a;
  wire y, w;
  b_18_3_3_dumpportsall_two_files_rejected_dev u(a, y);
  b_18_3_3_dumpportsall_two_files_rejected_dev v(a, w);
  initial begin
    a = 1'b0;
    $dumpports(u, "b_18_3_3_a.evcd");
    $dumpports(v, "b_18_3_3_b.evcd");
    #1 $dumpportsall("b_18_3_3_a.evcd", "b_18_3_3_b.evcd");
    #1 a = 1'b1;
  end
endmodule
