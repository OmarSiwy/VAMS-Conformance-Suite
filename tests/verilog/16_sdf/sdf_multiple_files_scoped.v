// Two files annotate the same instance in order: 5+2=7. The sibling retains its original delay 1.
//! inherited IEEE 1364-2005 16.4 17.2.10
`timescale 1ns/1ns
module sdf_cell(input a,output y);
  assign y=a;
  specify specparam delay_value=1; (a=>y)=delay_value; endspecify
endmodule
module sdf_multiple_files_scoped;
  reg a=0; wire y,z; integer fd; sdf_cell u(a,y),untouched(a,z);
  initial begin
    fd=$fopen("sdf_multiple_files_scoped_first.sdf","w");
    $fdisplay(fd,"(DELAYFILE");
    $fdisplay(fd," (SDFVERSION \"3.0\")");
    $fdisplay(fd," (TIMESCALE 1ns)");
    $fdisplay(fd," (CELL (CELLTYPE \"sdf_cell\") (INSTANCE) (DELAY (ABSOLUTE (IOPATH a y (5)))))");
    $fdisplay(fd,")");
    $fclose(fd);
    fd=$fopen("sdf_multiple_files_scoped_next.sdf","w");
    $fdisplay(fd,"(DELAYFILE");
    $fdisplay(fd," (SDFVERSION \"3.0\")");
    $fdisplay(fd," (TIMESCALE 1ns)");
    $fdisplay(fd," (CELL (CELLTYPE \"sdf_cell\") (INSTANCE) (DELAY (INCREMENT (IOPATH a y (2)))))");
    $fdisplay(fd,")");
    $fclose(fd);
    $sdf_annotate("sdf_multiple_files_scoped_first.sdf",u);
    $sdf_annotate("sdf_multiple_files_scoped_next.sdf",u);
    #10 a=1; #3 $display("early=%b,%b",y,z);
    #5 $display("late=%b,%b",y,z); $finish(0);
  end
endmodule
