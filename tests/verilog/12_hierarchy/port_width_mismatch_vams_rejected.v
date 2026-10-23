//! lrm-reject 6.5.7.1:1
//! reject-only the sizes of the port and the net connected to it shall match
// Verilog-AMS 2023 §6.5.7.1: "The sizes of the ports and net must match."
// Under the default language (VAMS 2023) a 1-bit net on a 2-bit input port is
// refused. Under `--std=1364-2005` the same connection is IEEE 1364-2005
// §12.3.9.2's continuous assignment (triage_port_input_width_extends).
module copy(output [1:0] out, input [1:0] in);
  assign out = in;
endmodule

module port_width_mismatch_vams_rejected;
  wire i1;
  wire [1:0] o1;

  copy c1(o1, i1);
endmodule
