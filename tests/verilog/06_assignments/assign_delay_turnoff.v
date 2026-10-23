// Verilog-AMS LRM 2.4 annex A.2.2.3 gives the third slot of `delay3`:
//   "delay3 ::= # delay_value
//             | # ( mintypmax_expression [ , mintypmax_expression
//                 [ , mintypmax_expression ] ] )"
// and annex A.6.1 attaches it to a continuous assignment:
//   "continuous_assign ::= assign [ drive_strength ] [ delay3 ]
//    list_of_net_assignments ;"
// The three-expression form is rise / fall / TURN-OFF (6.1.3 of IEEE Std 1364
// Verilog): the third value is the delay of a transition to the high-impedance
// value z. A turn-off delay is therefore only reachable from an expression
// that can PRODUCE z, which is why the source here is `en ? d : 1'bz`.
//
// §8.5.3.1: the continuous assignment is "sensitive to the source elements in
// the expression" — `en` and `d` both are — and a change "causes an active
// update event to be added to the event queue". Which of the three delays
// times that event is decided by the value being driven.
//
//! lrm annex A.2.2.3
//! lrm annex A.6.1
//! lrm 8.5.3.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.3 7.14
//
// Hand derivation for `assign #(2, 4, 6) y = en ? d : 1'bz;`
// (rise = 2, fall = 4, turn-off = 6):
//   t=0   en := 1, d := 0.  Longest delay is 6, so by t=10 y has settled -> 0
//   t=20  d := 1  -> destination 1 -> RISE     -> delivery 20 + 2 = 22
//         t=21 -> y = 0   t=22 -> y = 1
//   t=30  en := 0 -> destination z -> TURN-OFF -> delivery 30 + 6 = 36
//         t=35 -> y = 1   t=36 -> y = z
//   t=40  d := 0, en := 1 (same instant) -> destination 0 -> FALL
//                                        -> delivery 40 + 4 = 44
//         t=43 -> y = z   t=44 -> y = 0
// The turn-off delay is the load-bearing number: if the implementation reused
// the fall delay for the transition to z, t=35 would already read z and t=36
// would be indistinguishable from a 4 ns fall.

`timescale 1ns/1ns
module assign_delay_turnoff;
  reg en, d;
  wire y;

  assign #(2, 4, 6) y = en ? d : 1'bz;

  initial begin
    en = 1'b1; d = 1'b0;
    #10 #0 $display("t10 y=%b", y);
    #10 d = 1'b1;
    #1 #0 $display("t21 y=%b", y);
    #1 #0 $display("t22 y=%b", y);
    #8 en = 1'b0;
    #5 #0 $display("t35 y=%b", y);
    #1 #0 $display("t36 y=%b", y);
    #4 d = 1'b0; en = 1'b1;
    #3 #0 $display("t43 y=%b", y);
    #1 #0 $display("t44 y=%b", y);
    $finish(0);
  end
endmodule
