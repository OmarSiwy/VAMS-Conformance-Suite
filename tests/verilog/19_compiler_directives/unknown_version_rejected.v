// IEEE 1364-2005 §19.11, p. 361: "Implementations and other standards are
// permitted to extend the `begin_keywords directive with custom version
// specifiers. It shall be an error if an implementation does not recognize
// the version_specifier used with the `begin_keywords directive."
//
// "1364-2099" is no version_specifier of Syntax 19-10 and none VerA adds.
// Legal neighbour: keyword_versions.v uses "1364-1995", "1364-2005"
// and "1364-2001".
//! inherited IEEE 1364-2005 19.11
//! reject E0135
//! reject unsupported keyword set
//! neighbour keyword_versions.v
`begin_keywords "1364-2099"
module b_19_11_unknown_version_rejected;
  initial $display("accepted");
endmodule
