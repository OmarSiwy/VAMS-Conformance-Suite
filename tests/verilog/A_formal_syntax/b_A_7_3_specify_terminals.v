// IEEE 1364-2005 A.7.3, p. 500:
//   specify_input_terminal_descriptor ::= input_identifier [ [ constant_range_expression ] ]
//   specify_output_terminal_descriptor ::= output_identifier [ [ constant_range_expression ] ]
//   input_identifier ::= input_port_identifier | inout_port_identifier
//   output_identifier ::= output_port_identifier | inout_port_identifier
//
// Terminal descriptors of every kind in b_A_7_3_cell's paths: a whole input
// port, a bit-select (a[1]), a part-select (a[3:2]), the output's bit and
// part (y[0], y[3:2]), and the inout port io as a path input and as a path
// output. Each destination's time-0 change takes its paths' delay (§14.3.3),
// at most 5, so by t=10 the cell shows its assignments: a = 4'b1010 ->
// y = ~a = 4'b0101; io is driven by the top: 1.
// Output: "y=0101 io=1".
//! inherited IEEE 1364-2005 A.7.3
`timescale 1ns/1ns
module b_A_7_3_cell (a, y, io);
  input [3:0] a;
  output [3:0] y;
  inout io;
  assign y = ~a;
  specify
    (a *> y) = 1;
    (a[1] => y[0]) = 2;
    (a[3:2] *> y[3:2]) = 3;
    (io => y[1]) = 4;
    (a[0] => io) = 5;
  endspecify
endmodule
module b_A_7_3_specify_terminals;
  wire [3:0] y;
  wire io = 1'b1;
  b_A_7_3_cell c (4'b1010, y, io);
  initial #10 begin
    $display("y=%b io=%b", y, io);
    $finish(0);
  end
endmodule
