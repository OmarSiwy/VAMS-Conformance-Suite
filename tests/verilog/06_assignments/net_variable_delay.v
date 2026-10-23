//! inherited IEEE 1364-2005 6.1.3 7.14 A.2.2.3
// A net declaration assignment's delay may likewise be a variable expression
// (delay3/delay4).
module triage_net_variable_delay;
  reg [31:0] d;
  reg x;
  wire #d y = x;

  initial begin
    d = 3;
    x = 0;
    #4 $display("t4 %0d", y);
    x = 1;
    #4 $display("t8 %0d", y);
  end
endmodule
