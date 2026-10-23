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
// a11/bad/no_semicolon.map writes `include ../more.map` and then a
// library_declaration: the include_statement has no `;`, so no
// library_description derives the text. Legal neighbour:
// b_A_1_1_library_text.v, whose a11/lib.map ends its include_statement with
// `;`.
//@ libmap a11/bad/no_semicolon.map
//! lrm A.1.1
//! lrm A.1.1:1000
//! inherited IEEE 1364-2005 A.1.1
//! reject E0244
//! reject an `include` statement ends with `;`
//! neighbour b_A_1_1_library_text.v
module top;
endmodule
