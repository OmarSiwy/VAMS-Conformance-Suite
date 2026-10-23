// E1103: an integer port is not a vector of pins.
`timescale 1ns/1ps
module v_integer(y);
  output y;
  integer y;
  initial y = 3;
endmodule
