// IEEE 1364-2005 §4.5, pp. 25-26: "In the absence of an explicit
// declaration, an implicit net of default net type shall be assumed in the
// following circumstances:" ... "— If an identifier is used in the terminal
// list of a primitive instance or a module instance, and that identifier has
// not been declared previously in the scope where the instantiation appears
// ... then an implicit scalar net of default net type shall be assumed. — If
// an identifier appears on the left-hand side of a continuous assignment
// statement, and that identifier has not been declared previously in the
// scope where the continuous assignment statement appears ... then an
// implicit scalar net of default net type shall be assumed."
//
// No `default_nettype, so the default net type is wire (§19.2).
//   q: undeclared, in module instance sub u(q, r): sub drives y = ~a,
//      r = 0 -> q = 1
//   o: undeclared, output terminal of and g(o, q, 1'b1) -> 1 & 1 = 1
//   k: undeclared, LHS of assign k = 2'b10: a scalar net, so it keeps the
//      LSB (§5.6) -> 0
//! inherited IEEE 1364-2005 4.5
module b_4_5_implicit_nets;
  reg r;
  sub u(q, r);
  and g(o, q, 1'b1);
  assign k = 2'b10;
  initial begin
    r = 0;
    #1 $display("%b %b %b", q, o, k);
    $finish(0);
  end
endmodule

module sub(output y, input a);
  assign y = ~a;
endmodule
