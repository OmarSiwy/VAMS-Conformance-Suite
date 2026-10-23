// IEEE 1364-2005 §8.1.1, p. 107: "The output port shall be the first port in
// the port list."
//
// last_out lists input a first and output q second. Legal neighbour:
// definition_placement.v, the same inverter with q first.
//! inherited IEEE 1364-2005 8.1.1
//! reject E1100
//! reject output port shall be the first
//! neighbour definition_placement.v
primitive last_out(a, q);
  input a;
  output q;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_1_1_output_not_first_rejected;
  reg c;
  wire y;
  last_out u(y, c);
  initial begin
    c = 0;
    #1 $display("%b", y);
    $finish(0);
  end
endmodule
