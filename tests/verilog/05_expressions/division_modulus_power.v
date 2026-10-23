// IEEE 1364-2005 §5.1.5, pp. 45-47: "The integer division shall truncate any
// fractional part toward zero. For the division or modulus operators, if the
// second operand is a zero, then the entire result value shall be x." ...
// "The result of a modulus operation shall take the sign of the first
// operand." ... "If either operand of the power operator is real, then the
// result type shall be real." ... "The result value is 'bx if the first
// operand is zero and the second operand is negative. The result value is 1
// if the second operand is zero." ... "In all cases, the second operand of
// the power operator shall be treated as self-determined."
//
// Rows of Table 5-8 (pp. 46-47) and Table 5-6 (p. 46), signed 32-bit integer
// operands unless sized; printed %0d, reals %f.
// div:  -7/2 = -3.5 -> -3;  7/-2 -> -3
// mod (Table 5-8): 10%3 = 1, 11%3 = 2, 12%3 = 0, -10%3 = -1, 11%-3 = 2,
//       -4'd12 % 3: 4'd12 unsigned, self-determined size max(4,32) = 32,
//       unsigned; -12 mod 2**32 = 4294967284; 2**32 = 4**16 == 1 (mod 3),
//       so 4294967284 == 1 - 12 == 1 (mod 3) -> 1.
// pow (Table 5-8): 3**2 = 9, 2**3 = 8, 2**0 = 1, 0**0 = 1,
//       2 ** -3'sb1: -3'sb1 is 3-bit signed -1 (self-determined); Table 5-6
//       op1 > 1, op2 negative -> 0.
// pow (Table 5-6): (-1)**3 = -1, (-1)**2 = 1, (-1)**-3 = -1, (-1)**-2 = 1,
//       1**-5 = 1, (-2)**-1 = 0 (op1 < -1, op2 negative), 0**5 = 0,
//       (-2)**3 = -8.
// real pow (Table 5-8): 2.0 ** -3'sb1 = 2.0**-1 = 0.5; 9 ** 0.5 = 3.0;
//       9.0 ** (1/2): 1/2 = 0 -> 1.0; -3.0 ** 2.0: unary minus binds first
//       (§5.1.2) -> 9.0.
// x results, into reg [3:0] (context 32 bits, all bits x, truncated to 4):
//       7/0 -> xxxx, 7%0 -> xxxx, 0 ** -1 -> xxxx.
//! inherited IEEE 1364-2005 5.1.5
module b_5_1_5_division_modulus_power;
  reg [3:0] q, m, p;
  initial begin
    $display("div=%0d,%0d", -7 / 2, 7 / -2);
    $display("mod=%0d,%0d,%0d,%0d,%0d,%0d", 10 % 3, 11 % 3, 12 % 3, -10 % 3, 11 % -3, -4'd12 % 3);
    $display("pow=%0d,%0d,%0d,%0d,%0d", 3 ** 2, 2 ** 3, 2 ** 0, 0 ** 0, 2 ** -3'sb1);
    $display("pow6=%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d", (-1) ** 3, (-1) ** 2, (-1) ** -3, (-1) ** -2, 1 ** -5, (-2) ** -1, 0 ** 5, (-2) ** 3);
    $display("real=%f,%f,%f,%f", 2.0 ** -3'sb1, 9 ** 0.5, 9.0 ** (1 / 2), -3.0 ** 2.0);
    q = 7 / 0;
    m = 7 % 0;
    p = 0 ** -1;
    $display("x=%b,%b,%b", q, m, p);
    $finish(0);
  end
endmodule
