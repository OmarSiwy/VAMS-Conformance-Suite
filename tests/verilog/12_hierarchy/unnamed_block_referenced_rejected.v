// IEEE 1364-2005 §12.4.3, p. 190: "Although an unnamed generate block has no
// name that can be used in a hierarchical name, it needs to have a name by
// which external interfaces can refer to it." §12.5, p. 191: "Objects declared
// in unnamed generate blocks are also exceptions. They can be referenced by
// hierarchical names only from within the block and within any hierarchy
// instantiated by the block."
//
// The first construct's block is unnamed (its external name is genblk1); the
// module's initial, outside it, references genblk1.a. Legal neighbour:
// hierarchical_path_names.v (paths through instance and block names).
//! inherited IEEE 1364-2005 12.4.3 12.5
//! reject E1100
//! reject undeclared instance in a hierarchical reference
//! neighbour hierarchical_path_names.v
module b_12_4_3_unnamed_block_referenced_rejected;
  if (1) begin
    reg a;
  end
  initial $display("%b", genblk1.a);
endmodule
