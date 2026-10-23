// IEEE 1364-2005 §6.1.2, p. 70: "Example 2—The following is an example of the
// use of a continuous assignment to model a 4-bit adder with carry. The
// assignment could not be specified directly in the declaration of the nets
// because it requires a concatenation on the left-hand side." The adder
// module below is the clause's, verbatim.
//
// The sum is sized by its context: the concatenation {carry_out, sum_out} is
// 5 bits, the widest operand, so ina + inb + carry_in is computed in 5 bits
// (§5.4.1) and the carry is kept. Each read is one time unit after the change.
//   ina = 3, inb = 4, carry_in = 0   -> 7  = 0_0111
//   ina = f, inb = 1, carry_in = 1   -> 17 = 1_0001
//   ina = f, inb = f, carry_in = 1   -> 31 = 1_1111
//! inherited IEEE 1364-2005 6.1.2
module adder (sum_out, carry_out, carry_in, ina, inb);
output [3:0] sum_out;
output carry_out;
input [3:0] ina, inb;
input carry_in;
wire carry_out, carry_in;
wire [3:0] sum_out, ina, inb;
assign {carry_out, sum_out} = ina + inb + carry_in;
endmodule

module b_6_1_2_adder_concatenation_lhs;
  reg [3:0] a, b;
  reg c;
  wire [3:0] s;
  wire co;
  adder u(s, co, c, a, b);
  initial begin
    a = 4'h3; b = 4'h4; c = 0;
    #1 $display("%b %b", co, s);
    a = 4'hf; b = 4'h1; c = 1;
    #1 $display("%b %b", co, s);
    b = 4'hf;
    #1 $display("%b %b", co, s);
    $finish(0);
  end
endmodule
