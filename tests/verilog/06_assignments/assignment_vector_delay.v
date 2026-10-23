// IEEE1364-2005 §6.1.3: vector nonzero-to-nonzero uses rising delay,
// even if one bit falls. Whole-vector transition to zero uses falling delay;
// all-z uses turnoff. Samples deliberately avoid exact update-time races.
//! inherited IEEE 1364-2005 6.1.3
`timescale 1ns/1ns
module audit_assignment_vector_delay;
  reg [1:0] a;
  wire [1:0] y;
  assign #(2,7,4) y = a;
  initial begin
    a = 0;
    #10 a = 1;
    #3 $display("nonzero=%b", y);
    a = 2;
    #3 $display("nonzero_to_nonzero=%b", y);
    a = 0;
    #6 $display("before_fall=%b", y);
    #2 $display("after_fall=%b", y);
    a = 2'bzz;
    #3 $display("before_turnoff=%b", y);
    #2 $display("after_turnoff=%b", y);
    $finish(0);
  end
endmodule
