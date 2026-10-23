// IEEE 1364-2005 §9.3.2, p. 124: "The left-hand side of the assignment can be a
// variable, a net, a constant bit-select of a vector net, a part-select of a
// vector net, or a concatenation. It cannot be a memory word (array reference)
// or a bit-select or a part-select of a vector variable."
// (§9.3, p. 122: "Bit-selects and part-selects of vector variables are not
// allowed.")
//
// force r[1] = ... takes a bit-select of the vector variable r. Legal
// neighbours: force_net_selects.v forces a bit-select and a
// part-select of a vector NET; assignment_force_release.v forces a
// whole variable. (VerA's refusal also covers those legal net selects; that
// over-refusal is pinned by the xfail force_net_selects.v.)
//! inherited IEEE 1364-2005 9.3 9.3.2
//! reject E1100
//! reject names one whole variable or net
//! neighbour assignment_force_release.v
//! neighbour force_net_selects.v
module b_9_3_2_force_variable_bit_select_rejected;
  reg [3:0] r;
  initial force r[1] = 1'b1;
endmodule
