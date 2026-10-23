// IEEE1364-2005 10.3 printed150-152; block lifecycle also9.8 and11.4.1.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.3
//! expect stdout disable_sibling_block.expected.txt
// At time1 another process disables the target suspended until time5.
// Target continuation runs (resumed1), target tail must not run (late0),
// and a separate sibling process still completes at time3 (sibling1).
// Observe at time6, past every possible uncancelled resumption.
`timescale 1ns/1ns
module audit_disable_sibling_block;
  integer resumed,late,sibling;
  initial begin
    resumed=0; late=0;
    begin : target #5; late=1; end
    resumed=1;
  end
  initial begin sibling=0; #3; sibling=1; end
  initial begin
    #1; disable target;
    #5; $display("sibling-block resumed=%0d late=%0d sibling=%0d",resumed,late,sibling);
    $finish(0);
  end
endmodule
