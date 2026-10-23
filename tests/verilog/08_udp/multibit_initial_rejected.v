// IEEE 1364-2005 §8.1.3, p. 107: "The statement that follows shall be an
// assignment statement that assigns a single-bit literal value to the output
// port."
// Table 8-2, p. 111: "The procedural assignment statement shall assign one
// of the following values: 1'b1, 1'b0, 1'bx, 1, 0"
//
// q is initialized with 2'b01, a two-bit literal. Legal neighbour:
// initial_values.v, every init_val of Syntax 8-1.
//! inherited IEEE 1364-2005 8.1.3
//! reject E1100
//! reject single-bit literal
//! neighbour initial_values.v
`timescale 1ns/1ns
primitive wide_init(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 2'b01;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module b_8_1_3_multibit_initial_rejected;
  reg g, d;
  wire q;
  wide_init u(q, g, d);
  initial begin
    #1 $display("%b", q);
    $finish(0);
  end
endmodule
