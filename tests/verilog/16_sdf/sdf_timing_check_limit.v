// A 3 ns separation satisfies the original setup limit 1, but violates the annotated limit 5.
//! inherited IEEE 1364-2005 16.2.2
`timescale 1ns/1ns
module sdf_timing_cell(input clk,input d);
  reg note=0;
  specify $setup(d,posedge clk,1,note); endspecify
endmodule
module sdf_timing_check_limit;
  reg clk=0,d=0; integer fd; sdf_timing_cell u(clk,d);
  initial begin
    fd=$fopen("sdf_timing_check_limit.sdf","w");
    $fdisplay(fd,"(DELAYFILE");
    $fdisplay(fd," (SDFVERSION \"3.0\")");
    $fdisplay(fd," (TIMESCALE 1ns)");
    $fdisplay(fd," (CELL (CELLTYPE \"sdf_timing_cell\") (INSTANCE) (TIMINGCHECK (SETUP d (posedge clk) (5))))");
    $fdisplay(fd,")");
    $fclose(fd);
    $sdf_annotate("sdf_timing_check_limit.sdf",u);
    #10 d=1; #3 clk=1; #1 $display("notified=%b",u.note); $finish(0);
  end
endmodule
