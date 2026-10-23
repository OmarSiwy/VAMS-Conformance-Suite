// IEEE 1364-2005 §4.10.3, p. 38: "A specify parameter declared outside a
// specify block shall be declared before it is referenced."
//
// The initial block reads d, a module-body specparam declared after it.
// Legal neighbour: parameter_assigned_specparam_rejected.v's tpd
// reads dhold, declared on the line before.
//! inherited IEEE 1364-2005 4.10.3
//! reject E1100
//! reject declared before it is referenced
module b_4_10_3_specparam_before_declaration_rejected;
  initial $display("%0d", d);
  specparam d = 3;
endmodule
