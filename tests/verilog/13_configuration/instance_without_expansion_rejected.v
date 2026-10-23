// IEEE 1364-2005 §13.3.1.3, p. 203: "The instance clause is used to specify
// the specific instance to which the expansion clause shall apply." Syntax
// 13-4 (§13.3.1, p. 203) admits an inst_clause only as "inst_clause
// liblist_clause ;" or "inst_clause use_clause ;".
//
// `instance top.u;` has no expansion clause to apply. Legal neighbour:
// every_rule_form.v, whose instance clauses carry liblist and use.
//! inherited IEEE 1364-2005 13.3.1.3 13.3.1
//! reject E0207
//! reject pairs with `liblist` or `use`
//! neighbour every_rule_form.v
config cfg;
  design work.top;
  instance top.u;
endconfig
module leaf;
  initial $display("leaf");
endmodule
module top;
  leaf u();
endmodule
