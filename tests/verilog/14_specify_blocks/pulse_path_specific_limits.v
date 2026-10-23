// A width-4 pulse is rejected by the generic (7,9) limits.
// The path-specific (0,0) override on z passes it unchanged at t=30..34.
//! inherited IEEE 1364-2005 14.6 14.6.1
`timescale 1ns/1ns
module pulse_specific_cell(input a,output y,output z);
  assign y=a; assign z=a;
  specify
    specparam PATHPULSE$=(7,9), PATHPULSE$a$z=(0,0);
    (a=>y)=10; (a=>z)=10;
  endspecify
endmodule
module pulse_path_specific_limits;
  reg a=0; wire y,z; pulse_specific_cell u(a,y,z);
  initial begin
    #20 a=1; #4 a=0; #7 $display("pulse=%b,%b",y,z);
    #4 $display("settled=%b,%b",y,z); $finish(0);
  end
endmodule
