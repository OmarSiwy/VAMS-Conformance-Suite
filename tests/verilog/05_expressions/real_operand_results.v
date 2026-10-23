// IEEE 1364-2005 §5.1.1, pp. 42-43: "The operators shown in Table 5-2 shall
// be legal when applied to real operands." ... "The result of using logical
// or relational operators on real numbers is a single-bit scalar value."
// Table 5-2: unary + unary -, + - * / **, > >= < <=, ! && ||, == !=, ?:.
// §4.8.1, p. 33, repeats the rule for real variables: "The result of using
// logical or relational operators on real numbers and real variables is a
// single-bit scalar value."
//
// r = 2.5, s = 0.5 (reals, printed with %f: six fraction digits).
//   +r = 2.5, -r = -2.5, r+s = 3.0, r-s = 2.0, r*s = 1.25, r/s = 5.0,
//   r**2.0 = 6.25, (s ? r : s) = 2.5 (s nonzero is true).
//   Relational/equality/logical results are 1 bit each, so a concatenation
//   of them (legal: the operands are not real) is exactly as wide as the
//   number of results:
//   {r>s, r>=s, r<s, r<=s} = 1100
//   {r==s, r!=s} = 01
//   {!r, r&&s, r||0.0} = 011
//! inherited IEEE 1364-2005 5.1.1 4.8.1
module b_5_1_1_real_operand_results;
  real r, s;
  initial begin
    r = 2.5;
    s = 0.5;
    $display("%f %f %f %f %f %f %f %f", +r, -r, r + s, r - s, r * s, r / s, r ** 2.0, s ? r : s);
    $display("rel=%b eq=%b logic=%b", {r > s, r >= s, r < s, r <= s}, {r == s, r != s}, {!r, r && s, r || 0.0});
    $finish(0);
  end
endmodule
