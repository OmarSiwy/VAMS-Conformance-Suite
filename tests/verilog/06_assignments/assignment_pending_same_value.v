// IEEE1364-2005 §6.1.3(b): cancel pending propagation only if the newly
// evaluated RHS differs from the pending value. At10 a rises, scheduling1
// at15. At12 b rises too, but(a|b) is still1: delivery remains15, not17.
//! inherited IEEE 1364-2005 6.1.3
`timescale 1ns/1ns
module audit_assignment_pending_same_value;
  reg a, b;
  wire y;
  assign #5 y = a | b;
  initial begin
    a = 0; b = 0;
    #10 a = 1;
    #2 b = 1;
    #2 $display("before=%b", y);
    #2 $display("original_deadline_passed=%b", y);
    $finish(0);
  end
endmodule
