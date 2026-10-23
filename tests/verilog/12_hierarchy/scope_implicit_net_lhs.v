//! inherited IEEE 1364-2005 4.5
// The upwards search for a name stops at a module boundary: inside `test`, q
// is an implicit scalar net even though the containing module `main` has a
// wire q; the test's own q is 1 and main.q stays 0 (scope2b).
module test(p);
  output p;

  assign q = 1;
  assign p = q;
endmodule

module triage_scope_implicit_net_lhs;
  wire q = 0;
  wire sig;
  test inst(sig);

  initial begin
    #1;
    if (q !== 1'b0) $display("FAILED -- main.q == %b", q);
    else if (sig !== 1'b1) $display("FAILED -- test.q == %b", sig);
    else $display("PASSED");
  end
endmodule
