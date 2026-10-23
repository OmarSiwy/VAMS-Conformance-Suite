// IEEE 1364-2005 §14.2.3, p. 214: "The edge identifier may be one of the
// keywords posedge or negedge, associated with an input terminal descriptor,
// which may be any input port or inout port. If a vector port is specified as
// the input terminal descriptor, the edge transition shall be detected on the
// least significant bit. If the edge transition is not specified, the path
// shall be considered active on any transition at the input terminal." and
// "The data source expression is an arbitrary expression, which serves as a
// description of the flow of data to the path destination. This arbitrary
// data path description does not affect the actual propagation of data or
// events through the model".
// Its three examples (pp. 214-215):
//   ( posedge clock => ( out +: in ) ) = (10, 8);
//   ( negedge clock[0] => ( out -: in ) ) = (10, 8);
//   ( clock => ( out : in ) ) = (10, 8);
//
// The cell carries all three. They are declared on three different outputs
// (out, out_n, out_any) because each example is its own module in the clause;
// Example 2's vector clock is clockv. Each output is the flip-flop its path
// describes: out takes in on posedge clock, out_n takes ~in (the inverting
// `-:`) on negedge clockv[0], and out_any takes in on any change of clock.
// (The flop waits on a net copy of clockv[0]: VerA refuses an event control
// on a bit-select, E1100, a §9.7 gap outside this clause.)
//
// Each output change takes its path's delay when the path's edge caused it
// (§14.2.3, §14.3.3); the transcript is sampled 40 or more after the last
// edge, past the (10, 8) delays:
//   t = 1:   in = 1; clockv 2'bxx -> 2'b10: bit 0 x -> 0 is a negedge
//            (§9.7.2), so out_n <= ~1 = 0; clock x -> 0: no posedge, and
//            out_any <= 1 (any transition).
//   t = 11:  clock 0 -> 1: out <= 1, out_any <= 1.
//   t = 51:  prints out=1 out_n=0 out_any=1. Then in = 0 and clockv -> 2'b11
//            (bit 0 rises: nothing is sensitive to it).
//   t = 61:  clockv -> 2'b10: negedge on bit 0, out_n <= ~0 = 1;
//            clock 1 -> 0: no posedge, out keeps 1; out_any <= 0.
//   t = 111: prints out=1 out_n=1 out_any=0.
// in is set before the edges that sample it, so no edge races its data.
//! inherited IEEE 1364-2005 14.2.3
`timescale 1ns/1ns
module b_14_2_3_edge_sensitive_paths_cell(clock, clockv, in, out, out_n, out_any);
  input clock;
  input [1:0] clockv;
  input in;
  output out, out_n, out_any;
  reg out, out_n, out_any;
  always @(posedge clock) out <= in;
  wire clock0 = clockv[0];
  always @(negedge clock0) out_n <= ~in;
  always @(clock) out_any <= in;
  specify
    ( posedge clock => ( out +: in ) ) = (10, 8);
    ( negedge clockv[0] => ( out_n -: in ) ) = (10, 8);
    ( clock => ( out_any : in ) ) = (10, 8);
  endspecify
endmodule

module b_14_2_3_edge_sensitive_paths;
  reg clock, in;
  reg [1:0] clockv;
  wire out, out_n, out_any;
  b_14_2_3_edge_sensitive_paths_cell u(clock, clockv, in, out, out_n, out_any);
  initial begin
    #1 in = 1; clockv = 2'b10; clock = 0;
    #10 clock = 1;
    #40 $display("t=51 out=%b out_n=%b out_any=%b", out, out_n, out_any);
    in = 0; clockv = 2'b11;
    #10 clockv = 2'b10; clock = 0;
    #50 $display("t=111 out=%b out_n=%b out_any=%b", out, out_n, out_any);
  end
endmodule
