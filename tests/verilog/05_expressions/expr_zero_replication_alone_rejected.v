// IEEE1364-2005 §5.1.14: zero replication requires a positive-width
// sibling in its immediately enclosing concatenation; assignment width
// does not provide that sibling.
//! inherited IEEE 1364-2005 5.1.14
//! reject zero replication requires an immediately enclosing concatenation with a positive-width operand
module audit_expr_zero_replication_alone_rejected;
  reg [7:0] value;
  initial value={0{1'b1}};
endmodule
