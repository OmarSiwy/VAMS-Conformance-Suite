// IEEE 1364-2005 §12.4, p. 181: "They are evaluated at elaboration time, and
// the result is determined before simulation begins. Therefore, all
// expressions in generate schemes shall be constant expressions, deterministic
// at elaboration time."
//
// The if-generate condition is the reg c. Legal neighbour:
// direct_nesting_and_recursion.v (conditions on parameters).
//! lrm 6.6
//! lrm 6.6:2
//! inherited IEEE 1364-2005 12.4
//! reject E1100
//! reject a constant expression is required here
//! neighbour direct_nesting_and_recursion.v
module b_12_4_nonconstant_generate_scheme_rejected;
  reg c;
  if (c) begin : g
    initial $display("x");
  end
endmodule
