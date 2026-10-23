// IEEE 1364-2005 A.1.1, p. 487: "The syntax of a library map file is derived
// from the starting symbol library_text." (Annex A preamble, p. 487)
//   library_text ::= { library_description }
//   library_description ::=
//       library_declaration
//     | include_statement
//     | config_declaration
//   library_declaration ::=
//       library library_identifier file_path_spec [ { , file_path_spec } ]
//       [ -incdir file_path_spec { , file_path_spec } ] ;
//   include_statement ::= include file_path_spec ;
//
// a11/lib.map is a library_text of two library_descriptions: the
// library_declaration `library liba cells/a.v, "cells/b.v";` (two
// file_path_specs, the second quoted as §13.7.3's example, p. 209, writes
// `library lib1 "/proj/lib1/foo*.v";`) and the include_statement
// `include more.map;`, whose library_declaration `library libc cells/c*.v;`
// reads as though it stood in its place (§13.2.2). Each cell prints %m %l at
// its D; this file matches no file_path_spec and is work's (§13.2.1):
//   t=0 top work.top; t=1 top.u1 liba.a; t=2 top.u2 liba.b;
//   t=3 top.u3 libc.c1.
//@ libmap a11/lib.map
//@ files a11/cells/a.v a11/cells/b.v a11/cells/c1.v
//! lrm A.1.1
//! lrm A.1.1:1000
//! lrm A:1001
//! inherited IEEE 1364-2005 A.1.1
`timescale 1ns/1ns
module top;
  a #(1) u1();
  b #(2) u2();
  c1 #(3) u3();
  initial $display("%m %l");
endmodule
