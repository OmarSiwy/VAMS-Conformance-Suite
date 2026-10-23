// IEEE 1364-2005 §12.3.5 connects instance port expressions to the module's
// declared ports in the same order; §12.1.2 connects the nth to the nth.
// §12.1.2: "the first element in the list shall connect to the first port
// declared in the module, the second to the second port, and so on."
// The two null ports below retain their positions; the module has four
// ports, so a fifth connection has no declared port. Legal neighbour:
// null_port_combinations.v supplies the four positions and runs them.
//! inherited IEEE 1364-2005 12.3.5
//! reject E1100
//! reject more port connections than the module has ports
//! neighbour null_port_combinations.v
module null_leaf(a, , , y);
  input a;
  output y;
  assign y = a;
endmodule
module b_12_null_port_extra_connection_rejected;
  wire y;
  null_leaf u(1'b1, , , y, 1'b0);
endmodule
