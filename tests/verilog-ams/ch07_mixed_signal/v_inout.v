// E1103: an inout port has no bridge (the analog side would drive a resolved net).
`timescale 1ns/1ps
module v_inout(a, y);
  inout a;
  output y;
  assign y = a;
endmodule
