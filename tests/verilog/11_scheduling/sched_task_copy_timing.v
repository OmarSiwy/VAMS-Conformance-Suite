// IEEE1364-2005 §11.6.7: copy input at invocation, output only at return.
// Called at1 with3; caller input changes to9 at2 but copied input stays3.
// Internal output is assigned before suspension, yet caller output remains0
// at3. At5 task returns3+1=4 and blocking copy-out precedes following display.
//! inherited IEEE 1364-2005 11.6.7
`timescale 1ns/1ns
module audit_sched_task_copy_timing;
  reg [3:0] source, result;
  task delayed(input [3:0] i, output [3:0] o);
    begin
      o = i;
      #4 o = i + 1;
    end
  endtask
  initial begin
    source = 3; result = 0;
    #1 delayed(source, result);
    $display("returned=%0d", result);
    #1 $finish(0);
  end
  initial begin
    #2 source = 9;
    #1 $display("pending=%0d", result);
  end
endmodule
