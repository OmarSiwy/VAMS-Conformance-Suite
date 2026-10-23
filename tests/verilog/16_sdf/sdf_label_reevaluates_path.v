// Annotation replaces the original delay 1 with 7. Samples bracket t=17; ignoring annotation fails the first sample.
//! inherited IEEE 1364-2005 16.2.3
`timescale 1ns/1ns
module sdf_cell(input a,output y);
  assign y=a;
  specify specparam delay_value=1; (a=>y)=delay_value; endspecify
endmodule
module sdf_label_reevaluates_path;
  reg a=0; wire y; integer fd; sdf_cell u(a,y);
  initial begin
    fd=$fopen("sdf_label_reevaluates_path.sdf","w");
    $fdisplay(fd,"(DELAYFILE");
    $fdisplay(fd," (SDFVERSION \"3.0\")");
    $fdisplay(fd," (TIMESCALE 1ns)");
    $fdisplay(fd," (CELL (CELLTYPE \"sdf_cell\") (INSTANCE) (LABEL (ABSOLUTE (delay_value (7)))))");
    $fdisplay(fd,")");
    $fclose(fd);
    $sdf_annotate("sdf_label_reevaluates_path.sdf",u);
    #10 a=1;
    #6 $display("before=%b",y);
    #2 $display("after=%b",y); $finish(0);
  end
endmodule
