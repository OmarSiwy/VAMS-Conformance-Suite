// IEEE 1364-2005 §19.3.2, p. 352: "The directive `undef shall undefine a
// previously defined text macro. An attempt to undefine a text macro that was
// not previously defined using a `define compiler directive can result in a
// warning." ... "An undefined text macro has no value, just as if it had
// never been defined."
//
// width is defined as 4 and read (4), then undefined: `ifdef width now takes
// its `else arm ("width undefined"), as for a name never defined. Defined
// again as 6 after the `undef: 6 (nothing of the old definition survives).
// `undef never_defined is allowed ("can result in a warning", not an error),
// so the module still compiles and runs.
//! inherited IEEE 1364-2005 19.3.2
`define width 4
`undef never_defined
module b_19_3_2_undef;
  initial begin
    $display("%0d", `width);
`undef width
`ifdef width
    $display("width defined");
`else
    $display("width undefined");
`endif
`define width 6
    $display("%0d", `width);
    $finish(0);
  end
endmodule
