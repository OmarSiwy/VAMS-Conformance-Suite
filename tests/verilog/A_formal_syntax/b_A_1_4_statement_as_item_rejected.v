// IEEE 1364-2005 A.1.4, p. 488: a module_item is a port_declaration or a
// non_port_module_item, and a non_port_module_item is a
// module_or_generate_item, a generate_region, a specify_block, a
// parameter_declaration or a specparam_declaration. A procedural statement
// is none of them: it enters a module only inside an initial_construct or an
// always_construct (A.6.2, p. 497: "initial_construct ::= initial statement").
//
// `r = 1;` directly in the module body therefore derives no module_item.
// Legal neighbour: b_A_1_4_module_items.v, whose statements are all inside
// initial and always constructs.
//! inherited IEEE 1364-2005 A.1.4
//! reject E0240
//! reject not a module item
//! neighbour b_A_1_4_module_items.v
module b_A_1_4_statement_as_item_rejected;
  reg r;
  r = 1;
  initial $display("unreachable");
endmodule
