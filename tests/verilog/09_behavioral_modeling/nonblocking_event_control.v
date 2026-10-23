// IEEE 1364-2005 §9.7.7, p. 137: "The intra-assignment delay and event control
// can be applied to both blocking assignments and nonblocking assignments."
// p. 136: "An intra-assignment delay or event control shall delay the
// assignment of the new value to the left-hand side, but the right-hand
// expression shall be evaluated before the delay". §9.2.2, p. 119: "The
// nonblocking procedural assignment allows assignment scheduling without
// blocking the procedural flow."
//
// clk is 0 at t=0 and toggles every 1 ns: posedges at t = 1, 3, 5.
//   t=0  d = 4; q <= @(posedge clk) d: d is read now (4) and the process
//        does not wait: d = 9 and the display run at t=0, q still x -> "0 x 9"
//   t=1  the posedge: q takes the parked 4, not d's 9 -> at t=2 "2 4 9"
//   t=2  d = 6; p <= @(posedge clk) d parks 6; d = 1; the posedge at t=3
//        writes 6 -> at t=4 "4 6"
//! inherited IEEE 1364-2005 9.7.7 9.2.2
`timescale 1ns/1ns
module b_9_7_7_nonblocking_event_control;
  reg clk;
  integer d, q, p;
  always #1 clk = ~clk;
  initial begin
    clk = 1'b0;
    d = 4;
    q <= @(posedge clk) d;
    d = 9;
    $display("%0t %0d %0d", $time, q, d);
    #2 $display("%0t %0d %0d", $time, q, d);
    d = 6;
    p <= @(posedge clk) d;
    d = 1;
    #2 $display("%0t %0d", $time, p);
    $finish(0);
  end
endmodule
