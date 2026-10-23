// The Verilog-A model spice_lib_models.lib's `.HDL` card names, for
// spice_lib_include_hdl.va: I(d, s) = KP * (W/L) * V(g, s) * V(d, s).
`include "disciplines.vams"
module linfet(d, g, s, b);
  inout d, g, s, b; electrical d, g, s, b;
  parameter real KP = 1e-3;
  parameter real W = 1.0;
  parameter real L = 1.0;
  analog I(d, s) <+ KP * (W / L) * V(g, s) * V(d, s);
endmodule
