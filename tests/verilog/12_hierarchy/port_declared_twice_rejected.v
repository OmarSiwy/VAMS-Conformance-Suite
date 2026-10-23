// IEEE 1364-2005 §12.3.3, p. 174: "Once a name is used in a port declaration,
// it shall not be declared again in another port declaration or in a data type
// declaration." The clause's example (p. 175): "input aport; // First
// declaration - okay. input aport; // Error - multiple declaration, port
// declaration output aport; // Error - multiple declaration, port declaration".
//
// Legal neighbour: port_signed_inheritance.v (each port declared
// once as a port).
//! inherited IEEE 1364-2005 12.3.3
//! reject E0218
//! reject port redeclared in the module body
//! neighbour port_signed_inheritance.v
module m(aport);
  input aport;
  input aport;
  output aport;
endmodule
module b_12_3_3_port_declared_twice_rejected;
  wire w;
  m u(w);
endmodule
