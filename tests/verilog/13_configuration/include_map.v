// IEEE 1364-2005 §13.2.2, p. 202: "The include command is used to insert the
// entire contents of a library map file in another file during parsing. The
// result is as though the contents of the included map file appear in place
// of the include command." "If the file path specification, whether in an
// include or library statement, describes a relative path, it shall be
// relative to the location of the file that contains the file path."
//
// libmap/inc/outer.map holds only `include ../proj/tb/lib.map;`, relative to
// libmap/inc/. The included map's "../lib1/" specifications are relative to
// libmap/proj/tb/, which holds them: bar.v is lib3's (the directory) and
// barver.v lib4's ("*ver.v"). Resolved against outer.map's directory they
// would name libmap/lib1/, which does not exist, and both would be work.
//   t=0 top work.top; t=1 top.u1 lib3.bar; t=2 top.u2 lib4.barver.
//@ libmap libmap/inc/outer.map
//@ files libmap/proj/lib1/bar.v libmap/proj/lib1/barver.v
//! inherited IEEE 1364-2005 13.2.2
`timescale 1ns/1ns
module top;
  bar #(1) u1();
  barver #(2) u2();
  initial $display("%m %l");
endmodule
