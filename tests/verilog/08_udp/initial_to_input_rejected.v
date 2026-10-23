// IEEE 1364-2005 §8.1.3, p. 107: "The statement that follows shall be an
// assignment statement that assigns a single-bit literal value to the output
// port."
// Table 8-2, p. 111: "The procedural assignment statement shall assign a
// value to a reg whose identifier matches the identifier of an output
// terminal"
//
// The initial statement assigns input g, not output q. Legal neighbour:
// initial_values.v, which assigns q.
//! inherited IEEE 1364-2005 8.1.3 8.5
//! reject E1100
//! reject output
//! neighbour initial_values.v
`timescale 1ns/1ns
primitive input_init(q, g, d);
  output q;
  reg q;
  input g, d;
  initial g = 1;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module b_8_1_3_initial_to_input_rejected;
  reg g, d;
  wire q;
  input_init u(q, g, d);
  initial begin
    #1 $display("%b", q);
    $finish(0);
  end
endmodule
