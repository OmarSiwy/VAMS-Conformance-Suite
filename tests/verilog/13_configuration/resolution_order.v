// IEEE 1364-2005 §13.2.1.1, p. 201: "If a file name potentially matches
// multiple file path specifications, the path specifications shall be resolved
// in the following order: a) File path specifications that end with an
// explicit filename b) File path specifications that end with a wildcarded
// filename c) File path specifications that end with a directory". §13.2.1,
// p. 201: "Paths that end in / shall include all files in the specified
// directory." "Any file encountered by the compiler that does not match any
// library's file_path_spec shall by default be compiled into a library named
// work." §13.2.3, p. 202: "The cell is mapped into the library whose file path
// specification matches the source file name."
//
// §13.7.3's example (libmap/proj/tb/lib.map, its /proj/lib1 paths relative to
// /proj/tb): lib1 "foo*.v", lib2 "foo.v", lib3 the directory, lib4 "*ver.v".
// Each file is a module of its own name, printing %m and %l (§13.6) at D:
//   foobar.v  lib1 (wildcarded filename over lib3's directory)   t=1
//   foo.v     lib2 (explicit filename over lib1 and lib3)          t=2
//   bar.v     lib3 (only the directory matches)                    t=3
//   barver.v  lib4 (wildcarded filename over lib3's directory)   t=4
// This file matches nothing: work.top, at t=0.
//@ libmap libmap/proj/tb/lib.map
//@ files libmap/proj/lib1/foobar.v libmap/proj/lib1/foo.v libmap/proj/lib1/bar.v libmap/proj/lib1/barver.v
//! inherited IEEE 1364-2005 13.2.1.1 13.2.1 13.2.3
`timescale 1ns/1ns
module top;
  foobar #(1) u1();
  foo #(2) u2();
  bar #(3) u3();
  barver #(4) u4();
  initial $display("%m %l");
endmodule
