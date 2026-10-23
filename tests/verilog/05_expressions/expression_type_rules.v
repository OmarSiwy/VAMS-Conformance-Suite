// IEEE 1364-2005 §5.5.1, p. 65: "Expression type depends only on the
// operands. It does not depend on the left-hand side (if any). — Decimal
// numbers are signed. — Based_numbers are unsigned, except where the s
// notation is used in the base specifier (as in "4'sd12"). — Bit-select
// results are unsigned, regardless of the operands. — Part-select results are
// unsigned, regardless of the operands even if the part-select specifies the
// entire vector." ... "— Concatenate results are unsigned, regardless of the
// operands. — Comparison results (1, 0) are unsigned, regardless of the
// operands." ... "— If any operand is real, the result is real. — If any
// operand is unsigned, the result is unsigned, regardless of the operator. —
// If all operands are signed, the result will be signed, regardless of
// operator, except when specified otherwise."
//
// s = 4'sb1000 (signed, -8). Each value is assigned to an unsigned
// reg [7:0] u, so the 8-bit extension shows the RHS type (§5.5.3: sign
// extension if, and only if, the RHS is signed):
//   u = s          signed        -> 11111000
//   u = s[3:0]     part-select, the entire vector, unsigned -> 00001000
//   u = s[3]       bit-select unsigned: 1 zero-extended     -> 00000001
//   u = {s}        concatenation unsigned                   -> 00001000
//   u = (s < 4'sd0)  comparison unsigned: 1 zero-extended   -> 00000001
//   u = s + 4'b0000  one unsigned operand: unsigned         -> 00001000
//   u = s + 4'sb0000 all signed: signed                     -> 11111000
// LHS independence: reg signed [7:0] t = 4'b1000 + 4'b0000 is unsigned
//   whatever t is -> 00001000.
// Numbers: -1 < 0 (both decimal, signed) -> 1; -1 < 'd0 ('d0 unsigned, so
//   unsigned compare of 2**n-1 < 0) -> 0; -1 < 'sd0 (s notation) -> 1.
// Real: 1 + 0.5 -> real 1.5.
//! inherited IEEE 1364-2005 5.5.1
module b_5_5_1_expression_type_rules;
  reg signed [3:0] s;
  reg [7:0] u;
  reg signed [7:0] t;
  initial begin
    s = 4'sb1000;
    u = s;            $write("%b ", u);
    u = s[3:0];       $write("%b ", u);
    u = s[3];         $write("%b ", u);
    u = {s};          $write("%b ", u);
    u = (s < 4'sd0);  $display("%b", u);
    u = s + 4'b0000;  $write("%b ", u);
    u = s + 4'sb0000; $write("%b ", u);
    t = 4'b1000 + 4'b0000;
    $display("%b", t);
    $display("%b%b%b %f", -1 < 0, -1 < 'd0, -1 < 'sd0, 1 + 0.5);
    $finish(0);
  end
endmodule
