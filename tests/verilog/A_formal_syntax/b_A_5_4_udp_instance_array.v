// IEEE 1364-2005 A.5.4, p. 497:
//   udp_instance ::= [ name_of_udp_instance ] ( output_terminal , input_terminal
//     { , input_terminal } )
//   name_of_udp_instance ::= udp_instance_identifier [ range ]
// §8.6, p. 113 (quoted for context): "An optional range may be specified for
// an array of UDP instances. The port connection rules remain the same as
// outlined in 7.1." (§7.1.6's bit-by-bit connection.)
//
// b_A_5_4_and3 is a combinational AND UDP; `#1 ua [1:0] (ya, {1'b1, 1'b0},
// 2'b11)` makes ua[1] (ya[1], 1, 1) and ua[0] (ya[0], 0, 1): ya = 2'b10 at
// t=5. Output: "ya=10".
//! inherited IEEE 1364-2005 A.5.4
`timescale 1ns/1ns
primitive b_A_5_4_and3 (y, a, b);
  output y;
  input a, b;
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive
module b_A_5_4_udp_instance_array;
  wire [1:0] ya;
  b_A_5_4_and3 #1 ua [1:0] (ya, {1'b1, 1'b0}, 2'b11);
  initial #5 begin
    $display("ya=%b", ya);
    $finish(0);
  end
endmodule
