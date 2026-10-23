// IEEE1364-2005 10.3 printed150-152; block lifecycle also9.8 and11.4.1.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.3
//! expect stdout disable_sibling_task.expected.txt
// Disabling a task returns its caller to the following statement. The
// unrelated sibling task remains active. No output/inout copy-out oracle.
// Each observer runs after the target's original completion time.
`timescale 1ns/1ns
module audit_disable_sibling_task;
  integer resumed,late,sibling;
  task target; begin #5; late=1; end endtask
  task other; begin #3; sibling=1; end endtask
  initial begin resumed=0; late=0; target; resumed=1; end
  initial begin sibling=0; other; end
  initial begin
    #1; disable target;
    #5; $display("sibling-task resumed=%0d late=%0d sibling=%0d",resumed,late,sibling);
    $finish(0);
  end
endmodule
