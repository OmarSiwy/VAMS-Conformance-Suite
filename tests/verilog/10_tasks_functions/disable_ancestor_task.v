// IEEE1364-2005 10.3 printed150-152; block lifecycle also9.8 and11.4.1.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.3
//! expect stdout disable_ancestor_task.expected.txt
// Disabling outer terminates middle and leaf too; none of their trailing
// statements executes, but the original caller resumes. leaf schedules an
// NBA before suspension: IEEE10.3 makes its result unspecified on disable.
// pending_value is deliberately NOT printed or asserted, so either outcome
// is permitted. This tests lifecycle despite pending work, NOT NBA cancellation.
`timescale 1ns/1ns
module audit_disable_ancestor_task;
  integer resumed,leaf_tail,middle_tail,outer_tail;
  reg pending_value;
  task leaf; begin pending_value<=#3 1'b1; #5; leaf_tail=1; end endtask
  task middle; begin leaf; middle_tail=1; end endtask
  task outer; begin middle; outer_tail=1; end endtask
  initial begin
    resumed=0; leaf_tail=0; middle_tail=0; outer_tail=0; pending_value=0;
    outer; resumed=1;
  end
  initial begin
    #1; disable outer;
    #5; $display("task-chain resumed=%0d tails=%0d,%0d,%0d",resumed,leaf_tail,middle_tail,outer_tail);
    $finish(0);
  end
endmodule
