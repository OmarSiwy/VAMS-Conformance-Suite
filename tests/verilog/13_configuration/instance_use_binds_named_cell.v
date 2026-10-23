// IEEE 1364-2005 §13.3.1.3, p. 203: "The instance clause is used to specify
// the specific instance to which the expansion clause shall apply." §13.3.1.6,
// p. 204: "It specifies the exact library and cell to which a selected cell or
// instance is bound." p. 205: "If the library name is omitted, the library
// shall be inherited from the parent cell." "NOTE—The binding statement can
// create situations where the unbound instance's module name and the cell name
// to which it is bound are different."
//
// top instantiates rtl twice. The instance clause selects top.u2 alone and
// binds it to cell gate; its library is omitted, so it is top's library, work.
// top.u1 matches no rule and stays rtl. Each prints its own %m and %l (§13.6)
// at a distinct time (parameter D), so no §11.4.2 order is assumed:
//   t=1  top.u1 bound to work.rtl  -> "rtl top.u1 work.rtl"
//   t=2  top.u2 bound to work.gate -> "gate top.u2 work.gate"
//! inherited IEEE 1364-2005 13.3.1.3 13.3.1.6
`timescale 1ns/1ns
config cfg;
  design work.top;
  instance top.u2 use gate;
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
