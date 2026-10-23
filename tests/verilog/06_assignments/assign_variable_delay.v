//! inherited IEEE 1364-2005 6.1.3 7.14 A.2.2.3
// A continuous assignment's delay may be a variable expression, evaluated when
// the assignment is scheduled: #d with d=3 delays three time units (delay3).
module triage_assign_variable_delay;
  reg [31:0] d;
  reg x;
  wire y;

  assign #d y = x;

  initial begin
    d = 3;
    x = 0;
    #4 $display("t4 %0d", y);
    x = 1;
    #4 $display("t8 %0d", y);
  end
endmodule
