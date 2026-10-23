// IEEE1364-2005 10.2.2, printed147: A null argument is expressly forbidden; it is not a default argument.
// Legal-context control: task_copy_timing.v.
// The reject phrase below is an INTENDED rule-specific diagnostic, not an
// observed current diagnostic. Generic unsupported-declaration rejection
// cannot establish this rule; the paired legal control must execute too.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.2.2
//! reject null task arguments are not permitted
//! neighbour task_copy_timing.v
module audit_task_null_argument_rejected;
  task take(input a,input b); begin end endtask
  initial take(1'b1,);
endmodule
