// IEEE 1364-2005 §5.2.3.2, pp. 59-60: "When strings are assigned to variables,
// the values stored shall be padded on the left with zeros. Padding can
// affect the results of comparison and concatenation operations. The
// comparison and concatenation operators shall not distinguish between zeros
// resulting from padding and the original string characters (\0, ASCII
// NUL)."
//
// The clause's example, reg [8*10:1] s1, s2 (80 bits, 20 hex digits each):
//   s1 = "Hello" (40 bits) -> 000000000048656c6c6f
//   s2 = " world!" (56 bits) -> 00000020776f726c6421
//   {s1,s2} -> 000000000048656c6c6f00000020776f726c6421
//   {s1,s2} == "Hello world!" -> 0, "This comparison yields a result of
//     zero" (p. 60)
// The NUL rule: {s1,s2} == "\0\0\0\0\0Hello\0\0\0 world!", whose zero bytes
// are \0 characters (5 + 5 + 3 + 7 = 20 characters = 160 bits), -> 1.
//! inherited IEEE 1364-2005 5.2.3.2
module b_5_2_3_2_padding_breaks_compare;
  reg [8*10:1] s1, s2;
  initial begin
    s1 = "Hello";
    s2 = " world!";
    $display("%h %h", s1, s2);
    $display("%h", {s1, s2});
    $display("%b %b", {s1, s2} == "Hello world!", {s1, s2} == "\0\0\0\0\0Hello\0\0\0 world!");
    $finish(0);
  end
endmodule
