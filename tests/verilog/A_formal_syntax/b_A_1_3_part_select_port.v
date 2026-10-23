// IEEE 1364-2005 A.1.3, p. 487-488:
//   port_reference ::= port_identifier [ [ constant_range_expression ] ]
// A port can be a part-select of a declared vector: `q[3:0]` is a 4-bit
// port made of the low half of the 8-bit output q. §12.3.2, p. 174 (quoted
// for context): "A part-select of a vector declared within the module".
//
// pold drives q = 8'hA5; the port is q[3:0] = 4'h5, connected to the 4-bit
// n4 -> "n4=5".
//! inherited IEEE 1364-2005 A.1.3
`timescale 1ns/1ns
module b_A_1_3_pold (q[3:0]);
  output [7:0] q;
  assign q = 8'hA5;
endmodule
module b_A_1_3_part_select_port;
  wire [3:0] n4;
  b_A_1_3_pold p (n4);
  initial #1 begin
    $display("n4=%h", n4);
    $finish(0);
  end
endmodule
