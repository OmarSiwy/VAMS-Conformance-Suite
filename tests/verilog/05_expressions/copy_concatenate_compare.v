// IEEE 1364-2005 §5.2.3.1, p. 59: "The common string operations copy,
// concatenate, and compare are supported by Verilog HDL operators. Copy is
// provided by simple assignment. Concatenation is provided by the
// concatenation operator. Comparison is provided by the equality operators."
//
// Registers exactly 8*n bits wide (the clause's advice), so no padding enters:
//   copy: a = "abc" (24 bits), b = a -> b is "abc"
//   concatenate: c = {a, "def"} (48 bits) -> "abcdef"
//   compare: b == "abc" -> 1; b == "abd" -> 0; c != "abcdef" -> 0
//! inherited IEEE 1364-2005 5.2.3.1
module b_5_2_3_1_copy_concatenate_compare;
  reg [8*3:1] a, b;
  reg [8*6:1] c;
  initial begin
    a = "abc";
    b = a;
    c = {a, "def"};
    $display("%s %s", b, c);
    $display("%b%b%b", b == "abc", b == "abd", c != "abcdef");
    $finish(0);
  end
endmodule
