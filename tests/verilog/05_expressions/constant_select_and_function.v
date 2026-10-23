// IEEE 1364-2005 §5, p. 41: "The operands of a constant expression consist
// of constant numbers, strings, parameters, constant bit-selects and
// part-selects of parameters, constant function calls (see 10.4.5), and
// constant system function calls only; but they can use any of the operators
// defined in Table 5-1."
//
// The two operand kinds constant_operands.v does not cover:
//   Q = P[7:4] + P[0], P = 8'hA5 = 1010_0101.
//       P[7:4] = 4'b1010 = 10, P[0] = 1'b1 = 1; both unsigned (§5.5.1).
//       Q has no range, so it takes the size of its value (§4.10.1):
//       max(4, 1) = 4 bits; 10 + 1 = 11 fits -> 11.
//   U = dbl(21), dbl returns 2*x: a constant function call (§10.4.5) -> 42.
//! inherited IEEE 1364-2005 5
module b_5_constant_select_and_function;
  parameter P = 8'hA5;
  localparam Q = P[7:4] + P[0];
  function integer dbl;
    input integer x;
    dbl = 2 * x;
  endfunction
  localparam U = dbl(21);
  initial begin
    $display("Q=%0d U=%0d", Q, U);
    $finish(0);
  end
endmodule
