// IEEE 1364-2005 §12.1: "A module definition shall be enclosed between the
// keywords module and endmodule." A.1.3 lets every module item be absent, so
// a module with ports and a net and no process, gate or assignment is legal.
//
// HAND DERIVATION: nothing is ever scheduled, so the run ends at time 0 and
// prints nothing. The native executable holds a dispatch over no process.
//
//! inherited IEEE 1364-2005 12.1
`timescale 1ns/1ns
module b_12_1_module_without_process(a, y);
  input a;
  output y;
  wire w;
endmodule
