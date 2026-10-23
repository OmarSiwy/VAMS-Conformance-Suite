// IEEE1364-2005 §§8.1.4/8.4 permit at most one input transition per row.
// This definition is not instantiated, isolating validation from unsupported
// UDP execution. The legal twin udp_one_edge.v changes only the second
// descriptor to level0 and is accepted.
//! lrm A.5.3
//! lrm A.5.3:1000
//! reject E0234
//! reject at most one input transition descriptor
//! neighbour udp_one_edge.v
//! inherited IEEE 1364-2005 8.1.4 8.4
primitive shape_udp(q, a, b);
  output q; reg q;
  input a, b;
  table
    (01) (10) : ? : 1;
  endtable
endprimitive
module audit_definition;
  initial begin $display("definition accepted"); $finish(0); end
endmodule
