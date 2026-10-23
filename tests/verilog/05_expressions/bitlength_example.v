// IEEE 1364-2005 §5.4.2, pp. 63-64: "During the evaluation of an expression,
// interim results shall take the size of the largest operand (in case of an
// assignment, this also includes the left-hand side)."
//
// The clause's first example, reg [15:0] a, b, answer; a = 16'hFFFF,
// b = 16'h0001:
//   answer = (a + b) >> 1: all operands 16 bits, a + b = 0 in 16 bits,
//     >> 1 -> 0000000000000000 ("will not work properly")
//   answer = (a + b + 0) >> 1: the unsized 0 is integer-sized (at least 32
//     bits), so a + b = 17'h10000 survives; >> 1 = 16'h8000 ->
//     1000000000000000 (the same for any integer size above 16)
// The clause's module bitlength (p. 64): a = 9, b = 8, c = 1, reg [4:0] d
//   (never assigned: x in every bit); c ? (a&b) : d. c is 1 (known), so the
//   result is a&b = 1001 & 1000 = 1000, in max(L(a&b), L(d)) = 5 bits ->
//   "answer = 01000", the clause's stated output.
//! inherited IEEE 1364-2005 5.4.2
module b_5_4_2_bitlength_example;
  reg [15:0] a16, b16, answer;
  reg [3:0] a, b, c;
  reg [4:0] d;
  initial begin
    a16 = 16'hFFFF;
    b16 = 16'h0001;
    answer = (a16 + b16) >> 1;
    $display("%b", answer);
    answer = (a16 + b16 + 0) >> 1;
    $display("%b", answer);
    a = 9;
    b = 8;
    c = 1;
    $display("answer = %b", c ? (a&b) : d);
    $finish(0);
  end
endmodule
