// IEEE 1364-2005 §13.3.1.1, p. 202: "The design statement names the library
// and cell of the top-level module or modules in the design hierarchy
// configured by the config. There shall be one and only one design statement,
// but multiple top-level modules can be listed in the design statement."
// §13.4.4, p. 206: "In the case where the config includes a design statement,
// then the specified cell shall be the top-level module, regardless of the
// presence of any uninstantiated cells in the rest of the source files."
//
// design lists t1 and t2, so both are top-level modules; `other` is
// uninstantiated and not listed, so it is not a top and never prints.
// t1 prints at t=0, t2 at t=1 (distinct times, no §11.4.2 order assumed),
// and t1 finishes at t=2:  "t1", "t2".
//! inherited IEEE 1364-2005 13.3.1.1 13.4.4
`timescale 1ns/1ns
config cfg;
  design work.t1 work.t2;
endconfig
module t1;
  initial begin
    $display("t1");
    #2 $finish(0);
  end
endmodule
module t2;
  initial #1 $display("t2");
endmodule
module other;
  initial $display("other");
endmodule
