// LRM 10.6: "Without this directive, the set of reserved keywords in effect
// for this module shall be the implementation's default set of reserved
// keywords", and VerA's default is VAMS-2023, where `analog` is annex B. The
// same declaration std_1364_ams_keywords_are_identifiers.v makes under
// --std=1364-2005 is therefore a keyword where A.2.1.3 wants an identifier.
//! lrm 10.6
//! reject E0208
//! neighbour std_1364_ams_keywords_are_identifiers.v
module std_1364_ams_keywords_reserved_by_default;
  reg [3:0] analog;
  initial $finish(0);
endmodule
