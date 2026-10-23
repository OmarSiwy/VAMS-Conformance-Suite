// IEEE 1364-2005 A.2.1.2, p. 489:
//   inout_declaration ::= inout [ net_type ] [ signed ] [ range ] list_of_port_identifiers
//   input_declaration ::= input [ net_type ] [ signed ] [ range ] list_of_port_identifiers
//   output_declaration ::= output [ net_type ] [ signed ] [ range ] list_of_port_identifiers
//     | output reg [ signed ] [ range ] list_of_variable_port_identifiers
//     | output output_variable_type list_of_variable_port_identifiers
// A.2.3, p. 491: list_of_variable_port_identifiers ::=
//   port_identifier [ = constant_expression ] { , port_identifier [ = constant_expression ] }
//
// b_A_2_1_2_dut declares, in its body: an inout (no net_type), an input with
// net_type, signed and range, a plain input, an output wire with range, an
// output reg signed with range and an initializer, and two output
// output_variable_types (integer, time). Its behaviour:
//   io is driven by nothing inside and by the top's 1'b1 -> io = 1.
//   s = -3 (tri signed [3:0], 4'b1101); sum = s + 4'sd1 = 4'b1110 (the unsigned 4'd0 arm makes the ?: unsigned; the bits are those of -2).
//   q starts at 4'sd5 and is never assigned -> 5.
//   oi = 32'd70000, ot = 64'd12 (assigned at t=0).
// The top prints at t=1: "io=1 sum=1110 q=5 oi=70000 ot=12".
//! inherited IEEE 1364-2005 A.2.1.2
`timescale 1ns/1ns
module b_A_2_1_2_dut (io, s, en, sum, q, oi, ot);
  inout io;
  input tri signed [3:0] s;
  input en;
  output wire [3:0] sum;
  output reg signed [3:0] q = 4'sd5;
  output integer oi;
  output time ot;
  assign sum = en ? s + 4'sd1 : 4'd0;
  initial begin
    oi = 70000;
    ot = 12;
  end
endmodule
module b_A_2_1_2_port_declarations;
  wire io = 1'b1;
  wire [3:0] sum, q;
  wire [31:0] oi;
  wire [63:0] ot;
  b_A_2_1_2_dut d (io, 4'b1101, 1'b1, sum, q, oi, ot);
  initial #1 begin
    $display("io=%b sum=%b q=%0d oi=%0d ot=%0d", io, sum, q, oi, ot);
    $finish(0);
  end
endmodule
