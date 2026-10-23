`timescale 1ns/1ps
module v_inv(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule
