// The SDF PATHPULSE (0,0) overrides the source PATHPULSE$ (7,9), preserving the width-4 output pulse.
//! inherited IEEE 1364-2005 14.6.3 16.5
`timescale 1ns/1ns
module sdf_pulse_cell(input a,output y);
  assign y=a;
  specify specparam PATHPULSE$=(7,9); (a=>y)=10; endspecify
endmodule
module sdf_pulse_limits_override_specparam;
  reg a=0; wire y; integer fd; sdf_pulse_cell u(a,y);
  initial begin
    fd=$fopen("sdf_pulse_limits_override_specparam.sdf","w");
    $fdisplay(fd,"(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns) (CELL (CELLTYPE \"sdf_pulse_cell\") (INSTANCE) (DELAY (PATHPULSE a y (0) (0)))))"); $fclose(fd);
    $sdf_annotate("sdf_pulse_limits_override_specparam.sdf",u);
    #20 a=1; #4 a=0; #7 $display("pulse=%b",y);
    #4 $display("settled=%b",y); $finish(0);
  end
endmodule
