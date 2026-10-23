// IEEE 1364-2005 §5.1.9, p. 49: "The result of the evaluation of a logical
// comparison shall be 1 (defined as true), 0 (defined as false), or, if the
// result is ambiguous, the unknown value (x). The precedence of && is greater
// than that of ||, and both are lower than relational and equality
// operators." ... "The negation operator converts a nonzero or true operand
// into 0 and a zero or false operand into 1. An ambiguous truth value remains
// as x."
//
// The clause's Example 1 (alpha = 237, beta = 0):
//   alpha && beta -> 0          alpha || beta -> 1
// Precedence, a = 1, b = 2, c = 2 (Example 2's shape):
//   a > 2 && b == c || 1   = ((a>2) && (b==c)) || 1 = (0 && 1) || 1 -> 1
//                          (were || above &&: 0 && (1 || 1) -> 0)
//   a < 2 && b == c        = 1 && 1 -> 1   (were && above ==: a < (2&&b) == c
//                            = (1<1) == 2 = 0 == 2 -> 0)
// Negation: !237 -> 0, !0 -> 1, !(4'b00x0) -> ambiguous -> x.
//! inherited IEEE 1364-2005 5.1.9
module b_5_1_9_logical_connectives;
  integer alpha, beta, a, b, c;
  initial begin
    alpha = 237;
    beta = 0;
    a = 1;
    b = 2;
    c = 2;
    $display("%b %b", alpha && beta, alpha || beta);
    $display("%b %b", a > 2 && b == c || 1, a < 2 && b == c);
    $display("%b %b %b", !alpha, !beta, !(4'b00x0));
    $finish(0);
  end
endmodule
