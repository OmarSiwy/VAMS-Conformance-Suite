// IEEE 1364-2005 §12.1.2, p. 165: "Module definitions do not nest. In other
// words, one module definition shall not contain the text of another module
// definition within its module-endmodule keyword pair. A module definition
// nests another module by instantiating it."
//
// inner's definition is written inside outer's. Legal neighbour:
// ffnand_instances.v (ffnand defined alongside, then instantiated).
//! lrm 6.1
//! lrm 6.1:1000
//! inherited IEEE 1364-2005 12.1.2
//! reject E0240
//! reject not a module item
//! neighbour ffnand_instances.v
module b_12_1_2_nested_module_definition_rejected;
  module inner;
  endmodule
endmodule
