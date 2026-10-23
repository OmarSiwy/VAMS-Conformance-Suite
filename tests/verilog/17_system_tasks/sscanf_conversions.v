// IEEE 1364-2005 §17.2.4.3, pp. 291-293: "Both functions read characters,
// interpret them according to a format, and store the results." ... "If an
// argument is too small to hold the converted input, then, in general, the
// least significant bits are transferred." The control string holds "a) White
// space characters ... that ... cause input to be read up to the next
// nonwhite space character. b) An ordinary character (not %) that must match
// the next character of the input stream. c) Conversion specifications".
// "% A single % is expected in the input at this point; no assignment is
// done." d "an optionally signed decimal number", h or x "a hexadecimal
// number", o "a octal number", b "a binary number", c "a single character,
// whose 8-bit ASCII value is returned", s "a string, which is a sequence of
// nonwhite space characters". "The number of successfully matched and
// assigned input items is returned in code; this number can be 0 in the event
// of an early matching failure between an input character and the control
// string. If the input ends before the first matching failure or conversion,
// EOF is returned."
//
//   "12 3f 17 101 Z" with "%d %h %o %b %c": five items; a = 12, h = 8'h3f,
//     o = 8'o17 (%o of 8 bits: three digits, 017), bb = 8'b00000101, and the
//     blank before %c skips to Z = 8'h5a -> "5 12 3f 017 00000101 5a"
//   "-45 xyz" with "%d %s": a = -45, s = "xyz" (zero-padded; %s prints no
//     leading zeros) -> "2 -45 [xyz]"
//   "k=+9 50%" with "k=%d %d%%": k and = match literally, a = +9, b = 50,
//     %% matches the % -> "2 9 50"
//   "c3" with "%x": x is h -> "1 c3"
//   "300" with "%d" into 8-bit h: 300 = 9'h12c, the low 8 bits 8'h2c = 44
//     -> "1 44"
//   "q1" with "%d": q is no decimal digit, a matching failure before any
//     item -> 0, and a keeps 5 -> "0 5"
//   "   " with "%d": the input ends before any conversion -> EOF -> "-1"
//! inherited IEEE 1364-2005 17.2.4.3
module b_17_2_4_3_sscanf_conversions;
  integer code, a, b;
  reg [7:0] h, o, bb, ch;
  reg [8*5:1] s;
  initial begin
    code = $sscanf("12 3f 17 101 Z", "%d %h %o %b %c", a, h, o, bb, ch);
    $display("%0d %0d %h %o %b %h", code, a, h, o, bb, ch);
    code = $sscanf("-45 xyz", "%d %s", a, s);
    $display("%0d %0d [%s]", code, a, s);
    code = $sscanf("k=+9 50%", "k=%d %d%%", a, b);
    $display("%0d %0d %0d", code, a, b);
    code = $sscanf("c3", "%x", h);
    $display("%0d %h", code, h);
    code = $sscanf("300", "%d", h);
    $display("%0d %0d", code, h);
    a = 5;
    code = $sscanf("q1", "%d", a);
    $display("%0d %0d", code, a);
    code = $sscanf("   ", "%d", a);
    $display("%0d", code);
    $finish(0);
  end
endmodule
