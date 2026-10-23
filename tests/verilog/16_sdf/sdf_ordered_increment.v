// Annotation replaces the original delay 1 with 9. Samples bracket t=19; ignoring annotation fails the first sample.
//! inherited IEEE 1364-2005 16.3
`timescale 1ns/1ns
module sdf_cell(input a,output y);
  assign y=a;
  specify specparam delay_value=1; (a=>y)=delay_value; endspecify
endmodule
module sdf_ordered_increment;
  reg a=0; wire y; integer fd; sdf_cell u(a,y);
  initial begin
    fd=$fopen("sdf_ordered_increment.sdf","w");
    $fdisplay(fd,"(DELAYFILE");
    $fdisplay(fd," (SDFVERSION \"3.0\")");
    $fdisplay(fd," (TIMESCALE 1ns)");
    $fdisplay(fd," (CELL (CELLTYPE \"sdf_cell\") (INSTANCE) (DELAY (ABSOLUTE (IOPATH a y (7))) (INCREMENT (IOPATH a y (2)))))");
    $fdisplay(fd,")");
    $fclose(fd);
    $sdf_annotate("sdf_ordered_increment.sdf",u);
    #10 a=1;
    #8 $display("before=%b",y);
    #2 $display("after=%b",y); $finish(0);
  end
endmodule
