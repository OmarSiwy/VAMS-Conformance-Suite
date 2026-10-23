// IEEE 1364-2005 §10.4.5, p. 156: "Constant function calls are used to support
// the building of complex calculations of values at elaboration time" and "A
// constant function call shall be a function invocation of a constant
// function local to the calling module where the arguments to the function
// are constant expressions." §12.4.2, p. 186: "The conditional generate
// constructs, if-generate and case-generate, select at most one generate
// block from a set of alternative generate blocks based on constant
// expressions evaluated during elaboration."
//
// sq is a constant function of this module (it reads only its own input), so
// `sq(3) == 9` is a constant expression the conditional generate can test.
// The call runs during elaboration, before any process: the function exists
// but no statement of the design has run yet. sq(3) = 3 * 3 = 9, so the `yes`
// branch is generated and the `no` branch is not.
// Output: "sq(3) = 9: yes".
//! inherited IEEE 1364-2005 10.4.5
`timescale 1ns/1ns
module b_10_4_5_constant_function_generate_condition;
  function integer sq;
    input integer x;
    sq = x * x;
  endfunction
  generate
    if (sq(3) == 9) begin : yes
      initial $display("sq(3) = 9: yes");
    end else begin : no
      initial $display("sq(3) != 9: no");
    end
  endgenerate
endmodule
