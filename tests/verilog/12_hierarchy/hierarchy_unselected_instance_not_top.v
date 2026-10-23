// IEEE1364-2005 12.1.1 printed165: an instantiated module is not a top,
// even if its instantiation is in an unselected generate block. Thus the
// leaf's initial must never run; only top prints. A delayed top finish
// cannot race away an erroneously instantiated leaf's time0 message.
//! lrm 6.2.1
//! lrm 6.2.1:1000
//! inherited IEEE 1364-2005 12.1.1
//! expect stdout hierarchy_unselected_instance_not_top.expected.txt
`timescale 1ns/1ns
module audit_hierarchy_unselected_instance_not_top;
  generate
    if(0) begin : unselected
      audit_unselected_leaf u();
    end
  endgenerate
  initial begin #1; $display("top-only"); $finish(0); end
endmodule
module audit_unselected_leaf;
  initial $display("ERROR: non-top leaf executed");
endmodule
