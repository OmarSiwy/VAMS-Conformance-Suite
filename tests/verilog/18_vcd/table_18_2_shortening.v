// IEEE 1364-2005 §18.2.2, p. 331: "Dumps of value changes to scalar variables
// shall not have any white space between the value and the identifier code.
// Dumps of value changes to vectors shall not have any white space between
// the base letter and the value digits, but they shall have one white space
// between the value digits and the identifier code. The output format for
// each value is right-justified. Vector values appear in the shortest form
// possible: redundant bit values that result from left-extending values to
// fill a particular vector size are eliminated." Table 18-1 left-extends a
// leading 1 or 0 with 0, a Z with Z and an X with X. Table 18-2's rows, for a
// 4-bit reg: 0010 -> b10, XX10 -> bX10, ZZX0 -> bZX0, 0X10 -> b0X10.
//
// HAND DERIVATION (the d09_11 CONVENTION: codes from `!`; this writer prints
// x and z in lower case, which Syntax 18-8's value ::= 0|1|x|X|z|Z admits;
// changes in one time record in $var order, so #4 and #5 list s before r
// although r is assigned first; a range as its own token, `r [3:0]`):
// s is the scalar, code !; r is reg [3:0], code ".
//   #0 $dumpvars: s = 1, r = 4'b0010: 1! and b10 " (Table 18-2 row 1).
//   #1 r = 4'bxx10 -> bx10 "   (row 2: the second x extends the first)
//   #2 r = 4'bzzx0 -> bzx0 "   (row 3)
//   #3 r = 4'b0x10 -> b0x10 "  (row 4: a 0 extends with 0, and 0 does not
//                               extend to x, so it stays)
//   #4 r = 4'b1000 -> b1000 "  (a leading 1 is never redundant); s = z -> z!
//   #5 r = 4'b0000 -> b0 "; s = x -> x!
//   #6 r = 4'bzzzz -> bz "
//! inherited IEEE 1364-2005 18.2.2
//! expect vcd table_18_2_shortening.vcd == table_18_2_shortening.expected.vcd
`timescale 1ns/1ns
module b_18_2_2_table_18_2_shortening;
  reg s;
  reg [3:0] r;
  initial begin
    $dumpfile("table_18_2_shortening.vcd");
    $dumpvars(1, b_18_2_2_table_18_2_shortening);
    s = 1'b1;
    r = 4'b0010;
    #1 r = 4'bxx10;
    #1 r = 4'bzzx0;
    #1 r = 4'b0x10;
    #1 r = 4'b1000;
       s = 1'bz;
    #1 r = 4'b0000;
       s = 1'bx;
    #1 r = 4'bzzzz;
    $finish(0);
  end
endmodule
