// IEEE 1364-2005 §13.2.1.1, p. 202: "If multiple cells with the same name map
// to the same library, then the LAST cell encountered shall be written to the
// library. This is to support a "separate-compile" use model (see 13.4.3),
// where it is assumed that encountering a cell after it has previously been
// compiled is intended to be a recompiling of the cell. In the case where
// multiple modules with the same name are mapped to the same library in a
// single invocation of the compiler, then a warning message shall be issued."
//
// §4.11, p. 39, reads the other way: "Once a name is used to define a module
// or primitive, the name shall not be used again to declare another module or
// primitive." The two texts conflict. This fixture follows §13.2.1.1, the
// specific rule: it names exactly this case (same-named modules, one library,
// one compiler invocation) and prescribes a warning and last-wins, not an
// error; §4.11's text predates libraries. A tool that refuses the file under
// §4.11 is also defensible; VerA follows §13.2.1.1.
//
// Both leaf modules are in work (no map, §13.2.1); the second is the last
// encountered, so work.leaf is the second and top.u prints "second". The
// clause's warning names no text; VerA's is W1152.
//! inherited IEEE 1364-2005 13.2.1.1
module leaf;
  initial $display("first");
endmodule
module leaf;
  initial $display("second");
endmodule
module top;
  leaf u();
endmodule
