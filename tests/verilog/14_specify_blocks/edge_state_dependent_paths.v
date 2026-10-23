// IEEE 1364-2005 §14.2.4.3, p. 217: "If the path description of a
// state-dependent path describes an edge-sensitive path, then the
// state-dependent path is called an edge-sensitive state-dependent path." ...
// "Different delays can be assigned to the same edge-sensitive path as long as
// the following criteria are met: — The edge, condition, or both make each
// declaration unique. — The port is referenced in the same way in all path
// declarations (entire port, bit-select, or part-select)."
// Its Examples 1 to 3 (p. 217), each in a cell of its own:
//   Example 1: if ( !reset && !clear )
//                  ( posedge clock => ( out +: in ) ) = (10, 8) ;
//   Example 2 (a unique edge each):
//     ( posedge clk => ( q[0] : data ) ) = (10, 5);
//     ( negedge clk => ( q[0] : data ) ) = (20, 12);
//   Example 3 (a unique condition each):
//     if (reset)
//          ( posedge clk => ( q[0] : data ) ) = (15, 8);
//     if (!reset && cntrl)
//          ( posedge clk => ( q[0] : data ) ) = (6, 2);
// Every declaration in Examples 2 and 3 names q[0] the same way, a bit-select.
//
// The cells' logic: e1 takes in on posedge clock; e2's q[0] takes data on
// either edge of clk; e3's q[0] takes data on posedge clk. The q[1] bits are
// driven by the same processes (e2: ~data, e3: reset) so each vector has one
// driver.
//
// Each output change takes the delay its edge and conditions select
// (§14.3.3); the transcript is sampled 40 or more after each edge, past the
// longest delay (20):
//   t = 1:   reset = 0, clear = 0, cntrl = 1, in = 1, data = 1, both clocks
//            x -> 0 (a negedge: e2 takes q = {~1, 1} = 01).
//   t = 11:  clock and clk rise: e1 out <= 1; e2 q <= 01; e3 q <= {0, 1} = 01.
//   t = 51:  prints out=1 q2=01 q3=01. Then in = 0, data = 0, reset = 1.
//   t = 61:  clock and clk fall: e1 keeps out = 1 (not a posedge);
//            e2 q <= {~0, 0} = 10; e3 keeps 01.
//   t = 101: prints out=1 q2=10 q3=01.
//   t = 111: clock and clk rise: e1 out <= 0; e2 q <= 10; e3 q <= {1, 0} = 10.
//   t = 151: prints out=0 q2=10 q3=10.
// Data is set before the edges that sample it, so no edge races its data.
//! inherited IEEE 1364-2005 14.2.4.3
`timescale 1ns/1ns
module b_14_2_4_3_edge_state_dependent_paths_e1(clock, reset, clear, in, out);
  input clock, reset, clear, in;
  output out;
  reg out;
  always @(posedge clock) out <= in;
  specify
    if ( !reset && !clear )
      ( posedge clock => ( out +: in ) ) = (10, 8) ;
  endspecify
endmodule

module b_14_2_4_3_edge_state_dependent_paths_e2(clk, data, q);
  input clk, data;
  output [1:0] q;
  reg [1:0] q;
  always @(clk) q <= {~data, data};
  specify
    ( posedge clk => ( q[0] : data ) ) = (10, 5);
    ( negedge clk => ( q[0] : data ) ) = (20, 12);
  endspecify
endmodule

module b_14_2_4_3_edge_state_dependent_paths_e3(clk, data, reset, cntrl, q);
  input clk, data, reset, cntrl;
  output [1:0] q;
  reg [1:0] q;
  always @(posedge clk) q <= {reset, data};
  specify
    if (reset)
      ( posedge clk => ( q[0] : data ) ) = (15, 8);
    if (!reset && cntrl)
      ( posedge clk => ( q[0] : data ) ) = (6, 2);
  endspecify
endmodule

module b_14_2_4_3_edge_state_dependent_paths;
  reg clock, clk, reset, clear, cntrl, in, data;
  wire out;
  wire [1:0] q2, q3;
  b_14_2_4_3_edge_state_dependent_paths_e1 u1(clock, reset, clear, in, out);
  b_14_2_4_3_edge_state_dependent_paths_e2 u2(clk, data, q2);
  b_14_2_4_3_edge_state_dependent_paths_e3 u3(clk, data, reset, cntrl, q3);
  initial begin
    #1 reset = 0; clear = 0; cntrl = 1; in = 1; data = 1; clock = 0; clk = 0;
    #10 clock = 1; clk = 1;
    #40 $display("t=51 out=%b q2=%b q3=%b", out, q2, q3);
    in = 0; data = 0; reset = 1;
    #10 clock = 0; clk = 0;
    #40 $display("t=101 out=%b q2=%b q3=%b", out, q2, q3);
    #10 clock = 1; clk = 1;
    #40 $display("t=151 out=%b q2=%b q3=%b", out, q2, q3);
  end
endmodule
