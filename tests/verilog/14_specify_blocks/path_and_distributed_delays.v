// IEEE 1364-2005 §14.4: "If a module contains module path delays and
// distributed delays (delays on primitive instances within the module), the
// larger of the two delays for each path shall be used."
// Example 1, Figure 14-3: "the delay on the module path from input D to output
// Q is 22, while the sum of the distributed delays is 0 + 1 = 1. Therefore, a
// transition on Q caused by a transition on D will occur 22 time units after
// the transition on D."
// Example 2, Figure 14-4: "the delay on the module path from D to Q is 22, but
// the distributed delays along that module path now add up to 10 + 20 = 30.
// Therefore, an event on Q caused by an event on D will occur 30 time units
// after the event on D."
// Each figure's D-to-Q chain as two bufs with the figure's delays (the gates
// for A, B and C are not on the D path the figures discuss):
//   t = 1:   D = 0: Q3 = 0 at 1 + 22 = 23, Q4 = 0 at 1 + 30 = 31
//   t = 100: D = 1: Q3 = 1 at 122, Q4 = 1 at 130
//! inherited IEEE 1364-2005 14.4
`timescale 1ns/1ns
module b_14_4_path_and_distributed_delays_fig3(D, Q);
  input D;
  output Q;
  wire n;
  buf #0 g1(n, D);
  buf #1 g2(Q, n);
  specify
    (D => Q) = 22;
  endspecify
endmodule

module b_14_4_path_and_distributed_delays_fig4(D, Q);
  input D;
  output Q;
  wire n;
  buf #10 g1(n, D);
  buf #20 g2(Q, n);
  specify
    (D => Q) = 22;
  endspecify
endmodule

module b_14_4_path_and_distributed_delays;
  reg d;
  wire q3, q4;
  b_14_4_path_and_distributed_delays_fig3 u3(d, q3);
  b_14_4_path_and_distributed_delays_fig4 u4(d, q4);
  always @(q3) $display("%0t Q3=%b", $time, q3);
  always @(q4) $display("%0t Q4=%b", $time, q4);
  initial begin
    #1 d = 0;
    #99 d = 1;
  end
endmodule
