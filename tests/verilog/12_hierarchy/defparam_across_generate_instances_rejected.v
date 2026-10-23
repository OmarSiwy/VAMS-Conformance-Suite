// IEEE 1364-2005 §12.2.1, pp. 168-169: "a defparam statement in a hierarchy in
// or under a generate block instance ... shall not change a parameter value
// outside that hierarchy. Each instantiation of a generate block is considered
// to be a separate hierarchy scope. Therefore, this rule implies that a
// defparam statement in a generate block may not target a parameter in
// another instantiation of the same generate block, even when the other
// instantiation is created by the same loop generate construct. For example,
// the following code is not allowed:" (the somename loop below).
//
// somename[i]'s defparam targets somename[(i+1) % 8].my_flop. The clause's
// i+1 is wrapped so that somename[7] targets somename[0], not a somename[8]
// that does not exist: every target resolves, and targeting another instance
// of the block is the only error. Legal neighbour:
// defparam_inside_generate_block.v (each defparam targets its own
// block's instance).
//! lrm 6.3.1
//! lrm 6.3.1:1
//! lrm 6.3.1:3
//! lrm 6.3.1:6
//! inherited IEEE 1364-2005 12.2.1
//! reject-only E1100
//! reject outside the generate block
//! neighbour defparam_inside_generate_block.v
module flop;
  parameter xyz = 0;
endmodule
module b_12_2_1_defparam_across_generate_instances_rejected;
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : somename
      flop my_flop();
      defparam somename[(i+1) % 8].my_flop.xyz = i ;
    end
  endgenerate
endmodule
