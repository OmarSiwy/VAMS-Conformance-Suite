// IEEE 1364-2005 §10.4.5 allows constant function calls in constant
// expressions and requires that calls have no effect on the initial values
// of the variables used. A.2.8 permits local parameter declarations in the
// function; §4.10: "Parameters are not variables; they are constants."
//
// HAND DERIVATION. step = 2 + 1 = 3; add(4) = 7 and add(5) = 8, whether
// called during elaboration (A and B) or later during simulation. The
// constant values must survive each fresh elaboration-time activation.
// The function's parameters precede the calls, as §10.4.5 requires.
// Rejection neighbour: subroutine_parameter_assignment_rejected.v.
//! inherited IEEE 1364-2005 4.10 10.4.5 A.2.8
module b_10_constant_function_parameters;
  function integer add(input integer n);
    parameter offset = 2;
    localparam step = offset + 1;
    add = n + step;
  endfunction
  parameter A = add(4), B = add(5);
  initial $display("A=%0d B=%0d runtime=%0d", A, B, add(4));
endmodule
