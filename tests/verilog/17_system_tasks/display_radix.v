// §9.4.1 Table 9-1 gives $display, $displayb, $displayh and $displayo all
// "Supported in digital context: Yes", and §9.4.3 Table 9-22 defines the
// consuming conversions: "%h or %H Display in hexadecimal format / %d or %D
// Display in decimal format / %o or %O Display in octal format / %b or %B
// Display in binary format". §9.4.3's last sentence before Table 9-23 supplies
// the no-specifier rule: "Any expression argument with no corresponding format
// specification is displayed using the default decimal format in $strobe."
// §9.4.1 supplies the null-argument rule: "Any null argument produces a single
// space character in the display. (A null argument is characterized by two
// adjacent commas (,,) in the argument list.)" and the empty-call rule: "When
// $strobe is invoked without arguments, it simply prints a newline character."
// §9.4.1 also states the $write difference: "The $write task provides the same
// capabilities as $strobe, but with no newline."
//
// The FIELD WIDTHS are the inherited IEEE 1364-2005 §17.1.1.3 rule, "Automatic
// sizing of displayed data" — NOT §17.1.1.2, which is "Format specifications".
// The repo's own mapping of the two is specification/CLAUSE-AUDIT.md:274-275 (17.1-04 =
// "17.1.1.2 format specifications", 17.1-05 = "17.1.1.3 automatic sizing of
// displayed data"); this header cited the wrong subclause until the review.
// The rule: a radix conversion is sized to the operand's declared width, and
// the default decimal field is sized to the largest value the operand can hold.
// VerA's ANALOG printer deliberately deviates on the decimal width
// (lib/backend/cg_display.zig:128 "a bare INTEGER prints minimal-width"); that
// deviation is justified there by the analog integer being 64 bits wide, and it
// does NOT carry over here — a digital `reg [7:0]` has a declared width of 8,
// so the 1364 sizing is both meaningful and cheap. This file pins the digital
// sizing. (That source comment numbers the heritage it deviates from
// "§17.1.1.2"; by the mapping above the sizing rule is §17.1.1.3. The comment
// lives in src/ and is out of scope for this row — it is named here so the
// wrong number is not copied out of it again.)
//
// HAND DERIVATION, operand `reg [7:0] v`:
//   width 8  -> %b prints 8 binary digits
//            -> %h prints ceil(8/4) = 2 hex digits
//            -> %o prints ceil(8/3) = 3 octal digits
//            -> %d field = digits of the largest 8-bit value 255 = 3 columns,
//               right-justified with LEADING SPACES (not zeros)
//   %0d suppresses the field width entirely (minimum width), so it prints the
//   digits only.
//
//   v = 8'd7  = 8'b0000_0111 = 8'h07 = 8'o007
//     %d  -> "  7"        (3-column field, two leading spaces)
//     %0d -> "7"
//     %h  -> "07"
//     %o  -> 8 bits split from the LSB: {b2,b1,b0}=111=7, {b5,b4,b3}=000=0,
//            {b7,b6}=00=0  ->  "007"
//     %b  -> "00000111"
//
//   v = 8'b1010_0101 = 8'hA5 = 165 decimal
//     %d  -> "165"        (exactly fills the 3-column field, no padding)
//     %h  -> nibbles 1010=a, 0101=5 -> "a5"
//     %o  -> {b2,b1,b0}=101=5, {b5,b4,b3}=100=4, {b7,b6}=10=2 -> "245"
//     %b  -> "10100101"
//
// The radix DEFAULT-FORMAT tasks then print the same 8-bit 0xA5 with no format
// string at all: $displayh -> "a5", $displayo -> "245", $displayb ->
// "10100101", plain $display -> the §9.4.3 default decimal "165".
//
// Why 0xA5 and not, say, 0xFF: its four nibbles/octal groups are all different
// from each other and from the decimal digits, so a printer that ignores the
// requested radix cannot accidentally agree with the expectation. Why 7 as the
// second value: it is the only one of the two that exercises padding, because
// its rendering is SHORTER than every field width above.
//
//! lrm 9.4.1
//! lrm 9.4.3
//! inherited IEEE 1364-2005 17.1 (17.1.1.3 automatic sizing of displayed data)
//! expect stdout 01_display_radix.expected.txt
`timescale 1ns/1ns
module d09_display_radix;
  reg [7:0] v;
  initial begin
    v = 8'd7;
    $display("[%d][%0d][%h][%o][%b]", v, v, v, v, v);
    v = 8'b1010_0101;
    $display("[%d][%h][%o][%b]", v, v, v, v);
    $displayh(v);
    $displayo(v);
    $displayb(v);
    $display(v);
    $write("no");
    $write("newline");
    $display("");
    $display("[", , "]");
    $display("bare=", v);
    $display;
    $finish(0);
  end
endmodule
