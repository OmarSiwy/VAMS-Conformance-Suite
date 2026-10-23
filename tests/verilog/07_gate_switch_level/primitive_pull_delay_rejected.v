// IEEE1364-2005 §§7.1.3/7.8 forbid a delay on pullup or pulldown.
// The forbidden # is rejected by the primitive grammar before execution.
//! reject E0207
//! inherited IEEE 1364-2005 7.1.3 7.8
//! reject unexpected token: found `#`
module audit_primitive_pull_delay_rejected;
  wire y;
  pullup #1 p(y);
endmodule
