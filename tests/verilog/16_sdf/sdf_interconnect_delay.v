// Only the annotated source-to-load connection acquires delay 7; its early sample must retain the old value.
//! inherited IEEE 1364-2005 16.2.4
`timescale 1ns/1ns
module sdf_wire(input a,output y); assign y=a; endmodule
module sdf_interconnect_delay;
  reg a=0; wire net_value,y; integer fd;
  sdf_wire source(a,net_value),sink(net_value,y);
  initial begin
    fd=$fopen("sdf_interconnect_delay.sdf","w");
    $fdisplay(fd,"(DELAYFILE");
    $fdisplay(fd," (SDFVERSION \"3.0\")");
    $fdisplay(fd," (TIMESCALE 1ns)");
    $fdisplay(fd," (CELL (CELLTYPE \"sdf_interconnect_delay\") (INSTANCE) (DELAY (ABSOLUTE (INTERCONNECT source.y sink.a (7)))))");
    $fdisplay(fd,")");
    $fclose(fd);
    $sdf_annotate("sdf_interconnect_delay.sdf");
    #10 a=1; #3 $display("early=%b",y);
    #5 $display("late=%b",y); $finish(0);
  end
endmodule
