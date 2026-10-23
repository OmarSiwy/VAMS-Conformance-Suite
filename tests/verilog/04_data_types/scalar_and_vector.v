// IEEE 1364-2005 §4.3, p. 24: "A net or reg declaration without a range
// specification shall be considered 1 bit wide and is known as a scalar.
// Multibit net and reg data types shall be declared by specifying a range,
// which is known as a vector."
//
// {1'b1, e} is 1 followed by exactly the width of e (concatenation operands
// are self-determined, §5.4.1), so it shows each declaration's width:
//   reg a (scalar) = 1        -> 11
//   wire w1 = a (scalar)      -> 11
//   reg [3:0] v = 4'b0101     -> 10101
//   wire [15:0] busa = 16'h1  -> 1 0000000000000001
// A scalar keeps one bit of a wider value: a = 2'b10 -> a = 0 (§5.6).
//! inherited IEEE 1364-2005 4.3
module b_4_3_scalar_and_vector;
  reg a;
  reg [3:0] v;
  wire w1 = a;
  wire [15:0] busa = 16'h1;
  initial begin
    a = 1;
    v = 4'b0101;
    #1 $display("%b %b %b %b", {1'b1, a}, {1'b1, w1}, {1'b1, v}, {1'b1, busa});
    a = 2'b10;
    $display("%b", a);
    $finish(0);
  end
endmodule
