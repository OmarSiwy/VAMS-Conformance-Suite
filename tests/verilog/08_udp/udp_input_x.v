// IEEE1364-2005 §8.1.5: a table entry may use x but not z. The legal twin of
// udp_input_z_rejected.v: the same single-row table with z replaced by x.
// The definition is not instantiated, so the claim is definition acceptance.
//! lrm A.5.3
//! inherited IEEE 1364-2005 8.1.5
primitive alphabet_udp(q, a, b);
  output q;
  input a, b;
  table
    x 0 : x;
  endtable
endprimitive
module audit_definition;
  initial begin $display("definition accepted"); $finish(0); end
endmodule
