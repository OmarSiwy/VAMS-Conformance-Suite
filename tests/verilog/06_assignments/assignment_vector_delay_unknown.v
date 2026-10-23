// IEEE1364-2005 §6.1.3: vector transitions other than nonzero->zero
// and all-z use rising delay. Mixed x/z is not all-z; unlike scalar gates,
// a vector transition to x does not select the minimum delay.
// #(7,5,2): start00; at10 assign0x -> due17; at19 assign1z -> due26;
// at28 assignzz -> due30. Samples avoid update instants.
//! inherited IEEE 1364-2005 6.1.3
`timescale 1ns/1ns
module audit_assignment_vector_delay_unknown;
  reg [1:0] a;
  wire [1:0] y;
  assign #(7,5,2) y = a;
  initial begin
    a = 0;
    #10 a = 2'b0x;
    #3 $display("before_x=%b", y);
    #5 $display("after_x=%b", y);
    #1 a = 2'b1z;
    #3 $display("before_mixed_z=%b", y);
    #5 $display("after_mixed_z=%b", y);
    #1 a = 2'bzz;
    #1 $display("before_all_z=%b", y);
    #2 $display("after_all_z=%b", y);
    $finish(0);
  end
endmodule
