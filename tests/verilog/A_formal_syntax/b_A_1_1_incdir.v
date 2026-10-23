// IEEE 1364-2005 A.1.1, p. 487:
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
// a11/incdir.map writes `library liba cells/a.v -incdir cells, bad;`: a
// library_declaration with an -incdir list of two file_path_specs. Neither
// clause 13 nor Annex A says what the list does, and nothing here includes
// a file, so only the library binding is observable: u1's a is liba's and
// this file, matching no file_path_spec, is work's (§13.2.1):
//   t=0 top work.top; t=1 top.u1 liba.a.
//@ libmap a11/incdir.map
//@ files a11/cells/a.v
//! lrm A.1.1
//! lrm A.1.1:1000
//! inherited IEEE 1364-2005 A.1.1
`timescale 1ns/1ns
module top;
  a #(1) u1();
  initial $display("%m %l");
endmodule
