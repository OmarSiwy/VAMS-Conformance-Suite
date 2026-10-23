// IEEE 1364-2005 §4.11, p. 39: "Once a name is defined within the block,
// module, port, generate block, or specify block name space, it shall not be
// defined again in that space (with the same or a different type)." p. 40:
// the module name space "unifies the definition of functions, tasks, named
// blocks, module instances, generate blocks, parameters, named events,
// genvars, net type of declaration, and variable type of declaration."
//
// x is declared as a reg, then again as an integer, in one module. Legal
// neighbour: name_spaces.v (one x per space).
//! lrm 6.8
//! lrm 6.8:1
//! lrm 6.8:2
//! inherited IEEE 1364-2005 4.11
//! reject E1100
//! reject duplicate
//! neighbour name_spaces.v
module b_4_11_variable_redefined_rejected;
  reg x;
  integer x;
endmodule
