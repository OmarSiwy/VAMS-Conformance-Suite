// IEEE 1364-2005 §13.3.1.4, p. 204: "The cell selection clause names the cell
// to which it applies." §13.3.1.6, p. 204: "A use clause can only be used in
// conjunction with an instance or cell selection clause. It specifies the
// exact library and cell to which a selected cell or instance is bound."
//
// `cell rtl use work.gate;` selects every instance of cell rtl, so both of
// top's instances bind to work.gate. Each prints its own %m and %l (§13.6) at
// a distinct time (parameter D), so no §11.4.2 order is assumed:
//   t=1  "gate top.u1 work.gate"
//   t=2  "gate top.u2 work.gate"
//! lrm A.1.5
//! lrm A.1.5:1000
//! inherited IEEE 1364-2005 13.3.1.4 13.3.1.6
`timescale 1ns/1ns
config cfg;
  design work.top;
  cell rtl use work.gate;
endconfig
module rtl;
  parameter D = 0;
  initial #D $display("rtl %m %l");
endmodule
module gate;
  parameter D = 0;
  initial #D $display("gate %m %l");
endmodule
module top;
  rtl #(1) u1();
  rtl #(2) u2();
  initial #3 $finish(0);
endmodule
