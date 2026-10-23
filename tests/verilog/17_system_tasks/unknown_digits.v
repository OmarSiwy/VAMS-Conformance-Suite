// IEEE 1364-2005 §17.1.1.4, pp. 282-283: "In hexadecimal (%h) and octal (%o)
// formats, the rules are as follows: -- Each group of 4 bits is represented
// as a single hexadecimal digit; each group of 3 bits is represented as a
// single octal digit. -- If all bits in a group are at the unknown value, a
// lowercase x is displayed for that digit. -- If all bits in a group are at a
// high-impedance state, a lowercase z is printed for that digit. -- If some,
// but not all, bits in a group are unknown, an uppercase X is displayed for
// that digit. -- If some, but not all, bits in a group are at a
// high-impedance state, then an uppercase Z is displayed for that digit,
// unless there are also some bits at the unknown value, in which case an
// uppercase X is displayed for that digit. In binary (%b) format, each bit is
// printed separately using the characters 0, 1, x, and z."
//
// The clause's three examples (p. 283), groups taken from the LSB:
//   %d of 1'bx: every bit x -> x (a 1-bit value's field is one column).
//   %h of 14'bx01010: the leading x fills bits 13..5, so the groups are
//     [13:12] xx -> x, [11:8] xxxx -> x, [7:4] xxx0 -> X, [3:0] 1010 -> a:
//     "xxXa".
//   %h and %o of 12'b001xxx101x01 (bits 11..0 = 0 0 1 x x x 1 0 1 x 0 1):
//     hex [11:8] 001x -> X, [7:4] xx10 -> X, [3:0] 1x01 -> X: "XXX";
//     octal [11:9] 001 -> 1, [8:6] xxx -> x, [5:3] 101 -> 5, [2:0] x01 -> X:
//     "1x5X".
// The z rules:
//   %h of 8'bzzzz_1zz0: [7:4] all z -> z, [3:0] some z, no x -> Z: "zZ".
//   %h of 8'b0xz1_zzzz: [7:4] has z and x -> X, [3:0] all z -> z: "Xz".
//   %o of 6'bzzz_z01: [5:3] all z -> z, [2:0] some z -> Z: "zZ".
//   %b of 4'b01xz: bit by bit -> "01xz".
//! inherited IEEE 1364-2005 17.1.1.4
module b_17_1_1_4_unknown_digits;
  initial begin
    $display("%d", 1'bx);
    $display("%h", 14'bx01010);
    $display("%h %o", 12'b001xxx101x01, 12'b001xxx101x01);
    $display("%h %h %o %b", 8'bzzzz_1zz0, 8'b0xz1_zzzz, 6'bzzz_z01, 4'b01xz);
    $finish(0);
  end
endmodule
