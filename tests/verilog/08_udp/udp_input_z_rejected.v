// IEEE1364-2005 8.1.5 prohibits z in a table entry. This differs from a
// runtime input z, which must be treated as x. Replacing z by x is legal.
// Definition-only test isolates the table alphabet from unimplemented runtime.
//! lrm A.5.3
//! lrm A.5.3:1000
//! inherited IEEE 1364-2005 8.1.5
//! reject E0233
//! reject not a UDP input symbol
primitive alphabet_udp(q, a, b);
  output q;
  input a, b;
  table
    z 0 : x;
  endtable
endprimitive
module audit_definition;
  initial begin $display("definition accepted"); $finish(0); end
endmodule
