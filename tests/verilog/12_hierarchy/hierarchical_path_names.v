// IEEE 1364-2005 §12.5, p. 191: "Any named Verilog object or hierarchical name
// reference can be referenced uniquely in its full form by concatenating the
// names of the modules, module instance names, generate blocks, tasks,
// functions, or named blocks that contain it. The period character shall be
// used to separate each of the names in the hierarchy". "The complete path
// name to any object shall start at a top-level (root) module. This path name
// can be used from any level in the hierarchy or from a parallel hierarchy.
// The first node name in a path name can also be the top of a hierarchy that
// starts at the level where the path is being used (which allows and enables
// downward referencing of items)." p. 193: "If the unique hierarchical path
// name of an item is known, its value can be sampled or changed from anywhere
// within the description."
//
// The clause's Example 1 (p. 192), top module renamed wave -> this module;
// mod's reg hold is declared in the module (block-local declarations are
// named_block_items.v). Figure 12-2's names used here:
//   t=2  stim1 rises; amod's named block keep runs: %m ->
//        <top>.a.amod.keep
//   t=3  <top>.a.amod.hold (full path from the root) = 1; a.bmod.hold
//        (downward from this module) = x, bmod never saw a posedge; the port
//        net <top>.a.stim1 = 1.  -> "1 x 1"
//   t=100 the fork innerwave in named block wave1: %m -> <top>.wave1.innerwave
//! inherited IEEE 1364-2005 12.5
`timescale 1ns/1ns
module mod (in);
  input in;
  reg hold;
  always @(posedge in) begin : keep
    hold = in;
    $display("%m");
  end
endmodule
module cct (stim1, stim2);
  input stim1, stim2;
  mod amod(stim1), bmod(stim2);
endmodule
module b_12_5_hierarchical_path_names;
  reg stim1, stim2;
  cct a(stim1, stim2);
  initial begin :wave1
    #100 fork :innerwave
           $display("%m");
         join
    #150 begin
           stim1 = 0;
         end
  end
  initial begin
    #1 stim1 = 0; stim2 = 0;
    #1 stim1 = 1;
    #1 $display("%b %b %b", b_12_5_hierarchical_path_names.a.amod.hold, a.bmod.hold,
                b_12_5_hierarchical_path_names.a.stim1);
  end
endmodule
