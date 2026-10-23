// IEEE 1364-2005 A.2.1.3: net_declaration ::= ... | net_type [ signed ]
// range [ delay3 ] list_of_net_decl_assignments ; and A.2.2.3: delay3 ::=
// # delay_value | ..., delay_value ::= unsigned_number | real_number |
// identifier. So `wire [7:0] #3 dw = a;` is the range, then a one-number
// delay, then the assignment. Legal neighbour of
// b_A_2_1_3_delay_before_range_rejected.v (#63).
// a = 5 at t=0 and 9 at t=10; every transition waits 3 (one value is all
// three delays, §7.14), so dw is 5 from t=3 and 9 from t=13:
//   t=12: dw = 5 (the change to 9 is still in flight)
//   t=14: dw = 9
//! inherited IEEE 1364-2005 A.2.1.3 A.2.2.3
`timescale 1ns/1ns
module b_A_2_1_3_range_then_delay;
  reg [7:0] a;
  wire [7:0] #3 dw = a;
  initial begin
    a = 8'd5;
    #10 a = 8'd9;
    #2 $display("t12 %0d", dw);
    #2 $display("t14 %0d", dw);
    $finish(0);
  end
endmodule
