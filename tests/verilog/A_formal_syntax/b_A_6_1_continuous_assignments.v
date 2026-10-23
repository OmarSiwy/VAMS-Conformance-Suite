// IEEE 1364-2005 A.6.1, p. 497:
//   continuous_assign ::= assign [ drive_strength ] [ delay3 ] list_of_net_assignments ;
//   list_of_net_assignments ::= net_assignment { , net_assignment }
//   net_assignment ::= net_lvalue = expression
//
// assign with neither option: w = a + b = 3 + 4 = 7 (4 bits).
// assign (pull0, pull1) #2 with two net_assignments: p = a[0] = 1 and
//   q = 0; q also has an assign (weak0, weak1) q = 1, which the pull0
//   overrides (§7.10.1): q = 0.
// assign #(1, 2, 3) s = a + b + 4'd9: a delay3 of three values:
//   3 + 4 + 9 = 16, truncated to 4 bits: s = 0.
// (A concatenated net_lvalue is b_A_8_5_concatenated_lvalues.v.)
// Read at t=5 after every delay: "w=7 p=1 q=0 s=0".
//! inherited IEEE 1364-2005 A.6.1
`timescale 1ns/1ns
module b_A_6_1_continuous_assignments;
  reg [3:0] a, b;
  wire [3:0] w, s;
  wire p, q;
  assign w = a + b;
  assign (pull0, pull1) #2 p = a[0], q = 1'b0;
  assign (weak0, weak1) q = 1'b1;
  assign #(1, 2, 3) s = a + b + 4'd9;
  initial begin
    a = 4'd3;
    b = 4'd4;
    #5 $display("w=%0d p=%b q=%b s=%0d", w, p, q, s);
    $finish(0);
  end
endmodule
