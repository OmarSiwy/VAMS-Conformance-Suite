// IEEE 1364-2005 §5, p. 41: "The operands of a constant expression consist
// of constant numbers, strings, parameters, constant bit-selects and
// part-selects of parameters, constant function calls (see 10.4.5), and
// constant system function calls only; but they can use any of the operators
// defined in Table 5-1." ... "Specifically, the system functions allowed in
// constant expressions are the conversion system functions listed in 17.8 and
// the mathematical system functions listed in 17.11."
//
// Each localparam below is a constant expression built from one operand kind
// the sentence permits. (Parameter selects and constant function calls are
// constant_select_and_function.v.)
//   N = 3 ** 2 + (7 % 4) - (1 << 2): numbers and operators.
//       3**2 = 9; 7%4 = 3; 1<<2 = 4; 9 + 3 - 4 = 8.
//   S = "hi" in [15:0]: a string, "h" = 8'h68, "i" = 8'h69 -> 16'h6869.
//   P = B + 1 where B = 41: a previously defined parameter -> 42.
//   C = $clog2(9): §17.11.1 ceiling of log2; 2**3 = 8 < 9 <= 16 = 2**4 -> 4.
//   R = $rtoi(2.7): §17.8 converts by truncation -> 2.
//! inherited IEEE 1364-2005 5
module b_5_constant_operands;
  parameter B = 41;
  localparam N = 3 ** 2 + (7 % 4) - (1 << 2);
  localparam [15:0] S = "hi";
  localparam P = B + 1;
  localparam C = $clog2(9);
  localparam R = $rtoi(2.7);
  initial begin
    $display("N=%0d S=%h P=%0d C=%0d R=%0d", N, S, P, C, R);
    $finish(0);
  end
endmodule
