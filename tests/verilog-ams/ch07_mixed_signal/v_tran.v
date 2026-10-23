// E1103: a construct the native code generator does not compile, named.
`timescale 1ns/1ps
module v_tran(a, y);
  input a;
  output y;
  wire w;
  tran (w, a);
  assign y = w;
endmodule
