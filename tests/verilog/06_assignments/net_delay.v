// Verilog-AMS LRM 2.4 annex A.2.1.3:
//   "net_declaration ::=
//        net_type [ discipline_identifier ] [ signed ]
//            [ delay3 ] list_of_net_identifiers ;
//      | ..."
// A `delay3` therefore belongs to the NET, independently of whatever drives
// it. This is the net delay of 7.14 of IEEE Std 1364 Verilog: it delays the
// change of the net's resolved value, and it takes the same rise/fall
// interpretation as annex A.2.2.3 gives `delay3` everywhere else.
//
// The distinction being pinned is that a net delay is NOT the same object as a
// continuous-assignment delay: here both `assign` statements are undelayed
// (§8.5.3.1's active update event is queued for the current time) and every
// observed lag comes from the declaration of the net.
//
//! lrm annex A.2.1.3
//! lrm annex A.2.2.3
//! lrm 8.5.3.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.3 7.14
//
// Hand derivation.  `wire #4 y;` -> 4 ns for every direction.
//                   `wire #(2, 6) z;` -> rise 2, fall 6.
//   t=0   a := 0.  Longest delay is 6, so by t=10 both have settled -> 0, 0
//   t=20  a := 1
//         y: destination 1, single delay 4 -> delivery 24
//         z: destination 1, RISE 2         -> delivery 22
//         t=21 -> y=0 z=0
//         t=22 -> y=0 z=1   (z arrived, y has not)
//         t=23 -> y=0 z=1   (brackets y's delivery to exactly 24)
//         t=24 -> y=1 z=1
//   t=30  a := 0
//         y: destination 0, single delay 4 -> delivery 34
//         z: destination 0, FALL 6         -> delivery 36
//         t=34 -> y=0 z=1
//         t=35 -> y=0 z=1   (brackets z's delivery to exactly 36)
//         t=36 -> y=0 z=0
// The asymmetry of z between the rising edge (2 ns, EARLIER than y) and the
// falling edge (6 ns, LATER than y) is the load-bearing observation: a single
// averaged net delay cannot produce both orderings.

`timescale 1ns/1ns
module net_delay;
  reg a;
  wire #4 y;
  wire #(2, 6) z;

  assign y = a;
  assign z = a;

  initial begin
    a = 1'b0;
    #10 #0 $display("t10 y=%b z=%b", y, z);
    #10 a = 1'b1;
    #1 #0 $display("t21 y=%b z=%b", y, z);
    #1 #0 $display("t22 y=%b z=%b", y, z);
    #1 #0 $display("t23 y=%b z=%b", y, z);
    #1 #0 $display("t24 y=%b z=%b", y, z);
    #6 a = 1'b0;
    #4 #0 $display("t34 y=%b z=%b", y, z);
    #1 #0 $display("t35 y=%b z=%b", y, z);
    #1 #0 $display("t36 y=%b z=%b", y, z);
    $finish(0);
  end
endmodule
