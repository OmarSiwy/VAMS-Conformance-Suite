// IEEE 1364-2005 A.8.8, p. 507:
//   string ::= " { Any_ASCII_Characters_except_new_line } "
//
// Strings made of printable characters, spaces, an escaped quote and an
// escaped backslash (§3.6.3's escapes are Any_ASCII_Characters on this
// line), as a $display format and as an assigned value:
//   $display("say \"hi\" \\ ok")    -> say "hi" \ ok
//   the 24-bit reg w = "abc" printed with %s -> abc
// Output: `say "hi" \ ok`, then "abc".
//! inherited IEEE 1364-2005 A.8.8
module b_A_8_8_strings;
  reg [23:0] w;
  initial begin
    $display("say \"hi\" \\ ok");
    w = "abc";
    $display("%s", w);
    $finish(0);
  end
endmodule
