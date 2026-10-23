// IEEE 1364-2005 §13.1.1, p. 199: "library_cell ::=
// [library_identifier.]cell_identifier[:config]" (Syntax 13-1). §13.3.1.6,
// p. 204: "use_clause ::= use [library_identifier.]cell_identifier[:config]"
// (Syntax 13-9).
//
// The only suffix either production admits after `:` is the keyword config.
// `use work.leaf:module` puts `module` there, which no production derives.
// Legal neighbour: every_rule_form.v, whose use clauses carry no
// suffix.
//! inherited IEEE 1364-2005 13.1.1 13.3.1.6
//! reject E0207
//! reject a use_clause's `:` is followed by the word `config`
//! neighbour every_rule_form.v
config cfg;
  design work.top;
  instance top.u use work.leaf:module;
endconfig
module leaf;
  initial $display("leaf");
endmodule
module top;
  leaf u();
endmodule
