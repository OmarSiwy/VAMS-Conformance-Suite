// IEEE1364-2005 10.2.2, printed147: Output actual is an expression, not an assignable procedural destination.
// Legal-context control: task_output_lifetime.v.
// The reject phrase below is an INTENDED rule-specific diagnostic, not an
// observed current diagnostic. Generic unsupported-declaration rejection
// cannot establish this rule; the paired legal control must execute too.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.2.2
//! reject task output actual must be a procedural lvalue
//! neighbour task_output_lifetime.v
module audit_task_output_expression_rejected;
  task give(output [3:0] result); result=4'd5; endtask
  initial give(4'd1+4'd2);
endmodule
