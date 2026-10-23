//! inherited IEEE 1364-2005 4.5
// An undeclared identifier in a module instance's terminal list is an implicit
// scalar net: r in .r(!r) is one, undriven and so x under ! (pr1705027).
module child(output q, input r);
  assign q = r;
endmodule

module triage_implicit_net_in_instance_expression;
  wire q;

  child u(.q(q), .r(!r));

  initial #1 if (q === 1'bx) $display("PASSED"); else $display("FAILED %b", q);
endmodule
