// IEEE1364-2005 10.3 printed150-152; block lifecycle also9.8 and11.4.1.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.3
//! expect stdout disable_recursive_task.expected.txt
// Disabling the automatic task from its innermost recursive activation
// terminates ALL current activations, not just a local return. A conventional
// return would execute two caller tails; disable must leave tails0 and resume
// only the module caller. No output/inout values or pending assignments used.
module audit_disable_recursive_task;
  integer tails,resumed;
  task automatic descend(input integer depth);
    begin
      if(depth==0) disable descend;
      else descend(depth-1);
      tails=tails+1;
    end
  endtask
  initial begin
    tails=0; resumed=0; descend(2); resumed=1;
    $display("recursive tails=%0d resumed=%0d",tails,resumed); $finish(0);
  end
endmodule
