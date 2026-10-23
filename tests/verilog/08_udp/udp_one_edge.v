// IEEE1364-2005 §§8.1.4/8.4: a sequential UDP row may carry one input
// transition descriptor. The legal twin of udp_two_edges_rejected.v:
// the same definition with the second descriptor (10) replaced by level 0, so
// the one-descriptor limit is the only thing between the two files. The
// definition is not instantiated, so the claim is definition acceptance.
//! lrm A.5.3
//! inherited IEEE 1364-2005 8.1.4 8.4
primitive shape_udp(q, a, b);
  output q; reg q;
  input a, b;
  table
    (01) 0 : ? : 1;
  endtable
endprimitive
module audit_definition;
  initial begin $display("definition accepted"); $finish(0); end
endmodule
