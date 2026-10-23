// IEEE 1364-2005 §17.2.4.3, pp. 291-292: "c) Conversion specifications
// consisting of the character %, an optional assignment suppression character
// *, a decimal digit string that specifies an optional numerical maximum
// field width, and a conversion code. A conversion specification directs the
// conversion of the next input field; the result is placed in the variable
// specified in the corresponding argument unless assignment suppression was
// indicated by the character *." ... "An input field is defined as a string
// of nonspace characters; it extends to the next inappropriate character or
// until the maximum field width, if one is specified, is exhausted."
//   b "a sequence from the set 0,1,X,x,Z,z,?, and _"
//   d "an optionally signed decimal number, consisting of the optional sign
//     from the set + or -, followed by a sequence of characters from the set
//     0,1,2,3,4,5,6,7,8,9, and _, or a single value from the set x,X,z,Z,?"
//   h or x "... 0,...,9,a,A,...,f,F,x,X,z,Z,?, and _"
//   f, e, or g "Matches a floating point number."
// The clause lists the characters a field may hold but not the value an x or
// z digit gives; the values below take §3.5.1's (p. 10): "An x shall set 4
// bits to unknown in the hexadecimal base ... Similarly, a z shall set 4
// bits" and "If the leftmost bit in the unsigned number is an x or a z, then
// an x or a z shall be used to pad to the left", so a decimal field that is
// the single value x is x in every bit, as 'dx is.
//
//   "1_01" %b: the underscore belongs to the number, 101 -> "1 00000101"
//   "a_b"  %h: ab -> "1 ab"
//   "x"    %d: the single value x; a 32-bit integer all x, %0d -> "1 x"
//   "1z"   %h: two hex digits 1 and z -> 8'h1z -> "1 1z"
//   "123456" %3d%d: the width 3 ends the first field at 123; the second
//          field is 456 -> "2 123 456"
//   "7 8 9" %d %*d %d: 8 is read and not assigned, and is not counted
//          ("successfully matched and assigned input items") -> "2 7 9"
//   "2.5e1" %f into a real: 25.0 -> "1 25.000000"
//   "-1.5"  %e into a real -> "1 -1.500000"
//! inherited IEEE 1364-2005 17.2.4.3
module b_17_2_4_3_sscanf_field_rules;
  integer code, a, b;
  reg [7:0] h;
  real r;
  initial begin
    code = $sscanf("1_01", "%b", h);
    $display("%0d %b", code, h);
    code = $sscanf("a_b", "%h", h);
    $display("%0d %h", code, h);
    code = $sscanf("x", "%d", a);
    $display("%0d %0d", code, a);
    code = $sscanf("1z", "%h", h);
    $display("%0d %h", code, h);
    code = $sscanf("123456", "%3d%d", a, b);
    $display("%0d %0d %0d", code, a, b);
    code = $sscanf("7 8 9", "%d %*d %d", a, b);
    $display("%0d %0d %0d", code, a, b);
    code = $sscanf("2.5e1", "%f", r);
    $display("%0d %f", code, r);
    code = $sscanf("-1.5", "%e", r);
    $display("%0d %f", code, r);
    $finish(0);
  end
endmodule
