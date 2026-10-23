// Verilog-AMS LRM 2.4 annex A.2.1.3:
//   "net_declaration ::= ...
//      | net_type [ discipline_identifier ] [ drive_strength ] [ signed ]
//            [ delay3 ] list_of_net_decl_assignments ;"
// annex A.2.4:
//   "net_decl_assignment ::= ams_net_identifier = expression"
//
// A net declaration assignment is a continuous assignment written on the
// declaration (6.1.1 of IEEE Std 1364 Verilog): it places exactly ONE driver
// on the net, and §8.5.3.1 governs it like any other — "a process, sensitive
// to the source elements in the expression ... causes an active update event
// to be added to the event queue". The `delay3` permitted by the production
// above times that update event.
//
// IEEE 1364-2005 §6.1.3 makes this delay an assignment delay, not a net delay:
// `wire y; assign #3 y = ~a;` is the corresponding separate spelling, whereas
// `wire #3 y; assign y = ~a;` also delays other drivers. Additional separate
// drivers are not forbidden; this fixture exercises only one driver.
//
//! lrm annex A.2.1.3
//! lrm annex A.2.4
//! lrm 8.5.3.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.1 6.1.3
//
// Hand derivation for `wire #3 y = ~a;`:
//   t=0   a := 0  -> expression ~a = 1 -> update queued for 0 + 3 = 3
//   t=6   settled                                        -> y = 1
//   t=10  a := 1  -> expression ~a = 0 -> update for 13
//         t=12 -> y = 1    t=13 -> y = 0
//   t=20  a := 0  -> expression ~a = 1 -> update for 23
//         t=22 -> y = 0    t=23 -> y = 1
// Each pair brackets the delivery to one time unit, so the asserted numbers
// pin the delay to exactly 3 and not merely "nonzero".

`timescale 1ns/1ns
module net_decl_assign_delay;
  reg a;
  wire #3 y = ~a;

  initial begin
    a = 1'b0;
    #6 #0 $display("t6 y=%b", y);
    #4 a = 1'b1;
    #2 #0 $display("t12 y=%b", y);
    #1 #0 $display("t13 y=%b", y);
    #7 a = 1'b0;
    #2 #0 $display("t22 y=%b", y);
    #1 #0 $display("t23 y=%b", y);
    $finish(0);
  end
endmodule
