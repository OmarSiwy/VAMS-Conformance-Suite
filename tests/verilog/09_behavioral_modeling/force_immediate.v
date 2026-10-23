//! inherited IEEE 1364-2005 9.3.2
// force on a net takes effect when it executes: the next statement in the same
// thread reads the forced value (force1).
module triage_force_immediate;
  reg [3:0] val_drv = 4'b0101;
  wire [3:0] val;

  buf val_buf [3:0] (val, val_drv);

  initial begin
    #1;
    force val = 4'b1010;
    if (val !== 4'b1010)
      $display("FAILED force not visible, val=%b", val);
    else
      $display("PASSED");
  end
endmodule
