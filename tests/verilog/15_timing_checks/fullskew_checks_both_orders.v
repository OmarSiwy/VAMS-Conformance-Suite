// The reference-first timer uses limit 3; the data-first timer uses limit 5. Sample after each expiration.
//! inherited IEEE 1364-2005 15.3.3
`timescale 1ns/1ns
module fullskew_cell(input r,input d);
  reg note=0;
  specify $fullskew(posedge r,posedge d,3,5,note); endspecify
endmodule
module fullskew_checks_both_orders;
  reg a=0,b=0,c=0,d=0;
  fullskew_cell forward(a,b), reverse(c,d);
  initial begin
    #10 begin a=1; d=1; end
    #4 $display("t14=%b,%b",forward.note,reverse.note);
    #2 $display("t16=%b,%b",forward.note,reverse.note); $finish(0);
  end
endmodule
