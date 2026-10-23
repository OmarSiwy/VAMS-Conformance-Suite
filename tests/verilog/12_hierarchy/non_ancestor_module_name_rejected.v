// IEEE 1364-2005 §12.6, p. 193: "A lower level module can reference items in a
// module above it in the hierarchy." p. 194: a scope_name.item_name "shall be
// resolved as follows: a) Look in the current scope for a scope named
// scope_name. ... b) Look in the parent module's outermost scope for a scope
// named scope_name. If found, the item name shall be resolved from that scope.
// c) Repeat step b), going up the hierarchy." §12.5, p. 191: "The complete
// path name to any object shall start at a top-level (root) module."
//
// p references qmod.i. qmod is not p nor any module above p (p's parent is
// the top module), no scope named qmod exists in p or in the top module's
// outermost scope (its instances are u and v), and qmod is not a top-level
// module (q instantiates it). The name resolves to nothing. Legal neighbour:
// hierarchy_upward_reference.v (b.i from c, whose ancestor is b).
//! inherited IEEE 1364-2005 12.6
//! reject E1100
//! reject undeclared instance in a hierarchical reference
//! neighbour hierarchy_upward_reference.v
`timescale 1ns/1ns
module b_12_6_non_ancestor_module_name_rejected;
  p u();
  q v();
endmodule
module p;
  initial #1 $display("%0d", qmod.i);
endmodule
module qmod;
  integer i;
  initial i = 4;
endmodule
module q;
  qmod w();
endmodule
