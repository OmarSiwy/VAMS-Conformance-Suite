// IEEE 1364-2005 §6.2.1, pp. 72-73: "The variable declaration assignment is a
// special case of procedural assignment as it assigns a value to a variable.
// It allows an initial value to be placed in a variable in the same statement
// that declares the variable. The assignment shall be to a constant
// expression. The assignment does not have duration; instead, the variable
// holds the value until the next assignment to that variable." Examples 1, 3,
// 4 and 5, verbatim:
//   "Example 1—Declare a 4-bit reg and assign it the value 4.
//      reg[3:0] a = 4'h4;
//    This is equivalent to writing
//      reg[3:0] a;
//      initial a = 4'h4;"
//   "Example 3—Declare two integers; the first is assigned the value of 0.
//      integer i = 0, j;"
//   "Example 4—Declare two real variables, assigned to the values 2.5 and
//    300,000.
//      real r1 = 2.5, n300k = 3E6;"
//   "Example 5—Declare a time variable and realtime variable with initial
//    values.
//      time t1 = 25;
//      realtime rt1 = 2.5;"
// (Example 2 is the illegal array form, in
// array_declaration_assignment_rejected.v.)
//
// All reads are at time 1: a declaration assignment takes effect "as if the
// assignment occurred in a blocking assignment in an initial construct"
// (§4.2.2, p. 23), and initial constructs start in no defined order, so
// nothing is read at time 0.
//   a = 4'h4, and b, Example 1's equivalent `initial b = 4'h4` -> 4 4
//   i = 0; j has no declaration assignment, so x (§4.2.2): j === 32'bx -> 0 1
//   r1 = 2.5; n300k = 3E6 = 3 000 000.0 (the example's prose says 300,000,
//     but the constant 3E6 is three million; the code is what is run)
//                                         -> 2.500000 3000000.000000
//   t1 = 25, rt1 = 2.5                    -> 25 2.500000
//   Holds until the next assignment: a = a + 1 at time 1 -> 5, read at 2.
//! inherited IEEE 1364-2005 6.2.1
module b_6_2_1_examples;
  reg[3:0] a = 4'h4;
  reg[3:0] b;
  initial b = 4'h4;
  integer i = 0, j;
  real r1 = 2.5, n300k = 3E6;
  time t1 = 25;
  realtime rt1 = 2.5;
  initial begin
    #1 $display("%h %h", a, b);
    $display("%0d %b", i, j === 32'bx);
    $display("%f %f", r1, n300k);
    $display("%0d %f", t1, rt1);
    a = a + 1;
    #1 $display("%h", a);
    $finish(0);
  end
endmodule
