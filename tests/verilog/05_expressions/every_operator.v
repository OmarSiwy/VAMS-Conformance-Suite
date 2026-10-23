// IEEE 1364-2005 §5.1, p. 41: "The symbols for the Verilog HDL operators are
// similar to those in the C programming language. Table 5-1 lists these
// operators."
//
// Every Table 5-1 row once, on a = 4'b1100 (12), b = 4'b1010 (10), both
// unsigned. $display arguments are self-determined (§5.4.1 Table 5-22), so a
// binary arithmetic or bitwise result is max(4,4) = 4 bits, a relational,
// equality, logical or reduction result 1 bit, a shift L(a) = 4 bits.
//   {a,b} = 1100_1010        {2{b}} = 1010_1010
//   +a = 1100                -a = 16-12 = 4 = 0100
//   a+b = 22 mod 16 = 6 = 0110          a-b = 2 = 0010
//   a*b = 120 mod 16 = 8 = 1000         a/b = 1 = 0001
//   a%b = 2 = 0010           t**2, t = 4'd3: 9 = 1001
//   a>b 1, a>=b 1, a<b 0, a<=b 0
//   !a 0 (a nonzero), a&&b 1, a||b 1
//   a==b 0, a!=b 1, a===b 0, a!==b 1
//   ~a = 0011, a&b = 1000, a|b = 1110, a^b = 0110, a^~b = a~^b = 1001
//   &a 0, ~&a 1, |a 1, ~|a 0, ^a 0 (two ones), ~^a 1, ^~a 1
//   a<<1 = 1000, a>>1 = 0110, a<<<1 = 1000, a>>>1 = 0110 (unsigned: zero fill)
//   a ? b : t -> a is nonzero, so b = 1010
//! inherited IEEE 1364-2005 5.1
module b_5_1_every_operator;
  reg [3:0] a, b, t;
  initial begin
    a = 4'b1100;
    b = 4'b1010;
    t = 4'd3;
    $display("cat=%b rep=%b", {a, b}, {2{b}});
    $display("unary=%b,%b", +a, -a);
    $display("arith=%b,%b,%b,%b,%b,%b", a + b, a - b, a * b, a / b, a % b, t ** 2);
    $display("rel=%b%b%b%b", a > b, a >= b, a < b, a <= b);
    $display("logic=%b%b%b", !a, a && b, a || b);
    $display("eq=%b%b%b%b", a == b, a != b, a === b, a !== b);
    $display("bit=%b,%b,%b,%b,%b,%b", ~a, a & b, a | b, a ^ b, a ^~ b, a ~^ b);
    $display("red=%b%b%b%b%b%b%b", &a, ~&a, |a, ~|a, ^a, ~^a, ^~a);
    $display("shift=%b,%b,%b,%b", a << 1, a >> 1, a <<< 1, a >>> 1);
    $display("cond=%b", a ? b : t);
    $finish(0);
  end
endmodule
