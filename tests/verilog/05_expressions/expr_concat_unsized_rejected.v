// IEEE1364-2005 §5.1.14: direct unsized constant operand is prohibited.
//! inherited IEEE 1364-2005 5.1.14
//! reject unsized constant numbers are not allowed as concatenation operands
module audit_expr_concat_unsized_rejected;
  reg [7:0] value;
  initial value={1,1'b0};
endmodule
