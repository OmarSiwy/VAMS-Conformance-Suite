// IEEE 1364-2005 §5.2.3, pp. 58-59: "String operands shall be treated as
// constant numbers consisting of a sequence of 8-bit ASCII codes, one per
// character. Any Verilog HDL operator can manipulate string operands. The
// operator shall behave as though the entire string were a single numeric
// value. When a variable is larger than required to hold the value being
// assigned, the contents after the assignment shall be padded on the left
// with zeros."
//
// The clause's string_test (p. 59), reg [8*14:1] stringvar (112 bits, 28 hex
// digits):
//   stringvar = "Hello world": 11 characters = 88 bits, "H"=48 "e"=65 "l"=6c
//     "l"=6c "o"=6f " "=20 "w"=77 "o"=6f "r"=72 "l"=6c "d"=64, padded on the
//     left with 112-88 = 24 zero bits -> 00000048656c6c6f20776f726c64
//   stringvar = {stringvar,"!!!"}: 112 + 24 = 136 bits; assignment keeps the
//     low 112 (§5.6), dropping the 24 zero bits: "!" = 21 ->
//     48656c6c6f20776f726c64212121, which %s prints as "Hello world!!!".
// The clause prints the first line with %s as well; this fixture prints the
// padded value with %h only, since the padding NUL bytes are not printable
// characters. "Any operator": "ab" + 16'd1 = 16'h6162 + 1, 16 bits -> 6163.
//! inherited IEEE 1364-2005 5.2.3
module b_5_2_3_string_test;
  reg [8*14:1] stringvar;
  initial begin
    stringvar = "Hello world";
    $display("%h", stringvar);
    stringvar = {stringvar, "!!!"};
    $display("%s is stored as %h", stringvar, stringvar);
    $display("%h", "ab" + 16'd1);
    $finish(0);
  end
endmodule
