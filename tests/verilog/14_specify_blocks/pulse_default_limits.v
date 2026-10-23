// With no pulse options or PATHPULSE$ declaration, both limits are 100%
// of the path delay (10). A width-4 pulse is suppressed; width 12 passes.
//! inherited IEEE 1364-2005 14.6.2
`timescale 1ns/1ns
module default_pulse_cell(input a, output y);
  assign y=a;
  specify (a=>y)=10; endspecify
endmodule
module pulse_default_limits;
  reg a=0; wire y;
  default_pulse_cell u(a,y);
  initial begin
    #20 a=1; #4 a=0; #7 $display("short=%b",y);
    #9 a=1; #11 $display("long=%b",y);
    #1 a=0; #11 $display("finished=%b",y); $finish(0);
  end
endmodule
