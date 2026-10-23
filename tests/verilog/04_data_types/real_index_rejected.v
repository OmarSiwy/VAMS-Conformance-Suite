// IEEE 1364-2005 §4.8.1, p. 33: "Real number constants and real variables
// are also prohibited in the following cases:" ... "— Real number index
// expressions of bit-select or part-select references of vectors"
//
// v[1.0] indexes a vector with a real constant. Legal neighbour: the
// integral index vect[addr] (addr is reg [3:0]) in
// ../05_expressions/bit_part_select_addressing.v.
//! inherited IEEE 1364-2005 4.8.1
//! reject E1100
//! reject real
//! neighbour ../05_expressions/bit_part_select_addressing.v
module b_4_8_1_real_index_rejected;
  reg [3:0] v;
  initial begin
    v = 4'b0101;
    $display("%b", v[1.0]);
  end
endmodule
