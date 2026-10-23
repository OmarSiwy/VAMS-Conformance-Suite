// IEEE 1364-2005 §5.4, p. 62: "The Verilog HDL uses the bit length of the
// operands to determine how many bits to use while evaluating an expression.
// The bit length rules are given in 5.4.1. In the case of the addition
// operator, the bit length of the largest operand, including the left-hand
// side of an assignment, shall be used."
//
// The clause's example (which gives no values), run with a = 16'hFFFF,
// b = 16'h0001:
//   sumA = a + b, sumA 16 bits: evaluated in 16 bits, 65536 mod 2**16 = 0
//     -> 0000000000000000
//   sumB = a + b, sumB 17 bits: evaluated in 17 bits, keeps the carry
//     -> 10000000000000000
//! inherited IEEE 1364-2005 5.4
module b_5_4_sum_width_from_lhs;
  reg [15:0] a, b;
  reg [15:0] sumA;
  reg [16:0] sumB;
  initial begin
    a = 16'hFFFF;
    b = 16'h0001;
    sumA = a + b;
    sumB = a + b;
    $display("%b %b", sumA, sumB);
    $finish(0);
  end
endmodule
