// IEEE 1364-2005 §12.7: an identifier referenced without a hierarchical path
// is searched for upward "until an item by that name is found or until a
// module boundary is encountered. If the item is a variable, it shall stop at
// a module boundary". §12.6's upward search is for hierarchical names; a
// simple name is not one.
//
// So `j` in `leaf` names nothing: `j` is declared only in the module above,
// and the search for a variable stops at leaf's boundary. `top.j` would be
// the legal spelling (hierarchy_upward_reference.v).
//! lrm 6.8
//! lrm 6.8:5
//! inherited IEEE 1364-2005 12.7
//! reject undeclared digital variable
//! neighbour hierarchy_upward_reference.v
`timescale 1ns/1ns
module audit_hierarchy_simple_name_stops_at_module_rejected;
  integer j;
  leaf u();
endmodule
module leaf;
  initial j = 1;
endmodule
